import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/models/word.dart';
import '../../data/repositories/escape_room_repository.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/utils/rating_utils.dart';

/// Diálogo para editar la reseña de un escape room jugado
class ReviewDialog extends StatefulWidget {
  final Word word;
  final VoidCallback onReviewSaved;

  const ReviewDialog({
    required this.word,
    required this.onReviewSaved,
    super.key,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final EscapeRoomRepository _repository = EscapeRoomRepository();

  late DateTime _selectedDate;
  late TextEditingController _commentController;
  File? _selectedImage;

  late int _historiaRating;
  late int _ambientacionRating;
  late int _jugabilidadRating;
  late int _gameMasterRating;
  late int _miedoRating;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.word.datePlayed ?? DateTime.now();
    _commentController = TextEditingController(text: widget.word.review ?? '');
    _selectedImage = widget.word.photoPath != null
        ? File(widget.word.photoPath!)
        : null;

    _historiaRating = widget.word.historiaRating ?? 5;
    _ambientacionRating = widget.word.ambientacionRating ?? 5;
    _jugabilidadRating = widget.word.jugabilidadRating ?? 5;
    _gameMasterRating = widget.word.gameMasterRating ?? 5;
    _miedoRating = widget.word.miedoRating ?? 5;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = p.basename(image.path);
    final imagePath = p.join(directory.path, name);
    final newImage = await image.copy(imagePath);
    return newImage.path;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedPath = await _saveImagePermanently(File(pickedFile.path));
      setState(() {
        _selectedImage = File(savedPath);
      });
    }
  }

  Future<void> _selectDate(BuildContext dialogContext) async {
    final date = await showDatePicker(
      context: dialogContext,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveReview(BuildContext dialogContext) async {
    final navigator = Navigator.of(dialogContext);
    await _repository.updateReview(
      id: widget.word.id!,
      datePlayed: _selectedDate,
      personalRating: widget.word.personalRating ?? 0,
      review: _commentController.text.trim(),
      photoPath: _selectedImage?.path,
      historiaRating: _historiaRating,
      ambientacionRating: _ambientacionRating,
      jugabilidadRating: _jugabilidadRating,
      gameMasterRating: _gameMasterRating,
      miedoRating: _miedoRating,
    );

    if (!mounted) return;
    widget.onReviewSaved();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = RatingUtils.calculateAverageRating(widget.word);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        'Reseña: ${widget.word.text}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF001F54),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fecha
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, color: Colors.blueGrey),
              label: Text(
                'Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              onPressed: () => _selectDate(context),
            ),
            const SizedBox(height: 8),

            // Rating promedio con estrellas
            StarRating(rating: averageRating * 2, starSize: 24),
            const SizedBox(height: 8),

            // Sliders de rating
            _buildRatingSlider(
              'Historia',
              _historiaRating,
              (val) => setState(() => _historiaRating = val.toInt()),
            ),
            _buildRatingSlider(
              'Ambientación',
              _ambientacionRating,
              (val) => setState(() => _ambientacionRating = val.toInt()),
            ),
            _buildRatingSlider(
              'Jugabilidad',
              _jugabilidadRating,
              (val) => setState(() => _jugabilidadRating = val.toInt()),
            ),
            _buildRatingSlider(
              'GameMaster',
              _gameMasterRating,
              (val) => setState(() => _gameMasterRating = val.toInt()),
            ),
            _buildRatingSlider(
              'Miedo',
              _miedoRating,
              (val) => setState(() => _miedoRating = val.toInt()),
            ),

            // Comentario
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comentario',
                labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade100),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),

            // Botón seleccionar imagen
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo, color: Color(0xFF001F54)),
              label: const Text('Seleccionar imagen',
                  style: TextStyle(color: Color(0xFF001F54))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),

            // Preview de imagen
            if (_selectedImage?.existsSync() == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, height: 100, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar',
              style: TextStyle(color: Colors.blueGrey.shade700)),
        ),
        ElevatedButton(
          onPressed: () => _saveReview(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            elevation: 0,
          ),
          child: const Text('Guardar',
              style: TextStyle(color: Color(0xFF001F54))),
        ),
      ],
    );
  }

  Widget _buildRatingSlider(
    String label,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: value.toString(),
          onChanged: onChanged,
          activeColor: Colors.blue.shade700,
          inactiveColor: Colors.blue.shade100,
        ),
      ],
    );
  }
}
