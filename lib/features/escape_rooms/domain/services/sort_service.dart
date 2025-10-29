import '../../data/models/word.dart';
import '../../../../core/utils/rating_utils.dart';
import '../../../../core/utils/location_utils.dart';

/// Tipos de ordenamiento disponibles
enum SortOrder {
  none,
  ratingAsc,
  ratingDesc,
  cityAsc,
  cityDesc,
  provinceCityAsc,
  provinceCityDesc,
}

/// Servicio de lógica de negocio para ordenamiento de escape rooms
class SortService {
  /// Ordena una lista de escape rooms según el criterio especificado
  List<Word> sortWords(List<Word> words, SortOrder sortOrder) {
    final result = List<Word>.from(words);

    switch (sortOrder) {
      case SortOrder.ratingAsc:
        result.sort((a, b) => RatingUtils.parsePuntuacion(a.puntuacion)
            .compareTo(RatingUtils.parsePuntuacion(b.puntuacion)));
        break;

      case SortOrder.ratingDesc:
        result.sort((a, b) => RatingUtils.parsePuntuacion(b.puntuacion)
            .compareTo(RatingUtils.parsePuntuacion(a.puntuacion)));
        break;

      case SortOrder.cityAsc:
        result.sort((a, b) {
          final ciudadA = LocationUtils.parseUbicacion(a.ubicacion)['ciudad'] ?? '';
          final ciudadB = LocationUtils.parseUbicacion(b.ubicacion)['ciudad'] ?? '';
          return ciudadA.compareTo(ciudadB);
        });
        break;

      case SortOrder.cityDesc:
        result.sort((a, b) {
          final ciudadA = LocationUtils.parseUbicacion(a.ubicacion)['ciudad'] ?? '';
          final ciudadB = LocationUtils.parseUbicacion(b.ubicacion)['ciudad'] ?? '';
          return ciudadB.compareTo(ciudadA);
        });
        break;

      case SortOrder.provinceCityAsc:
        result.sort((a, b) {
          final ua = LocationUtils.parseUbicacion(a.ubicacion);
          final ub = LocationUtils.parseUbicacion(b.ubicacion);
          final pa = ua['provincia'] ?? '';
          final pb = ub['provincia'] ?? '';
          final ca = ua['ciudad'] ?? '';
          final cb = ub['ciudad'] ?? '';

          final cmp = pa.compareTo(pb);
          return cmp != 0 ? cmp : ca.compareTo(cb);
        });
        break;

      case SortOrder.provinceCityDesc:
        result.sort((a, b) {
          final ua = LocationUtils.parseUbicacion(a.ubicacion);
          final ub = LocationUtils.parseUbicacion(b.ubicacion);
          final pa = ua['provincia'] ?? '';
          final pb = ub['provincia'] ?? '';
          final ca = ua['ciudad'] ?? '';
          final cb = ub['ciudad'] ?? '';

          final cmp = pb.compareTo(pa);
          return cmp != 0 ? cmp : cb.compareTo(ca);
        });
        break;

      case SortOrder.none:
      default:
        // No hacer nada, mantener orden original
        break;
    }

    return result;
  }

  /// Convierte un string a SortOrder
  static SortOrder fromString(String orderString) {
    switch (orderString) {
      case 'puntuacion_asc':
        return SortOrder.ratingAsc;
      case 'puntuacion_desc':
        return SortOrder.ratingDesc;
      case 'ciudad_asc':
        return SortOrder.cityAsc;
      case 'ciudad_desc':
        return SortOrder.cityDesc;
      case 'provincia_ciudad_asc':
        return SortOrder.provinceCityAsc;
      case 'provincia_ciudad_desc':
        return SortOrder.provinceCityDesc;
      default:
        return SortOrder.none;
    }
  }

  /// Convierte SortOrder a string
  static String toOrderString(SortOrder order) {
    switch (order) {
      case SortOrder.ratingAsc:
        return 'puntuacion_asc';
      case SortOrder.ratingDesc:
        return 'puntuacion_desc';
      case SortOrder.cityAsc:
        return 'ciudad_asc';
      case SortOrder.cityDesc:
        return 'ciudad_desc';
      case SortOrder.provinceCityAsc:
        return 'provincia_ciudad_asc';
      case SortOrder.provinceCityDesc:
        return 'provincia_ciudad_desc';
      case SortOrder.none:
      default:
        return 'ninguno';
    }
  }
}
