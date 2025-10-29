import 'package:flutter/material.dart';

/// Utilidad para obtener colores por género de escape room
class GenreUtils {
  static Color getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'terror':
        return Colors.deepPurple;
      case 'aventura':
        return Colors.green;
      case 'investigación':
        return Colors.blueGrey;
      case 'acción':
        return Colors.redAccent;
      case 'fantasía':
        return Colors.indigo;
      case 'humor':
        return const Color(0xffe6a008);
      case 'misterio':
        return const Color(0xff831702);
      case 'sobrenatural':
        return const Color(0xff0509e1);
      case 'familiar':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Convierte un string de géneros separados por '/' en una lista limpia
  static List<String> parseGenres(String genreString) {
    return genreString
        .split('/')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
  }
}
