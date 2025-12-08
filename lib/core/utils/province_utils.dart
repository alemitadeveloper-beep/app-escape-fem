/// Utilidades para determinar la provincia desde coordenadas geográficas
class ProvinceUtils {
  /// Mapa de provincias españolas con sus límites aproximados (lat, lon)
  static const Map<String, Map<String, double>> _provinceBounds = {
    // Andalucía
    'Almería': {'minLat': 36.8, 'maxLat': 37.6, 'minLon': -3.0, 'maxLon': -1.6},
    'Cádiz': {'minLat': 36.0, 'maxLat': 36.9, 'minLon': -6.4, 'maxLon': -5.3},
    'Córdoba': {'minLat': 37.3, 'maxLat': 38.5, 'minLon': -5.5, 'maxLon': -4.2},
    'Granada': {'minLat': 36.7, 'maxLat': 37.6, 'minLon': -4.0, 'maxLon': -2.4},
    'Huelva': {'minLat': 37.1, 'maxLat': 38.0, 'minLon': -7.5, 'maxLon': -6.2},
    'Jaén': {'minLat': 37.5, 'maxLat': 38.5, 'minLon': -4.0, 'maxLon': -2.6},
    'Málaga': {'minLat': 36.4, 'maxLat': 37.2, 'minLon': -5.6, 'maxLon': -3.8},
    'Sevilla': {'minLat': 36.9, 'maxLat': 38.0, 'minLon': -6.5, 'maxLon': -4.8},

    // Aragón
    'Huesca': {'minLat': 41.6, 'maxLat': 42.8, 'minLon': -1.0, 'maxLon': 0.8},
    'Teruel': {'minLat': 40.0, 'maxLat': 41.2, 'minLon': -2.0, 'maxLon': -0.2},
    'Zaragoza': {'minLat': 40.8, 'maxLat': 42.3, 'minLon': -2.0, 'maxLon': -0.2},

    // Asturias
    'Asturias': {'minLat': 42.9, 'maxLat': 43.7, 'minLon': -7.2, 'maxLon': -4.5},

    // Islas Baleares
    'Baleares': {'minLat': 38.6, 'maxLat': 40.1, 'minLon': 1.2, 'maxLon': 4.3},

    // Canarias
    'Las Palmas': {'minLat': 27.6, 'maxLat': 29.5, 'minLon': -18.2, 'maxLon': -13.4},
    'Santa Cruz de Tenerife': {'minLat': 27.6, 'maxLat': 29.4, 'minLon': -18.2, 'maxLon': -13.4},

    // Cantabria
    'Cantabria': {'minLat': 42.8, 'maxLat': 43.5, 'minLon': -4.8, 'maxLon': -3.2},

    // Castilla y León
    'Ávila': {'minLat': 40.1, 'maxLat': 41.0, 'minLon': -5.9, 'maxLon': -4.4},
    'Burgos': {'minLat': 41.6, 'maxLat': 43.2, 'minLon': -4.2, 'maxLon': -2.5},
    'León': {'minLat': 42.1, 'maxLat': 43.2, 'minLon': -7.1, 'maxLon': -4.8},
    'Palencia': {'minLat': 41.9, 'maxLat': 43.0, 'minLon': -5.0, 'maxLon': -3.9},
    'Salamanca': {'minLat': 40.3, 'maxLat': 41.3, 'minLon': -7.1, 'maxLon': -5.4},
    'Segovia': {'minLat': 40.8, 'maxLat': 41.5, 'minLon': -4.6, 'maxLon': -3.4},
    'Soria': {'minLat': 41.2, 'maxLat': 42.2, 'minLon': -3.5, 'maxLon': -1.7},
    'Valladolid': {'minLat': 41.3, 'maxLat': 42.3, 'minLon': -5.6, 'maxLon': -4.0},
    'Zamora': {'minLat': 41.2, 'maxLat': 42.3, 'minLon': -6.8, 'maxLon': -5.2},

    // Castilla-La Mancha
    'Albacete': {'minLat': 38.4, 'maxLat': 39.7, 'minLon': -2.9, 'maxLon': -0.9},
    'Ciudad Real': {'minLat': 38.3, 'maxLat': 39.5, 'minLon': -5.0, 'maxLon': -2.7},
    'Cuenca': {'minLat': 39.5, 'maxLat': 40.9, 'minLon': -3.2, 'maxLon': -1.4},
    'Guadalajara': {'minLat': 40.3, 'maxLat': 41.3, 'minLon': -3.5, 'maxLon': -1.6},
    'Toledo': {'minLat': 39.3, 'maxLat': 40.3, 'minLon': -5.4, 'maxLon': -3.2},

    // Cataluña
    'Barcelona': {'minLat': 41.2, 'maxLat': 42.0, 'minLon': 1.5, 'maxLon': 2.8},
    'Girona': {'minLat': 41.8, 'maxLat': 42.5, 'minLon': 2.1, 'maxLon': 3.3},
    'Lleida': {'minLat': 41.3, 'maxLat': 42.8, 'minLon': 0.2, 'maxLon': 1.7},
    'Tarragona': {'minLat': 40.5, 'maxLat': 41.5, 'minLon': 0.2, 'maxLon': 1.5},

    // Comunidad Valenciana
    'Alicante': {'minLat': 37.8, 'maxLat': 38.9, 'minLon': -1.3, 'maxLon': 0.0},
    'Castellón': {'minLat': 39.8, 'maxLat': 40.8, 'minLon': -0.8, 'maxLon': 0.5},
    'Valencia': {'minLat': 38.9, 'maxLat': 40.1, 'minLon': -1.5, 'maxLon': -0.1},

    // Extremadura
    'Badajoz': {'minLat': 37.9, 'maxLat': 39.5, 'minLon': -7.6, 'maxLon': -4.8},
    'Cáceres': {'minLat': 39.2, 'maxLat': 40.5, 'minLon': -7.3, 'maxLon': -5.0},

    // Galicia
    'A Coruña': {'minLat': 42.6, 'maxLat': 43.8, 'minLon': -9.3, 'maxLon': -7.7},
    'Lugo': {'minLat': 42.3, 'maxLat': 43.8, 'minLon': -7.9, 'maxLon': -6.7},
    'Ourense': {'minLat': 41.8, 'maxLat': 42.8, 'minLon': -8.4, 'maxLon': -6.8},
    'Pontevedra': {'minLat': 42.0, 'maxLat': 42.9, 'minLon': -9.0, 'maxLon': -7.9},

    // La Rioja
    'La Rioja': {'minLat': 42.0, 'maxLat': 42.6, 'minLon': -3.0, 'maxLon': -1.8},

    // Madrid
    'Madrid': {'minLat': 40.0, 'maxLat': 41.2, 'minLon': -4.6, 'maxLon': -3.1},

    // Murcia
    'Murcia': {'minLat': 37.4, 'maxLat': 38.8, 'minLon': -2.3, 'maxLon': -0.7},

    // Navarra
    'Navarra': {'minLat': 42.0, 'maxLat': 43.3, 'minLon': -2.4, 'maxLon': -0.8},

    // País Vasco
    'Álava': {'minLat': 42.4, 'maxLat': 43.1, 'minLon': -3.2, 'maxLon': -2.3},
    'Guipúzcoa': {'minLat': 42.9, 'maxLat': 43.4, 'minLon': -2.5, 'maxLon': -1.7},
    'Vizcaya': {'minLat': 42.8, 'maxLat': 43.4, 'minLon': -3.5, 'maxLon': -2.4},
  };

