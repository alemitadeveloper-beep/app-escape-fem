import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

/// Repository para gestionar logros con persistencia
class AchievementRepository {
  static const String _keyUnlockedAchievements = 'unlocked_achievements';

  /// Obtiene todos los logros con su progreso actual
  Future<List<Achievement>> getAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedJson = prefs.getString(_keyUnlockedAchievements);

    Map<String, dynamic> unlockedData = {};
    if (unlockedJson != null) {
      unlockedData = json.decode(unlockedJson);
    }

    // Combinar logros base con progreso guardado
    final allAchievements = Achievement.getAllAchievements();

    return allAchievements.map((achievement) {
      final savedData = unlockedData[achievement.id];
      if (savedData != null) {
        return achievement.copyWith(
          currentProgress: savedData['currentProgress'] ?? 0,
          unlockedAt: savedData['unlockedAt'] != null
              ? DateTime.parse(savedData['unlockedAt'])
              : null,
        );
      }
      return achievement;
    }).toList();
  }

  /// Obtiene solo los logros desbloqueados
  Future<List<Achievement>> getUnlockedAchievements() async {
    final allAchievements = await getAllAchievements();
    return allAchievements.where((a) => a.isUnlocked).toList();
  }

  /// Obtiene un logro específico por ID
  Future<Achievement?> getAchievementById(String id) async {
    final allAchievements = await getAllAchievements();
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza el progreso de un logro
  Future<void> updateProgress(String achievementId, int progress) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedJson = prefs.getString(_keyUnlockedAchievements) ?? '{}';
    final Map<String, dynamic> unlockedData = json.decode(unlockedJson);

    unlockedData[achievementId] = {
      'currentProgress': progress,
      'unlockedAt': unlockedData[achievementId]?['unlockedAt'],
    };

    await prefs.setString(_keyUnlockedAchievements, json.encode(unlockedData));
  }

  /// Desbloquea un logro
  Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedJson = prefs.getString(_keyUnlockedAchievements) ?? '{}';
    final Map<String, dynamic> unlockedData = json.decode(unlockedJson);

    final achievement = await getAchievementById(achievementId);
    if (achievement == null) return;

    unlockedData[achievementId] = {
      'currentProgress': achievement.targetValue,
      'unlockedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_keyUnlockedAchievements, json.encode(unlockedData));
  }

  /// Obtiene estadísticas de logros
  Future<Map<String, dynamic>> getAchievementStats() async {
    final allAchievements = await getAllAchievements();
    final unlocked = allAchievements.where((a) => a.isUnlocked).length;
    final total = allAchievements.length;

    final bronzeUnlocked = allAchievements
        .where((a) => a.isUnlocked && a.tier == AchievementTier.bronze)
        .length;
    final silverUnlocked = allAchievements
        .where((a) => a.isUnlocked && a.tier == AchievementTier.silver)
        .length;
    final goldUnlocked = allAchievements
        .where((a) => a.isUnlocked && a.tier == AchievementTier.gold)
        .length;
    final platinumUnlocked = allAchievements
        .where((a) => a.isUnlocked && a.tier == AchievementTier.platinum)
        .length;

    return {
      'total': total,
      'unlocked': unlocked,
      'locked': total - unlocked,
      'percentage': (unlocked / total * 100).toInt(),
      'bronze': bronzeUnlocked,
      'silver': silverUnlocked,
      'gold': goldUnlocked,
      'platinum': platinumUnlocked,
    };
  }

  /// Resetea todos los logros (útil para testing)
  Future<void> resetAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUnlockedAchievements);
  }
}
