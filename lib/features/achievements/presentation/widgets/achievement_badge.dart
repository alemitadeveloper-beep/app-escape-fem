import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../domain/services/achievement_service.dart';

/// Badge pequeño de logro para mostrar en perfil
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;

  const AchievementBadge({
    required this.achievement,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementService.getTierColor(achievement.tier);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tierColor.withOpacity(0.2),
        border: Border.all(
          color: tierColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          achievement.emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// Grid de badges pequeños
class AchievementBadgeGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final int maxDisplay;

  const AchievementBadgeGrid({
    required this.achievements,
    this.maxDisplay = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayAchievements = achievements.take(maxDisplay).toList();
    final remaining = achievements.length - maxDisplay;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayAchievements.map((achievement) => AchievementBadge(
              achievement: achievement,
              size: 50,
            )),
        if (remaining > 0)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
