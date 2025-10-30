import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';
import '../widgets/achievement_card.dart';

/// Página de Logros Bloqueados
class AchievementsLockedPage extends StatefulWidget {
  const AchievementsLockedPage({super.key});

  @override
  State<AchievementsLockedPage> createState() => _AchievementsLockedPageState();
}

class _AchievementsLockedPageState extends State<AchievementsLockedPage> {
  final AchievementRepository _repository = AchievementRepository();

  List<Achievement> _lockedAchievements = [];
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
      _lockedAchievements = all.where((a) => !a.isUnlocked).toList()
        ..sort((a, b) => b.tier.index.compareTo(a.tier.index)); // Por tier (platino primero)
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lockedAchievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.amber.shade600),
              const SizedBox(height: 16),
              Text(
                '¡Felicidades!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has desbloqueado todos los logros',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lockedAchievements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementCard(
            achievement: _lockedAchievements[index],
            onTap: () => _showAchievementDetail(_lockedAchievements[index]),
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
            Text(
              '${achievement.currentProgress} / ${achievement.targetValue}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: achievement.progressPercentage,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(achievement.progressPercentage * 100).toStringAsFixed(0)}% completado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
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
}
