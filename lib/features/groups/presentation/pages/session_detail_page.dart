import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/services/group_service.dart';
import '../../data/models/group_session.dart';
import '../../data/models/session_rating.dart';
import '../../data/models/session_photo.dart';
import '../../../../services/auth_service.dart';

class SessionDetailPage extends StatefulWidget {
  final int sessionId;
  final bool isAdmin;

  const SessionDetailPage({
    required this.sessionId,
    required this.isAdmin,
    super.key,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> with SingleTickerProviderStateMixin {
  final GroupService _groupService = GroupService();
  final ImagePicker _imagePicker = ImagePicker();
  late TabController _tabController;

  GroupSession? _session;
  List<SessionRating> _ratings = [];
  List<SessionPhoto> _photos = [];
  Map<String, dynamic> _averageRating = {};
  SessionRating? _myRating;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final session = await _groupService.getSession(widget.sessionId);
      final ratings = await _groupService.getSessionRatings(widget.sessionId);
      final photos = await _groupService.getSessionPhotos(widget.sessionId);
      final avgRating = await _groupService.getSessionAverageRating(widget.sessionId);
      final myRating = await _groupService.getUserRating(widget.sessionId, AuthService.username);

      setState(() {
        _session = session;
        _ratings = ratings;
        _photos = photos;
        _averageRating = avgRating;
        _myRating = myRating;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _markAsCompleted() async {
    final success = await _groupService.markSessionCompleted(
      widget.sessionId,
      AuthService.username,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión marcada como completada')),
      );
      _loadData();
    }
  }

  Future<void> _showRatingDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _RatingDialog(
        sessionId: widget.sessionId,
        existingRating: _myRating,
        onRated: _loadData,
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (image != null && mounted) {
      final caption = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Añadir descripción'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Descripción de la foto (opcional)',
              ),
              maxLines: 2,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Subir'),
              ),
            ],
          );
        },
      );

