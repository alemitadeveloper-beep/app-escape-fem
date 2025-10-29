import 'package:flutter/material.dart';

/// Colores de la aplicación centralizados
class AppColors {
  // Colores principales
  static const Color appBarBackground = Color(0xFF000D17);
  static const Color primaryDark = Color(0xFF001F54);
  static const Color playedBadge = Color(0xFF015526);

  // Colores de género
  static const Color genreTerror = Colors.deepPurple;
  static const Color genreAventura = Colors.green;
  static const Color genreInvestigacion = Colors.blueGrey;
  static const Color genreAccion = Colors.redAccent;
  static const Color genreFantasia = Colors.indigo;
  static const Color genreHumor = Color(0xffe6a008);
  static const Color genreMisterio = Color(0xff831702);
  static const Color genreSobrenatural = Color(0xff0509e1);
  static const Color genreFamiliar = Colors.blue;

  // Colores de UI
  static const Color cardBackground = Colors.white;
  static Color cardBorder = Colors.blue.shade100;
  static Color textPrimary = Colors.blueGrey.shade900;
  static Color textSecondary = Colors.blueGrey.shade700;
  static Color iconDefault = Colors.blueGrey;

  // Ratings
  static Color starActive = Colors.cyan.shade300;
  static Color starInactive = Colors.blue.shade100;
}
