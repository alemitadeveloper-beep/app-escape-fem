import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/word.dart';
import '../../data/repositories/escape_room_repository.dart';
import '../../../../core/utils/rating_utils.dart';
import '../widgets/played_expansion_card.dart';
import '../widgets/pending_expansion_card.dart';
import '../widgets/review_dialog.dart';
import '../../../achievements/domain/services/achievement_service.dart';

/// Página de Mis Escape Rooms - REFACTORIZADA
class FavoritesPageRefactored extends StatefulWidget {
  const FavoritesPageRefactored({super.key});

  @override
  State<FavoritesPageRefactored> createState() =>
      _FavoritesPageRefactoredState();
}

class _FavoritesPageRefactoredState extends State<FavoritesPageRefactored>
    with SingleTickerProviderStateMixin {
  final EscapeRoomRepository _repository = EscapeRoomRepository();
  final AchievementService _achievementService = AchievementService();

  late TabController _tabController;
  List<Word> _played = [];
  List<Word> _pending = [];
  List<Word> _ranking = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Setup achievement unlock callback
    _achievementService.onAchievementUnlocked = (achievement) {
      if (mounted) {
        _achievementService.showAchievementUnlockedNotification(
          context,
          achievement,
        );
      }
    };

    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final played = await _repository.getPlayed();
    final pending = await _repository.getPending();

    if (!mounted) return;

    // Ordenar ranking por rating promedio
    final rankingList = [...played]
      ..sort((a, b) => RatingUtils.calculateAverageRating(b)
          .compareTo(RatingUtils.calculateAverageRating(a)));

    setState(() {
      _played = played;
      _pending = pending;
      _ranking = rankingList;
    });

    // Check and update achievements after data loads
    await _achievementService.checkAndUpdateAchievements();
  }

  void _openReviewDialog(Word word) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        word: word,
        onReviewSaved: _loadData,
      ),
    );
  }

  Future<void> _deletePending(Word word) async {
    await _repository.togglePending(word.id!, false);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis Escape Rooms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF000D17),
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF000D17),
            child: CupertinoTabBar(
              currentIndex: _tabController.index,
              onTap: (index) {
                _tabController.animateTo(index);
              },
              backgroundColor: const Color(0xFF000D17),
              activeColor: Colors.lightBlueAccent.shade100,
              inactiveColor: Colors.blueGrey.shade100,
              items: List.generate(3, (index) {
                final isSelected = _tabController.index == index;
                double iconSize = isSelected ? 30.0 : 24.0;
                return BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      [
                        Icons.check_circle,
                        Icons.access_time,
                        Icons.emoji_events,
                      ][index],
                      size: iconSize,
                    ),
                  ),
                  label: [
                    'Jugados',
                    'Pendientes',
                    'Ranking'
                  ][index],
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayedList(),
                _buildPendingList(),
                _buildRankingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayedList() {
    if (_played.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos para mostrar.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      itemCount: _played.length,
      itemBuilder: (context, index) {
        final word = _played[index];
        return PlayedExpansionCard(
          word: word,
          onEdit: () => _openReviewDialog(word),
          isRanking: false,
        );
      },
    );
  }

  Widget _buildPendingList() {
    if (_pending.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos para mostrar.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      itemCount: _pending.length,
      itemBuilder: (context, index) {
        final word = _pending[index];
        return PendingExpansionCard(
          word: word,
          onDelete: () => _deletePending(word),
        );
      },
    );
  }

  Widget _buildRankingList() {
    if (_ranking.isEmpty) {
      return Center(
        child: Text(
          'No hay escape rooms jugados con puntuación.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      itemCount: _ranking.length,
      itemBuilder: (context, index) {
        final word = _ranking[index];
        final averageRating = RatingUtils.calculateAverageRating(word);

        // Solo mostrar si tiene rating
        if (averageRating == 0.0) {
          return const SizedBox.shrink();
        }

        return PlayedExpansionCard(
          word: word,
          onEdit: () => _openReviewDialog(word),
          isRanking: true,
          rankingPosition: index + 1,
        );
      },
    );
  }
}
