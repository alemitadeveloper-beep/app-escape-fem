import 'package:flutter/material.dart';

/// Utilidad para obtener colores por género de escape room
class GenreUtils {
  static Color getGenreColor(String genre) {
    // Normalizar el género: tomar solo el primer género si es combinado
    final normalizedGenre = _normalizeGenre(genre);

    switch (normalizedGenre) {
      case 'terror':
        return const Color(0xFF4A148C); // Púrpura oscuro
      case 'aventura':
        return const Color(0xFF2E7D32); // Verde bosque
      case 'investigación':
        return const Color(0xFF455A64); // Gris azulado
      case 'acción':
        return const Color(0xFFD32F2F); // Rojo intenso
      case 'fantasía':
        return const Color(0xFF5E35B1); // Índigo profundo
      case 'humor':
        return const Color(0xFFF57C00); // Naranja alegre
      case 'misterio':
        return const Color(0xFF6D4C41); // Marrón misterioso
      case 'sobrenatural':
        return const Color(0xFF283593); // Azul índigo
      case 'familiar':
      case 'infantil':
        return const Color(0xFF1976D2); // Azul cálido
      case 'thriller':
        return const Color(0xFFC62828); // Rojo oscuro
      case 'robo':
        return const Color(0xFF388E3C); // Verde dinero
      case 'religioso':
        return const Color(0xFF7B1FA2); // Púrpura religioso
      case 'vampiros':
        return const Color(0xFF880E4F); // Granate sangre
      case 'histórico':
        return const Color(0xFF795548); // Marrón antiguo
      case 'ciencia ficción':
      case 'ciencia':
      case 'sci-fi':
        return const Color(0xFF0097A7); // Cian tecnológico
      case 'zombies':
        return const Color(0xFF558B2F); // Verde zombie
      case 'medieval':
        return const Color(0xFF5D4037); // Marrón medieval
      case 'piratas':
        return const Color(0xFF00796B); // Turquesa mar
      case 'magia':
        return const Color(0xFF8E24AA); // Púrpura mágico
      case 'espionaje':
        return const Color(0xFF37474F); // Gris oscuro secreto
      case 'militar':
        return const Color(0xFF616161); // Gris militar
      case 'cyberpunk':
        return const Color(0xFFE91E63); // Rosa neón
      case 'apocalipsis':
        return const Color(0xFFBF360C); // Naranja apocalíptico
      case 'arqueología':
        return const Color(0xFFD4A574); // Beige arena
      case 'egipto':
        return const Color(0xFFD4AF37); // Dorado egipcio
      case 'submarino':
        return const Color(0xFF006064); // Azul océano profundo
      case 'supervivencia':
        return const Color(0xFF827717); // Verde oliva supervivencia
      case 'conspiración':
        return const Color(0xFF263238); // Gris casi negro
      case 'miedo':
        return const Color(0xFF311B92); // Púrpura profundo
      case 'prisión':
        return const Color(0xFF424242); // Gris oscuro
      case 'fantasmas':
        return const Color(0xFF9FA8DA); // Azul grisáceo etéreo
      case 'virtual':
        return const Color(0xFF00BCD4); // Cian digital
      case 'adulto':
        return const Color(0xFF8D6E63); // Marrón maduro
      default:
        return const Color(0xFF757575); // Gris neutral
    }
  }

