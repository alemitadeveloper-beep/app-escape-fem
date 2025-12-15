import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Imports de la nueva arquitectura
import 'features/escape_rooms/data/datasources/word_database.dart';
import 'features/escape_rooms/presentation/pages/word_list_page_refactored.dart';
import 'features/escape_rooms/presentation/pages/favorites_page_refactored.dart';
import 'features/auth/presentation/pages/firebase_login_page.dart';
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

  // 🔥 Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔥 Firebase inicializado correctamente');

  // Inicializar AuthService nuevo (refactorizado)
  final authService = AuthService();
  await authService.initialize();

  // Inicializar AuthService antiguo (para AccountPage)
  await old_auth.AuthService.initialize();

  // 🚀 Lanzar la app INMEDIATAMENTE
  runApp(MyApp(authService: authService));

  // ⏳ Cargar base de datos EN SEGUNDO PLANO (no bloquea la UI)
  _initializeDatabaseInBackground();
}

/// Inicializa la base de datos en segundo plano sin bloquear la UI
Future<void> _initializeDatabaseInBackground() async {
  try {
    print('📦 Iniciando carga de base de datos en segundo plano...');

    // Inicializar base de datos
    await WordDatabase.instance.seedDatabaseFromJson();
    print('✅ Base de datos inicializada');

    // (UNA VEZ) Rellenar empresa de las filas existentes
    final updated = await WordDatabase.instance.backfillEmpresaFromExisting();
    print('✅ Empresa backfilled en $updated registros');

    // (OPCIONAL una vez): fusionar con el JSON scrapeado si ya lo tienes en assets
    await WordDatabase.instance.importEscapesFromScrapedJson();
    print('✅ Escapes importados desde JSON');

    // 🔎 DEBUG: verificar campo 'empresa' en BBDD
    final n = await WordDatabase.instance.countConEmpresa();
    print('👉 Registros con empresa: $n');

    final faltan = await WordDatabase.instance.getSinEmpresa(limit: 5);
    for (final w in faltan) {
      print('⚠️ Sin empresa → ${w.text} | ${w.web}');
    }

    print('🎉 Base de datos completamente cargada');
  } catch (e) {
    print('⚠️ Error al inicializar base de datos: $e');
  }
}

Future<void> deleteDatabaseIfNeeded() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'words.db');
  await deleteDatabase(path);
}

// Versión LOCAL sin Firebase (para distribución Android)
class MyAppLocal extends StatelessWidget {
  const MyAppLocal({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme =
        MaterialTheme(ThemeData.light().textTheme);

    return MaterialApp(
      title: 'Escape Fem',
      theme: materialTheme.light(),
      // Sin Firebase - ir directamente a la app
      home: const MainNavigation(),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/achievements': (context) => const AchievementsPage(),
        '/debug-auth': (context) => const DebugAuthPage(),
      },
    );
  }
}

// Versión CON Firebase (para iOS y desarrollo)
class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme =
        MaterialTheme(ThemeData.light().textTheme);

    return MaterialApp(
      title: 'Escape Room App',
      theme: materialTheme.light(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras se verifica el estado de autenticación
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF000D17),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }

          // Si hay un usuario autenticado, mostrar la navegación principal
          if (snapshot.hasData && snapshot.data != null) {
            print('🔥 Usuario autenticado: ${snapshot.data!.email}');
            return const MainNavigation();
          }

          // Si no hay usuario autenticado, mostrar login
          print('🔒 No hay usuario autenticado, mostrando login');
          return const FirebaseLoginPage();
        },
      ),
      routes: {
        '/login': (context) => const FirebaseLoginPage(),
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
