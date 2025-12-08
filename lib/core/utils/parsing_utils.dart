import 'dart:core';

/// Utilidades para parsear y limpiar datos de escape rooms
class ParsingUtils {
  /// Extrae el número mínimo y máximo de jugadores desde un string
  /// Ejemplos: "De 2 a 6 jugadores" -> (2, 6)
  ///           "2-4 jugadores" -> (2, 4)
  ///           "Hasta 6 jugadores" -> (1, 6)
  static Map<String, int?> parseJugadores(String? jugadores) {
    if (jugadores == null || jugadores.isEmpty) {
      return {'min': null, 'max': null};
    }

    final normalized = jugadores.toLowerCase().trim();

    // Patrones: "De X a Y", "X-Y", "X a Y"
    final patterns = [
      RegExp(r'de\s+(\d+)\s+a\s+(\d+)'),
      RegExp(r'(\d+)\s*-\s*(\d+)'),
      RegExp(r'(\d+)\s+a\s+(\d+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(normalized);
      if (match != null) {
        return {
          'min': int.tryParse(match.group(1)!),
          'max': int.tryParse(match.group(2)!),
        };
      }
    }

    // Patrón: "Hasta X" o "Máximo X"
    final maxPattern = RegExp(r'(?:hasta|m[aá]ximo)\s+(\d+)');
    final maxMatch = maxPattern.firstMatch(normalized);
    if (maxMatch != null) {
      return {
        'min': 1,
        'max': int.tryParse(maxMatch.group(1)!),
      };
    }

    // Patrón: "Mínimo X" o "Desde X"
    final minPattern = RegExp(r'(?:m[ií]nimo|desde)\s+(\d+)');
    final minMatch = minPattern.firstMatch(normalized);
    if (minMatch != null) {
      return {
        'min': int.tryParse(minMatch.group(1)!),
        'max': null,
      };
    }

    // Intenta extraer cualquier número
    final numberPattern = RegExp(r'\d+');
    final numbers = numberPattern.allMatches(normalized).toList();

    if (numbers.length >= 2) {
      return {
        'min': int.tryParse(numbers[0].group(0)!),
        'max': int.tryParse(numbers[1].group(0)!),
      };
    } else if (numbers.length == 1) {
      final num = int.tryParse(numbers[0].group(0)!);
      return {'min': num, 'max': num};
    }

    return {'min': null, 'max': null};
  }

  /// Normaliza el precio para mostrar
  /// "€ Desde 15€ por persona" -> "Desde 15€"
  /// "Desde 0€ por persona" -> null (gratis no es válido normalmente)
  static String? normalizePrecio(String? precio) {
    if (precio == null || precio.isEmpty) return null;

    var normalized = precio
        .replaceAll('€', '')
        .replaceAll('por persona', '')
        .replaceAll('persona', '')
        .trim();

    // Si es "Desde 0" o similar, devolver null
    if (normalized.contains('0') &&
        (normalized.startsWith('desde') || normalized.startsWith('0'))) {
      return null;
    }

    // Remueve símbolos extra
    normalized = normalized
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) return null;

    // Asegura que tenga el símbolo €
    if (!normalized.contains('€')) {
      normalized = '$normalized€';
    }

    return normalized;
  }

  /// Normaliza la duración
  /// "60 minutos" -> "60 min"
  /// "1 hora" -> "60 min"
  static String? normalizeDuracion(String? duracion) {
    if (duracion == null || duracion.isEmpty) return null;

    final normalized = duracion.toLowerCase().trim();

    // Extrae números
    final numberPattern = RegExp(r'(\d+)');
    final match = numberPattern.firstMatch(normalized);

    if (match == null) return null;

    final num = int.tryParse(match.group(1)!);
    if (num == null) return null;

    // Si menciona "hora" o "hour", convertir a minutos
    if (normalized.contains('hora') || normalized.contains('hour')) {
      return '${num * 60} min';
    }

    // Si ya está en minutos
    if (normalized.contains('min')) {
      return '$num min';
    }

    // Por defecto, asumir minutos
    return '$num min';
  }

  /// Limpia la descripción removiendo textos genéricos
  static String? cleanDescripcion(String? descripcion) {
    if (descripcion == null || descripcion.isEmpty) return null;

    final cleaned = descripcion.trim();

    // Lista de textos no válidos
    final invalidTexts = [
      'no disponible',
      'términos de uso',
      'página no encontrada',
      'oops',
      'error 404',
    ];

    final lowerCleaned = cleaned.toLowerCase();
    for (final invalid in invalidTexts) {
      if (lowerCleaned.contains(invalid)) {
        return null;
      }
    }

    // Si es muy corta, probablemente no es útil
    if (cleaned.length < 20) return null;

    return cleaned;
  }

  /// Valida si un nombre de escape room es válido
  static bool isValidNombre(String? nombre) {
    if (nombre == null || nombre.isEmpty) return false;

    final normalized = nombre.toLowerCase().trim();

    // Lista de nombres inválidos
    final invalidNames = [
      'no disponible',
      'oops',
      'página no encontrada',
      'error 404',
      'error',
      '404',
    ];

    for (final invalid in invalidNames) {
      if (normalized.contains(invalid)) {
        return false;
      }
    }

    // Debe tener al menos 3 caracteres
    return nombre.length >= 3;
  }

  /// Limpia el campo web
  static String? cleanWeb(String? web) {
    if (web == null || web.isEmpty) return null;

    final cleaned = web.trim();

    // Valores inválidos
    if (cleaned == '/' || cleaned == '#' || cleaned == 'No disponible') {
      return null;
    }

    return cleaned;
  }

  /// Limpia el campo genero
  static String? cleanGenero(String? genero) {
    if (genero == null || genero.isEmpty) return null;

    final cleaned = genero.trim();

    if (cleaned == 'No disponible' || cleaned.toLowerCase() == 'null') {
      return null;
    }

    return cleaned;
  }

  /// Extrae coordenadas válidas, devuelve null si son 0.0
  static double? cleanCoordinate(double? coord) {
    if (coord == null || coord == 0.0) return null;
    return coord;
  }

  /// Normaliza el texto removiendo espacios extra y capitalizando correctamente
  static String normalizeText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Extrae el código postal de una ubicación
  static String? extractCodigoPostal(String? ubicacion) {
    if (ubicacion == null || ubicacion.isEmpty) return null;

    // Patrón para código postal español (5 dígitos)
    final pattern = RegExp(r'\b(\d{5})\b');
    final match = pattern.firstMatch(ubicacion);

    return match?.group(1);
  }

  /// Limpia la ubicación removiendo código postal si es necesario
  static String cleanUbicacion(String? ubicacion) {
    if (ubicacion == null || ubicacion.isEmpty) return '';

    return ubicacion
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Valida si un email es válido
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return pattern.hasMatch(email);
  }

  /// Valida si un teléfono es válido (español)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remueve espacios y caracteres especiales
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Patrones válidos españoles: 9 dígitos, o +34 seguido de 9 dígitos
    final patterns = [
      RegExp(r'^\d{9}$'),
      RegExp(r'^\+34\d{9}$'),
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleaned));
  }

  /// Extrae el teléfono limpio
  static String? cleanPhone(String? phone) {
    if (phone == null || !isValidPhone(phone)) return null;

    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
