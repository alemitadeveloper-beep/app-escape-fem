import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'db/word_database.dart';
import 'pages/favorites_pages.dart' as fav;
import 'pages/word_list_page.dart' as word;
import 'pages/account_page.dart' as account;
import 'pages/login_page.dart';
import 'theme/theme.dart';
import 'services/auth_service.dart';
import 'pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔁 OPCIONAL: borrar la base de datos en desarrollo
  // await deleteDatabaseIfNeeded();

await WordDatabase.instance.seedDatabaseFromJson();

// (UNA VEZ) Rellenar empresa de las filas existentes
final updated = await WordDatabase.instance.backfillEmpresaFromExisting();
print('✅ Empresa backfilled en $updated registros');

// (OPCIONAL una vez): fusionar con el JSON scrapeado si ya lo tienes en assets
await WordDatabase.instance.importEscapesFromScrapedJson();

  // 🧩 (OPCIONAL) Importar del JSON scrapeado y fusionar en BBDD (una sola vez).
  // Descomenta estas dos líneas para ejecutarlo y, tras ver el log en consola,
  // vuelve a comentarlas para no reimportar cada arranque.
  // await WordDatabase.instance.importEscapesFromScrapedJson();

  // 🔎 DEBUG: verificar campo 'empresa' en BBDD
  try {
    final n = await WordDatabase.instance.countConEmpresa();
    // Ej: 👉 Registros con empresa: 123
    // Verás esta línea en la consola de Flutter
    // (Debug Console / Run)
    // ignore: avoid_print
    print('👉 Registros con empresa: $n');

    final faltan = await WordDatabase.instance.getSinEmpresa(limit: 5);
    for (final w in faltan) {
      // ignore: avoid_print
      print('⚠️ Sin empresa → ${w.text} | ${w.web}');
    }
  } catch (e) {
    // ignore: avoid_print
    print('⚠️ Debug empresa falló: $e');
  }

// hola hola
  runApp(const MyApp());
}

Future<void> deleteDatabaseIfNeeded() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'words.db');
  await deleteDatabase(path);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme =
        MaterialTheme(ThemeData.light().textTheme);

    return MaterialApp(
      title: 'Escape Room App',
      theme: materialTheme.light(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000D17),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/logo_escape_fem.png',
              width: 400,
              height: 400,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const fav.FavoritesPage(),
    const word.WordListPage(),
    const account.AccountPage(),
    const MapPage(), // <- añadida aquí
  ];

  void _onItemTapped(int index) {
    final BuildContext currentContext = context;

    if (index == 3 && !AuthService.isLoggedIn) {
      Navigator.pushNamed(currentContext, '/login');
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.outline,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/logo_escape_fem_FAV.png'),
              size: 32,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mis Escapes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi cuenta',
          ),
        ],
      ),
    );
  }
}