  /// Obtiene la ruta de la imagen asociada a un género
  /// Retorna null si no hay imagen disponible (usará icono por defecto)
  static String? getGenreImagePath(String genre) {
    final normalizedGenre = _normalizeGenre(genre);

    switch (normalizedGenre) {
      case 'terror':
        return 'assets/genres/terror.png';
      case 'aventura':
        return 'assets/genres/aventura.png';
      case 'investigación':
        return 'assets/genres/investigacion.png';
      case 'acción':
        return 'assets/genres/accion.png';
      case 'fantasía':
        return 'assets/genres/fantasia.png';
      case 'humor':
        return 'assets/genres/humor.png';
      case 'misterio':
        return 'assets/genres/misterio.png';
      case 'sobrenatural':
        return 'assets/genres/sobrenatural.png';
      case 'familiar':
      case 'infantil':
        return 'assets/genres/familiar.png';
      case 'thriller':
        return 'assets/genres/thriller.png';
      case 'robo':
        return 'assets/genres/robo.png';
      case 'religioso':
        return 'assets/genres/religioso.png';
      case 'vampiros':
        return 'assets/genres/vampiros.png';
      case 'histórico':
        return 'assets/genres/historico.png';
      case 'ciencia ficción':
      case 'ciencia':
      case 'sci-fi':
        return 'assets/genres/scifi.png';
      case 'zombies':
        return 'assets/genres/zombies.png';
      case 'medieval':
        return 'assets/genres/medieval.png';
      case 'piratas':
        return 'assets/genres/piratas.png';
      case 'magia':
        return 'assets/genres/magia.png';
      case 'espionaje':
        return 'assets/genres/espionaje.png';
      case 'militar':
        return 'assets/genres/militar.png';
      case 'cyberpunk':
        return 'assets/genres/cyberpunk.png';
      case 'apocalipsis':
        return 'assets/genres/apocalipsis.png';
      case 'arqueología':
        return 'assets/genres/arqueologia.png';
      case 'egipto':
        return 'assets/genres/egipto.png';
      case 'submarino':
        return 'assets/genres/submarino.png';
      case 'supervivencia':
        return 'assets/genres/supervivencia.png';
      case 'conspiración':
        return 'assets/genres/conspiracion.png';
      case 'miedo':
        return 'assets/genres/miedo.png';
      case 'prisión':
        return 'assets/genres/prision.png';
      case 'fantasmas':
        return 'assets/genres/fantasmas.png';
      case 'virtual':
        return 'assets/genres/virtual.png';
      case 'adulto':
        return 'assets/genres/adulto.png';
      default:
        return null;
    }
  }

  /// Obtiene el icono asociado a un género (fallback si no hay imagen)
  static IconData getGenreIcon(String genre) {
    // Normalizar el género: tomar solo el primer género si es combinado
    final normalizedGenre = _normalizeGenre(genre);

    switch (normalizedGenre) {
      case 'terror':
        return Icons.dark_mode;
      case 'aventura':
        return Icons.terrain;
      case 'investigación':
        return Icons.search;
      case 'acción':
        return Icons.local_fire_department;
      case 'fantasía':
        return Icons.stars;
      case 'humor':
        return Icons.sentiment_very_satisfied;
      case 'misterio':
        return Icons.fingerprint;
      case 'sobrenatural':
        return Icons.auto_fix_high;
      case 'familiar':
      case 'infantil':
        return Icons.family_restroom;
      case 'thriller':
        return Icons.flash_on;
      case 'robo':
        return Icons.savings;
      case 'religioso':
        return Icons.menu_book;
      case 'vampiros':
        return Icons.water_drop;
      case 'histórico':
        return Icons.history_edu;
      case 'ciencia ficción':
      case 'ciencia':
      case 'sci-fi':
        return Icons.rocket_launch;
      case 'zombies':
        return Icons.personal_injury;
      case 'medieval':
        return Icons.castle;
      case 'piratas':
        return Icons.sailing;
      case 'magia':
        return Icons.auto_awesome;
      case 'espionaje':
        return Icons.remove_red_eye;
      case 'militar':
        return Icons.military_tech;
      case 'cyberpunk':
        return Icons.memory;
      case 'apocalipsis':
        return Icons.warning;
      case 'arqueología':
        return Icons.explore;
      case 'egipto':
        return Icons.mosque;
      case 'submarino':
        return Icons.scuba_diving;
      case 'supervivencia':
        return Icons.eco;
      case 'conspiración':
        return Icons.layers;
      case 'miedo':
        return Icons.warning_amber;
      case 'prisión':
        return Icons.lock;
      case 'fantasmas':
        return Icons.blur_on;
      case 'virtual':
        return Icons.sports_esports;
      case 'adulto':
        return Icons.no_adult_content;
      default:
        return Icons.category;
    }
  }

  /// Normaliza un género extrayendo el primer género si está combinado
  static String _normalizeGenre(String genre) {
    // Si contiene coma, tomar el primer género
    if (genre.contains(',')) {
      genre = genre.split(',').first.trim();
    }

    return genre.toLowerCase().trim();
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
