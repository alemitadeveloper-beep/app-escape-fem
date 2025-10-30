import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../domain/services/achievement_service.dart';

/// Card de logro con animación y progreso
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    required this.achievement,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementService.getTierColor(achievement.tier);
    final isLocked = !achievement.isUnlocked;

    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: achievement.isUnlocked
              ? tierColor.withOpacity(0.5)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji con efecto locked/unlocked
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.shade200
                          : tierColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLocked ? Colors.grey.shade400 : tierColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        achievement.emoji,
                        style: TextStyle(
                          fontSize: 32,
                          color: isLocked ? Colors.grey.shade400 : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información del logro
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked
                                      ? Colors.grey.shade600
                                      : Colors.blueGrey.shade900,
                                ),
                              ),
                            ),
                            // Badge del tier
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: tierColor),
                              ),
                              child: Text(
                                AchievementService.getTierName(achievement.tier),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: tierColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isLocked
                                ? Colors.grey.shade500
                                : Colors.blueGrey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Fecha de desbloqueo o progreso
                        if (achievement.isUnlocked)
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Desbloqueado ${_formatDate(achievement.unlockedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progreso',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${achievement.currentProgress}/${achievement.targetValue}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: achievement.progressPercentage,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tierColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Icono de candado si está bloqueado
              if (isLocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Bloqueado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'hace ${diff.inMinutes} min';
      }
      return 'hace ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'hace ${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
