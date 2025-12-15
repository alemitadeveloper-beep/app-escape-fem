import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../utils/auth_helper.dart';
import '../../../../db/word_database.dart';
import '../../../../models/word.dart';

class CreateSessionPage extends StatefulWidget {
  final int groupId;

  const CreateSessionPage({required this.groupId, super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final GroupService _groupService = GroupService();
  final WordDatabase _wordDatabase = WordDatabase.instance;

  List<Word> _availableEscapeRooms = [];
  Word? _selectedEscapeRoom;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadEscapeRooms();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEscapeRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _wordDatabase.readAllWords();
      setState(() {
        _availableEscapeRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar escape rooms: $e')),
        );
      }
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate() || _selectedEscapeRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un escape room')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      await _groupService.createSession(
        groupId: widget.groupId,
        escapeRoomId: _selectedEscapeRoom!.id!,
        escapeRoomName: _selectedEscapeRoom!.text,
        scheduledDate: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        requestingUsername: AuthHelper.getCurrentUsername(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión creada exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear sesión: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Sesión'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona el Escape Room',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Word>(
                            value: _selectedEscapeRoom,
                            decoration: const InputDecoration(
                              labelText: 'Escape Room *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.room),
                            ),
                            items: _availableEscapeRooms.map((room) {
                              return DropdownMenuItem(
                                value: room,
                                child: Text(
                                  room.text,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedEscapeRoom = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona un escape room';
                              }
                              return null;
                            },
                          ),
                          if (_selectedEscapeRoom != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedEscapeRoom?.genero != null)
                                    Row(
                                      children: [
                                        Icon(Icons.category, size: 16, color: Colors.blue[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedEscapeRoom!.genero ?? '',
                                          style: TextStyle(color: Colors.blue[900]),
                                        ),
                                      ],
                                    ),
                                  if (_selectedEscapeRoom?.ubicacion != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.blue[700]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _selectedEscapeRoom!.ubicacion ?? '',
                                            style: TextStyle(color: Colors.blue[900]),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha y Hora',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha y hora programada *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _formatDateTime(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notas Adicionales',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notas (opcional)',
                              hintText: 'Punto de encuentro, hora de llegada, etc.',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear Sesión'),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} de ${months[date.month - 1]} ${date.year} a las $hour:$minute';
  }
}
