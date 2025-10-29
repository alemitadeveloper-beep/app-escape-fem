import '../../features/escape_rooms/data/models/word.dart';

/// Utilidades para cálculo de ratings
class RatingUtils {
  /// Parsea una puntuación en formato string (ej: "8.5/10") a double
  static double parsePuntuacion(String puntuacion) {
    final regex = RegExp(r'^\d+(\.\d+)?');
    final match = regex.firstMatch(puntuacion.trim());
    if (match != null) {
      return double.tryParse(match.group(0)!) ?? 0.0;
    }
    return 0.0;
  }

  /// Calcula el rating promedio de un escape room jugado
  /// basado en los 5 aspectos: historia, ambientación, jugabilidad, gameMaster, miedo
  static double calculateAverageRating(Word word) {
    int sum = 0;
    int count = 0;

    if (word.historiaRating != null && word.historiaRating! > 0) {
      sum += word.historiaRating!;
      count++;
    }
    if (word.ambientacionRating != null && word.ambientacionRating! > 0) {
      sum += word.ambientacionRating!;
      count++;
    }
    if (word.jugabilidadRating != null && word.jugabilidadRating! > 0) {
      sum += word.jugabilidadRating!;
      count++;
    }
    if (word.gameMasterRating != null && word.gameMasterRating! > 0) {
      sum += word.gameMasterRating!;
      count++;
    }
    if (word.miedoRating != null && word.miedoRating! > 0) {
      sum += word.miedoRating!;
      count++;
    }

    return count > 0 ? sum / count : 0.0;
  }
}
