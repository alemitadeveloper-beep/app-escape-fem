import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../../../../core/utils/parsing_utils.dart';
import '../../../../core/utils/province_utils.dart';

class WordDatabase {
  static final WordDatabase instance = WordDatabase._init();
  static Database? _database;

  WordDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('words.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        genero TEXT,
        ubicacion TEXT,
        puntuacion TEXT,
        web TEXT,
        latitud REAL,
        longitud REAL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isPlayed INTEGER NOT NULL DEFAULT 0,
        isPending INTEGER NOT NULL DEFAULT 0,
        empresa TEXT,
        review TEXT,
        photoPath TEXT,
        datePlayed TEXT,
        personalRating INTEGER,
        ratingPlayed INTEGER,
        reviewPlayed TEXT,
        historiaRating INTEGER,
        ambientacionRating INTEGER,
        jugabilidadRating INTEGER,
        gameMasterRating INTEGER,
        miedoRating INTEGER,
        precio TEXT,
        jugadores TEXT,
        duracion TEXT,
        descripcion TEXT,
        numJugadoresMin INTEGER,
        numJugadoresMax INTEGER,
        dificultad TEXT,
        telefono TEXT,
        email TEXT,
        provincia TEXT,
        imagenUrl TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE words ADD COLUMN empresa TEXT DEFAULT ''");
    }
    if (oldVersion < 3) {
      // Añadir nuevos campos en versión 3
      await db.execute("ALTER TABLE words ADD COLUMN precio TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN jugadores TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN duracion TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN descripcion TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN numJugadoresMin INTEGER");
      await db.execute("ALTER TABLE words ADD COLUMN numJugadoresMax INTEGER");
      await db.execute("ALTER TABLE words ADD COLUMN dificultad TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN telefono TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN email TEXT");
      await db.execute("ALTER TABLE words ADD COLUMN provincia TEXT");
    }
    if (oldVersion < 4) {
      // Añadir campo imagenUrl en versión 4
      await db.execute("ALTER TABLE words ADD COLUMN imagenUrl TEXT");
    }
  }

  Future<void> seedDatabaseFromJson() async {
    final db = await instance.database;

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM words'),
    );
    if (count != null && count > 0) return;

    final String jsonString =
        await rootBundle.loadString('assets/escape_rooms_seed.json');
    final List<dynamic> data = jsonDecode(jsonString);

    for (var item in data) {
      final word = Word.fromMap(item);
      await db.insert('words', word.toMap());
    }
  }

  // ----- CRUD -----
  Future<Word> create(Word word) async {
    final db = await database;
    final id = await db.insert('words', word.toMap());
    return word.copyWith(id: id);
  }

  Future<int> update(Word word) async {
    final db = await database;
    if (word.id == null) {
      throw ArgumentError('update() requiere un Word con id != null');
    }
    return db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<Word?> readById(int id) async {
    final db = await database;
    final maps =
        await db.query('words', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Word.fromMap(maps.first);
  }

  Future<List<Word>> readAllWords() async {
    final db = await database;
    final result = await db.query('words');
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> readFavorites() async {
    final db = await database;
    final result =
        await db.query('words', where: 'isFavorite = ?', whereArgs: [1]);
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> readPlayed() async {
    final db = await database;
    final result =
        await db.query('words', where: 'isPlayed = ?', whereArgs: [1]);
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> readPending() async {
    final db = await database;
    final maps =
        await db.query('words', where: 'isPending = ?', whereArgs: [1]);
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  Future<void> togglePending(int id, bool isPending) async {
    final db = await database;
    await db.update('words', {'isPending': isPending ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> togglePlayed(int id, bool isPlayed) async {
    final db = await database;
    await db.update('words', {'isPlayed': isPlayed ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool newValue) async {
    final db = await database;
    await db.update('words', {'isFavorite': newValue ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAsPlayed(
    Word word, {
    String? review,
    String? photoPath,
    DateTime? datePlayed,
    int? personalRating,
  }) async {
    final db = await database;
    final updated = word.copyWith(
      isPlayed: true,
      review: review,
      photoPath: photoPath,
      datePlayed: datePlayed,
      personalRating: personalRating,
    );
    await db.update('words', updated.toMap(),
        where: 'id = ?', whereArgs: [word.id]);
  }

  Future<void> updateReview(
    int id,
    DateTime datePlayed,
    int personalRating,
    String comment,
    String? photoPath,
    int historiaRating,
    int ambientacionRating,
    int jugabilidadRating,
    int gameMasterRating,
    int miedoRating,
  ) async {
    final db = await database;
    await db.update(
      'words',
      {
        'datePlayed': datePlayed.toIso8601String(),
        'personalRating': personalRating,
        'review': comment,
        'photoPath': photoPath,
        'historiaRating': historiaRating,
        'ambientacionRating': ambientacionRating,
        'jugabilidadRating': jugabilidadRating,
        'gameMasterRating': gameMasterRating,
        'miedoRating': miedoRating,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('words');
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    final maps = await db.query('words');
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  // ---------- MERGE JSON EN BBDD ----------
  Future<int> upsertFromJsonList(List<Map<String, dynamic>> items) async {
    final db = await database;
    int inserts = 0, updates = 0;

    String norm(String? s) =>
        (s ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    final existing = await db.query('words');
    final byKey = <String, Map<String, dynamic>>{};
    for (final m in existing) {
      final key =
          '${norm(m['text'] as String? ?? m['nombre'] as String?)}::${norm(m['ubicacion'] as String?)}';
      byKey[key] = m;
    }
    final byWeb = <String, Map<String, dynamic>>{};
    for (final m in existing) {
      final webValue = m['web'];
      if (webValue is String) {
        final String w = norm(webValue);
        if (w.isNotEmpty) {
          byWeb[w] = m;
        }
      }
    }

    await db.transaction((txn) async {
      for (final raw in items) {
        final w = Word.fromMap(raw);
        final String k = '${norm(w.text)}::${norm(w.ubicacion)}';
        final String wweb = norm(w.web);

        Map<String, dynamic>? found =
            byKey[k] ?? (wweb.isNotEmpty ? byWeb[wweb] : null);

        if (found == null) {
          final id = await txn.insert('words', w.toMap());
          inserts++;
          final mInserted = w.copyWith(id: id).toMap();
          byKey[k] = mInserted;
          if (wweb.isNotEmpty) byWeb[wweb] = mInserted;
        } else {
          final current = Word.fromMap(found);
          final merged = current.copyWith(
            text: current.text.isEmpty ? w.text : current.text,
            genero: current.genero.isEmpty ? w.genero : current.genero,
            ubicacion: current.ubicacion.isEmpty ? w.ubicacion : current.ubicacion,
            puntuacion: current.puntuacion.isEmpty ? w.puntuacion : current.puntuacion,
            web: current.web.isEmpty ? w.web : current.web,
            latitud: (current.latitud == 0.0 ? w.latitud : current.latitud),
            longitud: (current.longitud == 0.0 ? w.longitud : current.longitud),
            empresa: (w.empresa != null && w.empresa!.isNotEmpty) ? w.empresa : current.empresa,
            precio: (w.precio != null && w.precio!.isNotEmpty) ? w.precio : current.precio,
            jugadores: (w.jugadores != null && w.jugadores!.isNotEmpty) ? w.jugadores : current.jugadores,
            duracion: (w.duracion != null && w.duracion!.isNotEmpty) ? w.duracion : current.duracion,
            descripcion: (w.descripcion != null && w.descripcion!.isNotEmpty) ? w.descripcion : current.descripcion,
            numJugadoresMin: w.numJugadoresMin ?? current.numJugadoresMin,
            numJugadoresMax: w.numJugadoresMax ?? current.numJugadoresMax,
            dificultad: (w.dificultad != null && w.dificultad!.isNotEmpty) ? w.dificultad : current.dificultad,
            telefono: (w.telefono != null && w.telefono!.isNotEmpty) ? w.telefono : current.telefono,
            email: (w.email != null && w.email!.isNotEmpty) ? w.email : current.email,
            provincia: (w.provincia != null && w.provincia!.isNotEmpty) ? w.provincia : current.provincia,
            imagenUrl: (w.imagenUrl != null && w.imagenUrl!.isNotEmpty) ? w.imagenUrl : current.imagenUrl,
          );

          await txn.update('words', merged.toMap(),
              where: 'id = ?', whereArgs: [current.id]);
          updates++;
        }
      }
    });

    return inserts + updates;
  }

  // ---------- IMPORTACIÓN DESDE JSON SCRAPEADO ----------
  Future<void> importEscapesFromScrapedJson() async {
    final String jsonString =
        await rootBundle.loadString('assets/escape_rooms_completo.json');
    final List<dynamic> data = jsonDecode(jsonString);

    int filtrados = 0;

    // --- Procesamiento mejorado con limpieza y parseo ---
    final List<Map<String, dynamic>> items = [];

    for (final e in data) {
      final m = Map<String, dynamic>.from(e);

      // Validar nombre (filtrar registros basura)
      final nombre = (m['text'] ?? m['nombre'] ?? '').toString();
      if (!ParsingUtils.isValidNombre(nombre)) {
        filtrados++;
        continue;
      }

      m['text'] = nombre;
      m['genero'] = ParsingUtils.cleanGenero(m['genero']?.toString());
      m['ubicacion'] = ParsingUtils.cleanUbicacion(m['ubicacion']?.toString());
      m['puntuacion'] = (m['puntuacion'] ?? '').toString();

      // Limpiar web
      final web = ParsingUtils.cleanWeb(m['web']?.toString());
      m['web'] = web ?? '';

      // Coordenadas
      double lat = 0.0;
      double lon = 0.0;

      if (m['latitud'] is String) {
        lat = double.tryParse(m['latitud']) ?? 0.0;
      } else if (m['latitud'] != null) {
        lat = (m['latitud'] as num).toDouble();
      }

      if (m['longitud'] is String) {
        lon = double.tryParse(m['longitud']) ?? 0.0;
      } else if (m['longitud'] != null) {
        lon = (m['longitud'] as num).toDouble();
      }

      m['latitud'] = lat;
      m['longitud'] = lon;

      // Empresa: deduce desde URL o nombre
      final currentEmpresa = (m['empresa'] ?? '').toString().trim();
      if (currentEmpresa.isEmpty) {
        if (web != null && web.isNotEmpty) {
          m['empresa'] = _guessCompanyFromUrl(web);
        } else {
          m['empresa'] = _guessCompanyFromNombre(nombre);
        }
      }

      // --- NUEVOS CAMPOS ---

      // Parsear precio
      m['precio'] = ParsingUtils.normalizePrecio(m['precio']?.toString());

      // Parsear jugadores
      final jugadoresStr = m['jugadores']?.toString();
      m['jugadores'] = jugadoresStr;
      final jugadoresMap = ParsingUtils.parseJugadores(jugadoresStr);
      m['numJugadoresMin'] = jugadoresMap['min'];
      m['numJugadoresMax'] = jugadoresMap['max'];

      // Parsear duración
      m['duracion'] = ParsingUtils.normalizeDuracion(m['duracion']?.toString());

      // Limpiar descripción
      m['descripcion'] = ParsingUtils.cleanDescripcion(m['descripcion']?.toString());

      // Teléfono y email
      m['telefono'] = ParsingUtils.cleanPhone(m['telefono']?.toString());
      m['email'] = ParsingUtils.isValidEmail(m['email']?.toString())
          ? m['email']?.toString()
          : null;

      // Obtener provincia desde coordenadas o ubicación
      m['provincia'] = ProvinceUtils.getProvincia(
        lat != 0.0 ? lat : null,
        lon != 0.0 ? lon : null,
        m['ubicacion']?.toString(),
      );

      items.add(m);
    }

    final int changes = await upsertFromJsonList(items);
    print('✅ Importación scrapeada: $changes filas insertadas/actualizadas');
    print('🗑️ Registros filtrados (inválidos): $filtrados');
  }

  // ---- Helpers privados ----
  String _guessCompanyFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    Uri? uri;
    try {
      if (!url.startsWith('http')) {
        url = 'https://' + url;
      }
      uri = Uri.parse(url);
    } catch (_) {
      return '';
    }
    String host = uri.host.isNotEmpty ? uri.host : uri.toString();

    host = host
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '')
        .trim();

    String company = _companyFromHost(host);

    if (company.isEmpty) {
      final p = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (p.isNotEmpty) company = _cleanCompanyName(p);
    }

    return company;
  }

  // Nuevo: deduce empresa desde el nombre del juego si viene en formato "Juego | Empresa"
  String _guessCompanyFromNombre(String? nombre) {
    final s = (nombre ?? '').trim();
    if (s.isEmpty) return '';
    if (s.contains('|')) {
      final parts = s.split('|');
      if (parts.length >= 2) {
        final candidate = parts.last.trim();
        final cleaned = _cleanCompanyName(candidate);
        return cleaned;
      }
    }
    return '';
  }

  Future<int> countConEmpresa() async {
    final db = await database;
    final res = await db.rawQuery(
      "SELECT COUNT(*) as c FROM words WHERE TRIM(IFNULL(empresa, '')) <> ''"
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // Rellena 'empresa' usando 'web' para registros existentes que no la tengan
  Future<int> backfillEmpresaFromExisting() async {
    final db = await database;
    final rows = await db.query(
      'words',
      columns: ['id', 'web', 'empresa'],
      where: "empresa IS NULL OR empresa = ''",
    );

    int updates = 0;
    for (final r in rows) {
      final int id = r['id'] as int;
      final String web = (r['web'] as String?)?.trim() ?? '';
      final String empresaActual = (r['empresa'] as String?)?.trim() ?? '';
      if (empresaActual.isNotEmpty) continue;

      final guessed = _guessCompanyFromUrl(web).trim();
      if (guessed.isNotEmpty) {
        await db.update(
          'words',
          {'empresa': guessed},
          where: 'id = ?',
          whereArgs: [id],
        );
        updates++;
      }
    }
    return updates;
  }

  Future<List<Word>> getSinEmpresa({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: "TRIM(IFNULL(empresa, '')) = ''",
      limit: limit,
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  // ---------- NUEVOS MÉTODOS DE CONSULTA ----------

  /// Obtiene escape rooms filtrados por provincia
  Future<List<Word>> getByProvincia(String provincia) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'provincia = ?',
      whereArgs: [provincia],
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  /// Obtiene todas las provincias únicas disponibles
  Future<List<String>> getProvinciasDisponibles() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT DISTINCT provincia FROM words WHERE provincia IS NOT NULL AND provincia != '' ORDER BY provincia"
    );
    return result.map((r) => r['provincia'] as String).toList();
  }

  /// Obtiene escape rooms con descripción
  Future<List<Word>> getWithDescripcion() async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: "descripcion IS NOT NULL AND descripcion != ''",
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  /// Filtra escape rooms por número de jugadores
  Future<List<Word>> getByNumJugadores(int numJugadores) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: '(numJugadoresMin IS NULL OR numJugadoresMin <= ?) AND (numJugadoresMax IS NULL OR numJugadoresMax >= ?)',
      whereArgs: [numJugadores, numJugadores],
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  /// Actualiza la provincia para todos los registros que tengan coordenadas
  Future<int> backfillProvinciaFromCoordinates() async {
    final db = await database;
    final rows = await db.query(
      'words',
      columns: ['id', 'latitud', 'longitud', 'ubicacion', 'provincia'],
      where: "provincia IS NULL OR provincia = ''",
    );

    int updates = 0;
    for (final r in rows) {
      final int id = r['id'] as int;
      final double? lat = r['latitud'] as double?;
      final double? lon = r['longitud'] as double?;
      final String? ubicacion = r['ubicacion'] as String?;

      final provincia = ProvinceUtils.getProvincia(lat, lon, ubicacion);

      if (provincia != null && provincia.isNotEmpty) {
        await db.update(
          'words',
          {'provincia': provincia},
          where: 'id = ?',
          whereArgs: [id],
        );
        updates++;
      }
    }
    return updates;
  }

  /// Obtiene estadísticas de la base de datos
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM words'),
    ) ?? 0;

    final conDescripcion = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM words WHERE descripcion IS NOT NULL AND descripcion != ''"),
    ) ?? 0;

    final conProvincia = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM words WHERE provincia IS NOT NULL AND provincia != ''"),
    ) ?? 0;

    final conPrecio = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM words WHERE precio IS NOT NULL AND precio != ''"),
    ) ?? 0;

    final conJugadores = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM words WHERE numJugadoresMin IS NOT NULL"),
    ) ?? 0;

    final conEmpresa = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM words WHERE empresa IS NOT NULL AND empresa != ''"),
    ) ?? 0;

    return {
      'total': total,
      'conDescripcion': conDescripcion,
      'conProvincia': conProvincia,
      'conPrecio': conPrecio,
      'conJugadores': conJugadores,
      'conEmpresa': conEmpresa,
    };
  }

  String _companyFromHost(String host) {
    var base = host.split(':').first;
    final parts = base.split('.');
    if (parts.length >= 2) {
      base = parts[parts.length - 2];
    } else {
      base = parts.first;
    }
    return _cleanCompanyName(base);
  }

  String _cleanCompanyName(String raw) {
    if (raw.isEmpty) return '';
    var s = raw
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();

    const stop = {
      'escape', 'room', 'rooms', 'escaperoom', 'escape room',
      'the', 'la', 'el', 'de', 'del'
    };

    if (stop.contains(s)) return '';

    s = s
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return s;
  }
}
