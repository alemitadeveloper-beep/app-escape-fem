/// Tipos de logros disponibles
enum AchievementType {
  firstPlay,        // Juega tu primer escape room
  explorer,         // Juega 5 escape rooms
  veteran,          // Juega 20 escape rooms
  master,           // Juega 50 escape rooms
  terrorFan,        // Juega 10 escape rooms de terror
  adventureFan,     // Juega 10 escape rooms de aventura
  traveler,         // Visita 3 provincias diferentes
  globetrotter,     // Visita 10 provincias diferentes
  critic,           // Escribe 10 reseñas
  photographer,     // Agrega fotos a 5 reseñas
  weeklyStreak,     // Juega un escape room cada semana por 4 semanas
  completionist,    // Completa todos los escape rooms de una provincia
}

/// Niveles de dificultad de logros
enum AchievementTier {
  bronze,   // 🥉
  silver,   // 🥈
  gold,     // 🥇
  platinum, // 💎
}

/// Modelo de logro
class Achievement {
  final AchievementType type;
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementTier tier;
  final int targetValue;
  final DateTime? unlockedAt;
  final int currentProgress;

  Achievement({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.tier,
    required this.targetValue,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progressPercentage => (currentProgress / targetValue).clamp(0.0, 1.0);

  Achievement copyWith({
    AchievementType? type,
    String? id,
    String? title,
    String? description,
    String? emoji,
    AchievementTier? tier,
    int? targetValue,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      type: type ?? this.type,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      tier: tier ?? this.tier,
      targetValue: targetValue ?? this.targetValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'tier': tier.toString(),
      'targetValue': targetValue,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      id: map['id'],
      title: map['title'],
      description: map['description'],
      emoji: map['emoji'],
      tier: AchievementTier.values.firstWhere(
        (e) => e.toString() == map['tier'],
      ),
      targetValue: map['targetValue'],
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      currentProgress: map['currentProgress'] ?? 0,
    );
  }

  /// Define todos los logros disponibles
  static List<Achievement> getAllAchievements() {
    return [
      // Logros de cantidad jugada
      Achievement(
        type: AchievementType.firstPlay,
        id: 'first_play',
        title: 'Primer Paso',
        description: 'Juega 50 escape rooms',
        emoji: '🎯',
        tier: AchievementTier.bronze,
        targetValue: 50,
      ),
      Achievement(
        type: AchievementType.explorer,
        id: 'explorer',
        title: 'Explorador',
        description: 'Juega 100 escape rooms',
        emoji: '🧭',
        tier: AchievementTier.silver,
        targetValue: 100,
      ),
      Achievement(
        type: AchievementType.veteran,
        id: 'veteran',
        title: 'Veterano',
        description: 'Juega 300 escape rooms',
        emoji: '🏆',
        tier: AchievementTier.gold,
        targetValue: 300,
      ),
      Achievement(
        type: AchievementType.master,
        id: 'master',
        title: 'Maestro Escapista',
        description: 'Juega 500 escape rooms',
        emoji: '💎',
        tier: AchievementTier.platinum,
        targetValue: 500,
      ),

      // Logros por género
      Achievement(
        type: AchievementType.terrorFan,
        id: 'terror_fan',
        title: 'Fan del Terror',
        description: 'Juega 50 escape rooms de terror',
        emoji: '👻',
        tier: AchievementTier.gold,
        targetValue: 50,
      ),
      Achievement(
        type: AchievementType.adventureFan,
        id: 'adventure_fan',
        title: 'Aventurero',
        description: 'Juega 50 escape rooms de aventura',
        emoji: '🗺️',
        tier: AchievementTier.gold,
        targetValue: 50,
      ),

      // Logros de ubicación
      Achievement(
        type: AchievementType.traveler,
        id: 'traveler',
        title: 'Viajero',
        description: 'Visita 5 provincias diferentes',
        emoji: '✈️',
        tier: AchievementTier.silver,
        targetValue: 5,
      ),
      Achievement(
        type: AchievementType.globetrotter,
        id: 'globetrotter',
        title: 'Trotamundos',
        description: 'Visita 10 provincias diferentes',
        emoji: '🌍',
        tier: AchievementTier.platinum,
        targetValue: 10,
      ),

      // Logros de reseñas
      Achievement(
        type: AchievementType.critic,
        id: 'critic',
        title: 'Crítico',
        description: 'Escribe 50 reseñas',
        emoji: '✍️',
        tier: AchievementTier.gold,
        targetValue: 50,
      ),
      Achievement(
        type: AchievementType.photographer,
        id: 'photographer',
        title: 'Fotógrafo',
        description: 'Agrega fotos a 20 reseñas',
        emoji: '📸',
        tier: AchievementTier.silver,
        targetValue: 20,
      ),

    ];
  }
}
