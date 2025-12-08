import 'package:flutter/material.dart';
import '../../../escape_rooms/data/models/word.dart';
import '../../../escape_rooms/data/repositories/escape_room_repository.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../../../core/utils/genre_utils.dart';
import '../../../../core/utils/location_utils.dart';

/// Servicio para gestionar la lógica de logros
class AchievementService {
  final AchievementRepository _repository = AchievementRepository();
  final EscapeRoomRepository _escapeRoomRepository = EscapeRoomRepository();

  /// Callback cuando se desbloquea un logro
  Function(Achievement)? onAchievementUnlocked;

  /// Verifica y actualiza el progreso de todos los logros
  Future<List<Achievement>> checkAndUpdateAchievements() async {
    final allAchievements = await _repository.getAllAchievements();
    final newlyUnlocked = <Achievement>[];

    // Obtener datos necesarios
    final playedRooms = await _escapeRoomRepository.getPlayed();

    for (final achievement in allAchievements) {
      if (achievement.isUnlocked) continue; // Ya desbloqueado

      final progress = await _calculateProgress(achievement.type, playedRooms);

      // Actualizar progreso
      if (progress != achievement.currentProgress) {
        await _repository.updateProgress(achievement.id, progress);
      }

      // Verificar si se desbloqueó
      if (progress >= achievement.targetValue) {
        await _repository.unlockAchievement(achievement.id);
        final unlockedAchievement = achievement.copyWith(
          currentProgress: progress,
          unlockedAt: DateTime.now(),
        );
        newlyUnlocked.add(unlockedAchievement);

        // Notificar
        onAchievementUnlocked?.call(unlockedAchievement);
      }
    }

    return newlyUnlocked;
  }

  /// Calcula el progreso actual de un logro específico
  Future<int> _calculateProgress(
    AchievementType type,
    List<Word> playedRooms,
  ) async {
    switch (type) {
      // Logros de cantidad jugada
      case AchievementType.firstPlay:
      case AchievementType.explorer:
      case AchievementType.veteran:
      case AchievementType.master:
        return playedRooms.length;

      // Logros por género
      case AchievementType.terrorFan:
        return _countByGenre(playedRooms, 'terror');

      case AchievementType.adventureFan:
        return _countByGenre(playedRooms, 'aventura');

      // Logros de ubicación
      case AchievementType.traveler:
      case AchievementType.globetrotter:
        return _countUniqueProvinces(playedRooms);

      // Logros de reseñas
      case AchievementType.critic:
        // Contar solo escape rooms con reseña completa (al menos un rating)
        return playedRooms.where((w) {
          final hasReview = w.review != null && w.review!.isNotEmpty;
          final hasRating = w.personalRating != null ||
                           w.historiaRating != null ||
                           w.ambientacionRating != null ||
                           w.jugabilidadRating != null ||
                           w.gameMasterRating != null ||
                           w.miedoRating != null;
          return hasReview && hasRating;
        }).length;

      case AchievementType.photographer:
        return playedRooms.where((w) =>
          w.photoPath != null && w.photoPath!.isNotEmpty
        ).length;

      case AchievementType.weeklyStreak:
        return _calculateWeeklyStreak(playedRooms);

      case AchievementType.completionist:
        return 0; // TODO: Implementar lógica específica
    }
  }

  /// Cuenta escape rooms por género
  int _countByGenre(List<Word> rooms, String targetGenre) {
    return rooms.where((room) {
      final genres = GenreUtils.parseGenres(room.genero);
      return genres.any((g) => g.toLowerCase() == targetGenre.toLowerCase());
    }).length;
  }

  /// Cuenta provincias únicas visitadas
  int _countUniqueProvinces(List<Word> rooms) {
    final provinces = rooms.map((room) {
      final location = LocationUtils.parseUbicacion(room.ubicacion);
      return location['provincia'];
    }).where((p) => p != null && p.isNotEmpty).toSet();

    return provinces.length;
  }

  /// Calcula racha semanal
  int _calculateWeeklyStreak(List<Word> rooms) {
    if (rooms.isEmpty) return 0;

    // Ordenar por fecha
    final sorted = rooms.where((r) => r.datePlayed != null).toList()
      ..sort((a, b) => a.datePlayed!.compareTo(b.datePlayed!));

    if (sorted.isEmpty) return 0;

    int currentStreak = 1;
    int maxStreak = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prevDate = sorted[i - 1].datePlayed!;
      final currentDate = sorted[i].datePlayed!;

      final daysDiff = currentDate.difference(prevDate).inDays;

      if (daysDiff <= 7) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  /// Muestra notificación de logro desbloqueado
  void showAchievementUnlockedNotification(
    BuildContext context,
    Achievement achievement,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡Logro Desbloqueado!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    achievement.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navegar a página de logros
          },
        ),
      ),
    );
  }

  /// Obtiene el color del tier
  static Color getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  /// Obtiene el nombre del tier en español
  static String getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronce';
      case AchievementTier.silver:
        return 'Plata';
      case AchievementTier.gold:
        return 'Oro';
      case AchievementTier.platinum:
        return 'Platino';
    }
  }
}
