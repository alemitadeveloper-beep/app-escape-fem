import '../../data/models/word.dart';
import '../../../../core/utils/rating_utils.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/genre_utils.dart';

/// Servicio de lógica de negocio para filtrado de escape rooms
class FilterService {
  /// Filtra una lista de escape rooms según criterios múltiples
  List<Word> filterWords({
    required List<Word> words,
    Set<String>? selectedGenres,
    String? selectedProvincia,
    double minRating = 0.0,
    double maxRating = 10.0,
    String? searchQuery,
  }) {
    return words.where((word) {
      // Filtro por género
      if (selectedGenres != null && selectedGenres.isNotEmpty) {
        final wordGenres = GenreUtils.parseGenres(word.genero);
        final matchesGenre = wordGenres.any((g) => selectedGenres.contains(g));
        if (!matchesGenre) return false;
      }

      // Filtro por provincia
      if (selectedProvincia != null) {
        final ubicacionData = LocationUtils.parseUbicacion(word.ubicacion);
        if (ubicacionData['provincia'] != selectedProvincia) return false;
      }

      // Filtro por rating
      final rating = RatingUtils.parsePuntuacion(word.puntuacion);
      if (rating < minRating || rating > maxRating) return false;

      // Filtro por búsqueda de texto
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final ubicacionData = LocationUtils.parseUbicacion(word.ubicacion);
        final ciudad = ubicacionData['ciudad'] ?? '';
        final provincia = ubicacionData['provincia'] ?? '';

        final matchesText = word.text.toLowerCase().contains(query) ||
            word.genero.toLowerCase().contains(query) ||
            word.ubicacion.toLowerCase().contains(query) ||
            provincia.toLowerCase().contains(query) ||
            ciudad.toLowerCase().contains(query) ||
            word.web.toLowerCase().contains(query);

        if (!matchesText) return false;
      }

      return true;
    }).toList();
  }

  /// Extrae todos los géneros únicos de una lista de escape rooms
  List<String> extractUniqueGenres(List<Word> words) {
    final genresSet = words
        .expand((w) => GenreUtils.parseGenres(w.genero))
        .toSet();
    final genres = genresSet.toList()..sort();
    return genres;
  }

  /// Extrae todas las provincias únicas de una lista de escape rooms
  List<String> extractUniqueProvincias(List<Word> words) {
    final provinciasSet = words
        .map((w) => LocationUtils.parseUbicacion(w.ubicacion)['provincia']!)
        .where((p) => p.isNotEmpty)
        .toSet();
    final provincias = provinciasSet.toList()..sort();
    return provincias;
  }
}
