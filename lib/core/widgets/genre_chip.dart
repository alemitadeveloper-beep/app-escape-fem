import 'package:flutter/material.dart';
import '../utils/genre_utils.dart';

/// Widget reutilizable para mostrar un chip de género con icono y nombre
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
    final imagePath = GenreUtils.getGenreImagePath(genre);
    final icon = GenreUtils.getGenreIcon(genre);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(20) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Usar imagen si está disponible, sino usar icono
          imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 16,
                  height: 16,
                  color: color,
                  errorBuilder: (context, error, stackTrace) {
                    // Si la imagen no existe, usar el icono como fallback
                    return Icon(
                      icon,
                      size: 16,
                      color: color,
                    );
                  },
                )
              : Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
          const SizedBox(width: 5),
          Text(
            genre,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
