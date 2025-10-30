import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';
import '../widgets/achievement_card.dart';

/// Página Home/Dashboard de Logros - Muestra resumen y estadísticas
class AchievementsHomePage extends StatefulWidget {
  const AchievementsHomePage({super.key});

  @override
  State<AchievementsHomePage> createState() => _AchievementsHomePageState();
}

class _AchievementsHomePageState extends State<AchievementsHomePage> {
  final AchievementRepository _repository = AchievementRepository();

  List<Achievement> _unlockedAchievements = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await _repository.getAllAchievements();
    final stats = await _repository.getAchievementStats();

    if (!mounted) return;

    setState(() {
      _unlockedAchievements = all.where((a) => a.isUnlocked).toList();
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      color: const Color(0xFF000D17),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Estadísticas principales
            Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${_stats['unlocked']}/${_stats['total']}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completado',
                  '${_stats['percentage']}%',
                  Icons.percent,
                  Colors.lightBlue,
                ),
              ),
            ],
            ),
            const SizedBox(height: 20),

            // Insignias conseguidas
            if (_unlockedAchievements.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insignias Conseguidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAchievementBadges(),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Últimos logros desbloqueados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimos Desbloqueados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_unlockedAchievements.length > 3)
                  TextButton(
                    onPressed: () {
                      // Cambiar a la tab de desbloqueados
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_unlockedAchievements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        '¡Aún no has desbloqueado logros!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Juega más escape rooms para conseguir logros',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._unlockedAchievements.take(3).map((achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AchievementCard(
                      achievement: achievement,
                      onTap: () => _showAchievementDetail(achievement),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadges() {
    // Mostrar los emojis de los logros desbloqueados en una grilla
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: _unlockedAchievements.map((achievement) {
        return GestureDetector(
          onTap: () => _showAchievementDetail(achievement),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      }).toList(),
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