      if (caption != null) {
        final success = await _groupService.addPhoto(
          sessionId: widget.sessionId,
          username: AuthService.username,
          photoPath: image.path,
          caption: caption.isEmpty ? null : caption,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto subida exitosamente')),
          );
          _loadData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Sesión no encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_session!.escapeRoomName),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
        actions: [
          if (!_session!.isCompleted && widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Marcar como completada',
              onPressed: _markAsCompleted,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Valoraciones'),
            Tab(icon: Icon(Icons.photo), text: 'Fotos'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSessionHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRatingsTab(),
                _buildPhotosTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _session!.isCompleted
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _showRatingDialog();
                } else {
                  _uploadPhoto();
                }
              },
              icon: Icon(_tabController.index == 0 ? Icons.rate_review : Icons.add_a_photo),
              label: Text(_tabController.index == 0 ? 'Valorar' : 'Subir Foto'),
            )
          : null,
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                _formatDate(_session!.scheduledDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const Spacer(),
              if (_session!.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPLETADO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
            ],
          ),
          if (_session!.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              _session!.notes!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          if (_ratings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text(
                  '${(_averageRating['average'] as double).toStringAsFixed(1)}/5.0',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_ratings.length} valoraciones)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingsTab() {
    if (!_session!.isCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sesión pendiente',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Las valoraciones estarán disponibles al completar la sesión',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_ratings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aún no hay valoraciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en valorar esta sesión',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _ratings.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final rating = _ratings[index];
        final isMyRating = rating.username == AuthService.username;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isMyRating ? 3 : 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isMyRating ? Colors.blue[700] : Colors.grey[400],
                      child: Text(
                        rating.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                rating.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (isMyRating) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '(Tú)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            _formatDate(rating.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${rating.overallRating}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (rating.review != null) ...[
                  const SizedBox(height: 12),
                  Text(rating.review!),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (rating.historiaRating != null)
                      _buildDetailChip('Historia', rating.historiaRating!),
                    if (rating.ambientacionRating != null)
                      _buildDetailChip('Ambientación', rating.ambientacionRating!),
                    if (rating.jugabilidadRating != null)
                      _buildDetailChip('Jugabilidad', rating.jugabilidadRating!),
                    if (rating.gameMasterRating != null)
                      _buildDetailChip('Game Master', rating.gameMasterRating!),
                    if (rating.miedoRating != null)
                      _buildDetailChip('Miedo', rating.miedoRating!),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(String label, int rating) {
    return Chip(
      label: Text('$label: $rating/5'),
      labelStyle: const TextStyle(fontSize: 11),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPhotosTab() {
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay fotos',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_session!.isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'Sube la primera foto del grupo',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return _buildPhotoCard(photo);
      },
    );
  }

  Widget _buildPhotoCard(SessionPhoto photo) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPhotoDetail(photo),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.file(
                File(photo.photoPath),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.username,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (photo.caption != null)
                    Text(
                      photo.caption!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(SessionPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(photo.username),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: Image.file(File(photo.photoPath)),
            ),
            if (photo.caption != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(photo.caption!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Dialog para valorar sesión
class _RatingDialog extends StatefulWidget {
  final int sessionId;
  final SessionRating? existingRating;
  final VoidCallback onRated;

  const _RatingDialog({
    required this.sessionId,
    this.existingRating,
    required this.onRated,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  final GroupService _groupService = GroupService();
  final _reviewController = TextEditingController();

  late int _overallRating;
  int? _historiaRating;
  int? _ambientacionRating;
  int? _jugabilidadRating;
  int? _gameMasterRating;
  int? _miedoRating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _overallRating = widget.existingRating?.overallRating ?? 3;
    _historiaRating = widget.existingRating?.historiaRating;
    _ambientacionRating = widget.existingRating?.ambientacionRating;
    _jugabilidadRating = widget.existingRating?.jugabilidadRating;
    _gameMasterRating = widget.existingRating?.gameMasterRating;
    _miedoRating = widget.existingRating?.miedoRating;
    _reviewController.text = widget.existingRating?.review ?? '';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    final success = await _groupService.rateSession(
      sessionId: widget.sessionId,
      username: AuthService.username,
      overallRating: _overallRating,
      historiaRating: _historiaRating,
      ambientacionRating: _ambientacionRating,
      jugabilidadRating: _jugabilidadRating,
      gameMasterRating: _gameMasterRating,
      miedoRating: _miedoRating,
      review: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      widget.onRated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valoración guardada')),
      );
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar valoración')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(widget.existingRating == null ? 'Valorar Sesión' : 'Editar Valoración'),
              automaticallyImplyLeading: false,
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: [
                  const Text(
                    'Valoración general',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildRatingSelector(_overallRating, (value) {
                    setState(() => _overallRating = value);
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Valoraciones detalladas (opcional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedRating('Historia', _historiaRating, (value) {
                    setState(() => _historiaRating = value);
                  }),
                  _buildDetailedRating('Ambientación', _ambientacionRating, (value) {
                    setState(() => _ambientacionRating = value);
                  }),
                  _buildDetailedRating('Jugabilidad', _jugabilidadRating, (value) {
                    setState(() => _jugabilidadRating = value);
                  }),
                  _buildDetailedRating('Game Master', _gameMasterRating, (value) {
                    setState(() => _gameMasterRating = value);
                  }),
                  _buildDetailedRating('Nivel de miedo', _miedoRating, (value) {
                    setState(() => _miedoRating = value);
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Comentario (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector(int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < value ? Icons.star : Icons.star_border,
            color: Colors.amber[700],
            size: 32,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }

  Widget _buildDetailedRating(String label, int? value, ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          ...List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                value != null && index < value ? Icons.star : Icons.star_border,
                color: Colors.amber[700],
                size: 20,
              ),
              onPressed: () => onChanged(index + 1),
              visualDensity: VisualDensity.compact,
            );
          }),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () => onChanged(null),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
