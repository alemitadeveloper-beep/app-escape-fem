import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Imports de la nueva arquitectura
import 'features/escape_rooms/data/datasources/word_database.dart';
import 'features/escape_rooms/presentation/pages/word_list_page_refactored.dart';
import 'features/escape_rooms/presentation/pages/favorites_page_refactored.dart';
import 'features/auth/presentation/pages/login_page_refactored.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/achievements/presentation/pages/achievements_page.dart';
import 'core/theme/theme.dart';

// Imports antiguos que aún se usan
import 'pages/account_page.dart' as account;
import 'pages/map_page.dart';
import 'services/auth_service.dart' as old_auth;
import 'debug_auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔁 OPCIONAL: borrar la base de datos en desarrollo
  // await deleteDatabaseIfNeeded();

  // Inicializar base de datos
  await WordDatabase.instance.seedDatabaseFromJson();

  // (UNA VEZ) Rellenar empresa de las filas existentes
  final updated = await WordDatabase.instance.backfillEmpresaFromExisting();
  print('✅ Empresa backfilled en $updated registros');

  // (OPCIONAL una vez): fusionar con el JSON scrapeado si ya lo tienes en assets
  await WordDatabase.instance.importEscapesFromScrapedJson();

  // 🔎 DEBUG: verificar campo 'empresa' en BBDD
  try {
    final n = await WordDatabase.instance.countConEmpresa();
    print('👉 Registros con empresa: $n');

    final faltan = await WordDatabase.instance.getSinEmpresa(limit: 5);
    for (final w in faltan) {
      print('⚠️ Sin empresa → ${w.text} | ${w.web}');
    }
  } catch (e) {
    print('⚠️ Debug empresa falló: $e');
  }

  // Inicializar AuthService nuevo (refactorizado)
  final authService = AuthService();
  await authService.initialize();

  // Inicializar AuthService antiguo (para AccountPage)
  await old_auth.AuthService.initialize();

  runApp(MyApp(authService: authService));
}

Future<void> deleteDatabaseIfNeeded() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'words.db');
  await deleteDatabase(path);
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme =
        MaterialTheme(ThemeData.light().textTheme);

    // Usar el AuthService antiguo para la ruta inicial (sincronizado con AccountPage)
    final initialRoute = old_auth.AuthService.isLoggedIn ? '/main' : '/login';
    print('🚀 App starting - initialRoute: $initialRoute, isLoggedIn: ${old_auth.AuthService.isLoggedIn}');

    return MaterialApp(
      title: 'Escape Room App',
      theme: materialTheme.light(),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPageRefactored(),
        '/main': (context) => const MainNavigation(),
        '/achievements': (context) => const AchievementsPage(),
        '/debug-auth': (context) => const DebugAuthPage(),
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

  // Usando las páginas REFACTORIZADAS
  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const FavoritesPageRefactored(), // ⭐ NUEVA
    const WordListPageRefactored(),  // ⭐ NUEVA
    const account.AccountPage(),
    const MapPage(),
  ];

  void _onItemTapped(int index) {
    // Debug: imprimir estado de autenticación
    print('🔍 Tab $index tapped - isLoggedIn: ${old_auth.AuthService.isLoggedIn}, username: ${old_auth.AuthService.username}');

    // TEMPORALMENTE DESHABILITADO: Permitir acceso a Mi cuenta sin login
    // para poder acceder a Debug Auth y Mis Logros

    print('✅ Mostrando página $index (sin verificar login)');
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