  /// Centros aproximados de cada provincia (para cálculo de distancia)
  static const Map<String, Map<String, double>> _provinceCenter = {
    'Almería': {'lat': 37.2, 'lon': -2.3},
    'Cádiz': {'lat': 36.5, 'lon': -6.0},
    'Córdoba': {'lat': 37.9, 'lon': -4.8},
    'Granada': {'lat': 37.2, 'lon': -3.6},
    'Huelva': {'lat': 37.5, 'lon': -6.9},
    'Jaén': {'lat': 37.8, 'lon': -3.8},
    'Málaga': {'lat': 36.7, 'lon': -4.4},
    'Sevilla': {'lat': 37.4, 'lon': -5.9},
    'Huesca': {'lat': 42.1, 'lon': -0.4},
    'Teruel': {'lat': 40.3, 'lon': -1.1},
    'Zaragoza': {'lat': 41.7, 'lon': -0.9},
    'Asturias': {'lat': 43.4, 'lon': -5.8},
    'Baleares': {'lat': 39.6, 'lon': 2.6},
    'Las Palmas': {'lat': 28.1, 'lon': -15.4},
    'Santa Cruz de Tenerife': {'lat': 28.5, 'lon': -16.3},
    'Cantabria': {'lat': 43.2, 'lon': -4.0},
    'Ávila': {'lat': 40.7, 'lon': -4.7},
    'Burgos': {'lat': 42.3, 'lon': -3.7},
    'León': {'lat': 42.6, 'lon': -5.6},
    'Palencia': {'lat': 42.0, 'lon': -4.5},
    'Salamanca': {'lat': 40.9, 'lon': -5.7},
    'Segovia': {'lat': 41.0, 'lon': -4.1},
    'Soria': {'lat': 41.8, 'lon': -2.5},
    'Valladolid': {'lat': 41.7, 'lon': -4.7},
    'Zamora': {'lat': 41.5, 'lon': -5.7},
    'Albacete': {'lat': 39.0, 'lon': -1.9},
    'Ciudad Real': {'lat': 38.9, 'lon': -3.9},
    'Cuenca': {'lat': 40.1, 'lon': -2.1},
    'Guadalajara': {'lat': 40.6, 'lon': -3.2},
    'Toledo': {'lat': 39.9, 'lon': -4.0},
    'Barcelona': {'lat': 41.4, 'lon': 2.2},
    'Girona': {'lat': 42.0, 'lon': 2.8},
    'Lleida': {'lat': 41.6, 'lon': 0.6},
    'Tarragona': {'lat': 41.1, 'lon': 1.2},
    'Alicante': {'lat': 38.3, 'lon': -0.5},
    'Castellón': {'lat': 40.0, 'lon': -0.0},
    'Valencia': {'lat': 39.5, 'lon': -0.4},
    'Badajoz': {'lat': 38.9, 'lon': -6.3},
    'Cáceres': {'lat': 39.5, 'lon': -6.4},
    'A Coruña': {'lat': 43.4, 'lon': -8.4},
    'Lugo': {'lat': 43.0, 'lon': -7.6},
    'Ourense': {'lat': 42.3, 'lon': -7.9},
    'Pontevedra': {'lat': 42.4, 'lon': -8.6},
    'La Rioja': {'lat': 42.3, 'lon': -2.4},
    'Madrid': {'lat': 40.4, 'lon': -3.7},
    'Murcia': {'lat': 37.9, 'lon': -1.1},
    'Navarra': {'lat': 42.8, 'lon': -1.6},
    'Álava': {'lat': 42.8, 'lon': -2.7},
    'Guipúzcoa': {'lat': 43.2, 'lon': -2.0},
    'Vizcaya': {'lat': 43.2, 'lon': -2.9},
  };

