import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';

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
      version: 2,
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
        empresa TEXT DEFAULT '',
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
        miedoRating INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE words ADD COLUMN empresa TEXT DEFAULT ''");
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
            empresa: (w.empresa ?? '').isNotEmpty ? w.empresa : current.empresa,
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

    // --- ARREGLO A: normaliza web y deduce empresa de URL o del nombre ---
    final List<Map<String, dynamic>> items = data.map((e) {
      final m = Map<String, dynamic>.from(e);

      m['text'] = (m['text'] ?? m['nombre'] ?? '').toString();
      m['genero'] = (m['genero'] ?? '').toString();
      m['ubicacion'] = (m['ubicacion'] ?? '').toString();
      m['puntuacion'] = (m['puntuacion'] ?? '').toString();

      // Normaliza web y trata "/" o "#" como vacío
      var web = (m['web'] ?? '').toString().trim();
      if (web == '/' || web == '#') web = '';
      m['web'] = web;

      // Coordenadas
      if (m['latitud'] is String) {
        m['latitud'] = double.tryParse(m['latitud']) ?? 0.0;
      } else if (m['latitud'] == null) {
        m['latitud'] = 0.0;
      }
      if (m['longitud'] is String) {
        m['longitud'] = double.tryParse(m['longitud']) ?? 0.0;
      } else if (m['longitud'] == null) {
        m['longitud'] = 0.0;
      }

      // Empresa: si no viene y no hay web válida, intenta desde el nombre
      final currentEmpresa = (m['empresa'] ?? '').toString().trim();
      if (currentEmpresa.isEmpty) {
        if (web.isNotEmpty) {
          m['empresa'] = _guessCompanyFromUrl(web);
        } else {
          m['empresa'] = _guessCompanyFromNombre(m['text']);
        }
      }

      return m;
    }).toList();

    final int changes = await upsertFromJsonList(items);
    print('✅ Importación scrapeada: $changes filas insertadas/actualizadas');
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
