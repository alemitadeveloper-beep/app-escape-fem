import 'package:flutter/material.dart';
import 'achievements_home_page.dart';
import 'achievements_unlocked_page.dart';
import 'achievements_locked_page.dart';

/// Página principal de Logros con pestañas
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Mis Logros',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Tab 0: Mis Logros (Dashboard/Resumen)
            AchievementsHomePage(),
            // Tab 1: Desbloqueados
            AchievementsUnlockedPage(),
            // Tab 2: Bloqueados
            AchievementsLockedPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: (index) {
            _tabController.animateTo(index);
            setState(() {});
          },
          selectedItemColor: const Color(0xFF000D17),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Mis Logros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'Desbloqueados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock),
              label: 'Bloqueados',
            ),
          ],
        ),
      ),
    );
  }
}
