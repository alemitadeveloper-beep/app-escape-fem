import 'package:flutter/material.dart';

/// Constantes de la aplicación centralizadas
class AppConstants {
  // Colores principales
  static const Color primaryDark = Color(0xFF000D17);
  static const Color primaryBlue = Color(0xFF001F54);
  static const Color lightBlue = Colors.lightBlue;
  static const Color backgroundWhite = Colors.white;

  // Colores de rating
  static const Color starActive = Colors.cyan;
  static const Color starInactive = Colors.blue;

  // Configuración de rating
  static const double minRating = 0.0;
  static const double maxRating = 10.0;
  static const int ratingDivisions = 20;
  static const int maxStars = 5;

  // Tamaños
  static const double cardElevation = 2.0;
  static const double borderRadius = 10.0;
  static const double chipBorderRadius = 20.0;

  // Strings
  static const String appTitle = 'Escape Room App';
  static const String noElementsMessage = 'No hay elementos para mostrar.';
  static const String invalidUrlMessage = 'URL no válida';
  static const String cannotOpenLinkMessage = 'No se pudo abrir el enlace';

  // Mapeo de ciudades a provincias
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

  // Colores por género
  static const Map<String, Color> genreColors = {
    'terror': Colors.deepPurple,
    'aventura': Colors.green,
    'investigación': Colors.blueGrey,
    'acción': Colors.redAccent,
    'fantasía': Colors.indigo,
    'humor': Color(0xffe6a008),
    'misterio': Color(0xff831702),
    'sobrenatural': Color(0xff0509e1),
    'familiar': Colors.blue,
  };

  static const Color defaultGenreColor = Colors.grey;
}
