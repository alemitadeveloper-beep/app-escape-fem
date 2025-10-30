import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_badge.dart';

/// Página de Logros Desbloqueados
class AchievementsUnlockedPage extends StatefulWidget {
  const AchievementsUnlockedPage({super.key});

  @override
  State<AchievementsUnlockedPage> createState() => _AchievementsUnlockedPageState();
}

class _AchievementsUnlockedPageState extends State<AchievementsUnlockedPage> {
  final AchievementRepository _repository = AchievementRepository();

  List<Achievement> _unlockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await _repository.getAllAchievements();

    if (!mounted) return;

    setState(() {
      _unlockedAchievements = all.where((a) => a.isUnlocked).toList()
        ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!)); // Más reciente primero
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_unlockedAchievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No hay logros desbloqueados',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¡Sigue jugando para desbloquear más!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _unlockedAchievements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementCard(
            achievement: _unlockedAchievements[index],
            onTap: () => _showAchievementDetail(_unlockedAchievements[index]),
          ),
        );
      },
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Desbloqueado',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Desbloqueado el ${_formatDate(achievement.unlockedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