  /// Determina la provincia basándose en coordenadas geográficas
  static String? getProvinciaFromCoordinates(double lat, double lon) {
    // Primero intenta match exacto dentro de los límites
    for (final entry in _provinceBounds.entries) {
      final bounds = entry.value;
      if (lat >= bounds['minLat']! &&
          lat <= bounds['maxLat']! &&
          lon >= bounds['minLon']! &&
          lon <= bounds['maxLon']!) {
        return entry.key;
      }
    }

    // Si no hay match exacto, encuentra la provincia más cercana
    String? closestProvincia;
    double minDistance = double.infinity;

    for (final entry in _provinceCenter.entries) {
      final center = entry.value;
      final distance = _calculateDistance(
        lat,
        lon,
        center['lat']!,
        center['lon']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestProvincia = entry.key;
      }
    }

    return closestProvincia;
  }

  /// Calcula la distancia euclidiana aproximada entre dos puntos
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return dLat * dLat + dLon * dLon; // Distancia cuadrada (suficiente para comparar)
  }

  /// Extrae la provincia desde el texto de ubicación
  static String? extractProvinciaFromUbicacion(String? ubicacion) {
    if (ubicacion == null || ubicacion.isEmpty) return null;

    final normalized = ubicacion.toLowerCase();

    // Busca coincidencias directas en el texto
    for (final provincia in _provinceCenter.keys) {
      if (normalized.contains(provincia.toLowerCase())) {
        return provincia;
      }
    }

    // Busca también variantes comunes
    final variantes = {
      'coruña': 'A Coruña',
      'alava': 'Álava',
      'guipuzcoa': 'Guipúzcoa',
      'vizcaya': 'Vizcaya',
      'bizkaia': 'Vizcaya',
      'gipuzkoa': 'Guipúzcoa',
      'araba': 'Álava',
      'rioja': 'La Rioja',
      'baleares': 'Baleares',
      'mallorca': 'Baleares',
      'menorca': 'Baleares',
      'ibiza': 'Baleares',
      'formentera': 'Baleares',
      'tenerife': 'Santa Cruz de Tenerife',
      'gomera': 'Santa Cruz de Tenerife',
      'hierro': 'Santa Cruz de Tenerife',
      'palma': 'Santa Cruz de Tenerife',
      'gran canaria': 'Las Palmas',
      'lanzarote': 'Las Palmas',
      'fuerteventura': 'Las Palmas',
    };

    for (final entry in variantes.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Obtiene la provincia combinando coordenadas y ubicación textual
  static String? getProvincia(double? lat, double? lon, String? ubicacion) {
    // Primero intenta desde coordenadas si están disponibles
    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      final fromCoords = getProvinciaFromCoordinates(lat, lon);
      if (fromCoords != null) return fromCoords;
    }

    // Si no hay coordenadas o no se encontró, intenta desde texto
    return extractProvinciaFromUbicacion(ubicacion);
  }

  /// Lista de todas las provincias disponibles
  static List<String> getAllProvincias() {
    return _provinceCenter.keys.toList()..sort();
  }
}
