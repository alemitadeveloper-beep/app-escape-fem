/// Utilidades para parseo y manejo de ubicaciones
class LocationUtils {
  /// Mapa de ciudades a provincias
  static const Map<String, String> ciudadesToProvincias = {
    'Benidorm': 'Alicante',
    'Madrid': 'Madrid',
    'Huesca': 'Huesca',
    'Gijón': 'Asturias',
    'Orihuela': 'Alicante',
    'Cáceres': 'Cáceres',
    'Córdoba': 'Córdoba',
    'Valencia': 'Valencia',
    'Barcelona': 'Barcelona',
    'Sevilla': 'Sevilla',
    'Zaragoza': 'Zaragoza',
    'Málaga': 'Málaga',
    'Murcia': 'Murcia',
    'Palma': 'Illes Balears',
    'Las Palmas de Gran Canaria': 'Las Palmas',
    'Bilbao': 'Bizkaia',
    'Alicante': 'Alicante',
    'Vigo': 'Pontevedra',
    'Granada': 'Granada',
    'Oviedo': 'Asturias',
    'Cartagena': 'Murcia',
    'A Coruña': 'A Coruña',
    'Vitoria-Gasteiz': 'Álava',
    'Albacete': 'Albacete',
    'Burgos': 'Burgos',
    'Salamanca': 'Salamanca',
    'Logroño': 'La Rioja',
    'Pamplona': 'Navarra',
    'Santander': 'Cantabria',
    'Castellón de la Plana': 'Castellón',
    'Almería': 'Almería',
    'La Rioja': 'La Rioja',
    'Valladolid': 'Valladolid',
    'Jaén': 'Jaén',
    'Huelva': 'Huelva',
    'Badajoz': 'Badajoz',
    'Lleida': 'Lleida',
    'Tarragona': 'Tarragona',
    'León': 'León',
    'Cádiz': 'Cádiz',
    'Ourense': 'Ourense',
    'Girona': 'Girona',
    'Lugo': 'Lugo',
    'Teruel': 'Teruel',
    'Soria': 'Soria',
    'Ávila': 'Ávila',
    'Cuenca': 'Cuenca',
    'Zamora': 'Zamora',
    'Segovia': 'Segovia',
    'Guadalajara': 'Guadalajara',
    'Toledo': 'Toledo',
    'Ciudad Real': 'Ciudad Real',
    'Pontevedra': 'Pontevedra',
  };

  /// Parsea una ubicación en formato "Ciudad, Provincia, etc"
  /// Retorna un mapa con 'provincia' y 'ciudad'
  static Map<String, String> parseUbicacion(String ubicacion) {
    String provincia = '';
    String ciudad = '';

    final parts = ubicacion.split(',').map((p) => p.trim()).toList();
    if (parts.isNotEmpty) ciudad = parts[0];

    final normalized = ubicacion.toLowerCase();
    for (final p in ciudadesToProvincias.values) {
      if (normalized.contains(p.toLowerCase())) {
        provincia = p;
        break;
      }
    }

    return {'provincia': provincia, 'ciudad': ciudad};
  }
}
