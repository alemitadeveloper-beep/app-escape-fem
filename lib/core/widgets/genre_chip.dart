import 'package:flutter/material.dart';
import '../utils/genre_utils.dart';

/// Widget reutilizable para mostrar un chip de género con color
class GenreChip extends StatelessWidget {
  final String genre;
  final bool filled;

  const GenreChip({
    required this.genre,
    this.filled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = GenreUtils.getGenreColor(genre);

    return Chip(
      label: Text(
        genre,
        style: TextStyle(
          color: filled ? Colors.white : color,
        ),
      ),
      backgroundColor: filled ? color : color.withAlpha(40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withAlpha(120)),
      ),
    );
  }
}

/// Widget para mostrar múltiples géneros
class GenreChipList extends StatelessWidget {
  final List<String> genres;
  final bool filled;

  const GenreChipList({
    required this.genres,
    this.filled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: genres
          .map((genre) => GenreChip(genre: genre, filled: filled))
          .toList(),
    );
  }
}
