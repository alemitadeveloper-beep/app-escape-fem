import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/group_session.dart';
import '../models/session_rating.dart';
import '../models/session_photo.dart';
import '../models/group_invitation.dart';

class GroupsDatabase {
  static final GroupsDatabase instance = GroupsDatabase._init();
  static Database? _database;

  GroupsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('groups.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar campo isPublic a grupos
      await db.execute('ALTER TABLE groups ADD COLUMN isPublic INTEGER NOT NULL DEFAULT 1');

      // Crear tabla de invitaciones
      await db.execute('''
        CREATE TABLE group_invitations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          groupId INTEGER NOT NULL,
          groupName TEXT NOT NULL,
          senderUsername TEXT NOT NULL,
          recipientUsername TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          message TEXT,
          FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE CASCADE,
          UNIQUE(groupId, recipientUsername, status)
        )
      ''');

      // Índices para invitaciones
      await db.execute('CREATE INDEX idx_invitations_recipient ON group_invitations(recipientUsername, status)');
      await db.execute('CREATE INDEX idx_invitations_group ON group_invitations(groupId)');
    }

    if (oldVersion < 3) {
      // Verificar si la tabla group_invitations existe, si no, crearla
      var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='group_invitations'"
      );

      if (tables.isEmpty) {
        // Crear tabla de invitaciones
        await db.execute('''
          CREATE TABLE group_invitations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            groupId INTEGER NOT NULL,
            groupName TEXT NOT NULL,
            senderUsername TEXT NOT NULL,
            recipientUsername TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            message TEXT,
            FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE CASCADE,
            UNIQUE(groupId, recipientUsername, status)
          )
        ''');

        // Índices para invitaciones
        await db.execute('CREATE INDEX idx_invitations_recipient ON group_invitations(recipientUsername, status)');
        await db.execute('CREATE INDEX idx_invitations_group ON group_invitations(groupId)');
      }
    }
  }

  Future _createDB(Database db, int version) async {
    // Tabla de grupos
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        adminUsername TEXT NOT NULL,
        routeName TEXT,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        isPublic INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de miembros del grupo
    await db.execute('''
      CREATE TABLE group_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        username TEXT NOT NULL,
        joinedAt TEXT NOT NULL,
        isAdmin INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE CASCADE,
        UNIQUE(groupId, username)
      )
    ''');

    // Tabla de sesiones
    await db.execute('''
      CREATE TABLE group_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        escapeRoomId INTEGER NOT NULL,
        escapeRoomName TEXT NOT NULL,
        scheduledDate TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de valoraciones de sesiones
    await db.execute('''
      CREATE TABLE session_ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        username TEXT NOT NULL,
        overallRating INTEGER NOT NULL,
        historiaRating INTEGER,
        ambientacionRating INTEGER,
        jugabilidadRating INTEGER,
        gameMasterRating INTEGER,
        miedoRating INTEGER,
        review TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES group_sessions (id) ON DELETE CASCADE,
        UNIQUE(sessionId, username)
      )
    ''');

    // Tabla de fotos de sesiones
    await db.execute('''
      CREATE TABLE session_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        username TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        caption TEXT,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES group_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de invitaciones (IMPORTANTE: debe estar en onCreate también)
    await db.execute('''
      CREATE TABLE group_invitations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        groupName TEXT NOT NULL,
        senderUsername TEXT NOT NULL,
        recipientUsername TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        message TEXT,
        FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE CASCADE,
        UNIQUE(groupId, recipientUsername, status)
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_group_members_groupId ON group_members(groupId)');
    await db.execute('CREATE INDEX idx_group_sessions_groupId ON group_sessions(groupId)');
    await db.execute('CREATE INDEX idx_session_ratings_sessionId ON session_ratings(sessionId)');
    await db.execute('CREATE INDEX idx_session_photos_sessionId ON session_photos(sessionId)');
    await db.execute('CREATE INDEX idx_invitations_recipient ON group_invitations(recipientUsername, status)');
    await db.execute('CREATE INDEX idx_invitations_group ON group_invitations(groupId)');
  }

  // ==================== GRUPOS ====================

  Future<int> createGroup(EscapeGroup group) async {
    final db = await database;
    return await db.insert('groups', group.toMap());
  }

  Future<List<EscapeGroup>> getAllGroups() async {
    final db = await database;
    final result = await db.query('groups', orderBy: 'createdAt DESC');
    return result.map((map) => EscapeGroup.fromMap(map)).toList();
  }

  Future<List<EscapeGroup>> getGroupsByUsername(String username) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT g.* FROM groups g
      INNER JOIN group_members gm ON g.id = gm.groupId
      WHERE gm.username = ?
      ORDER BY g.createdAt DESC
    ''', [username]);
    return result.map((map) => EscapeGroup.fromMap(map)).toList();
  }

  Future<EscapeGroup?> getGroup(int id) async {
    final db = await database;
    final result = await db.query('groups', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return EscapeGroup.fromMap(result.first);
  }

  Future<int> updateGroup(EscapeGroup group) async {
    final db = await database;
    return await db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    final db = await database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MIEMBROS ====================

  Future<int> addMember(GroupMember member) async {
    final db = await database;
    return await db.insert(
      'group_members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    final db = await database;
    final result = await db.query(
      'group_members',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'joinedAt ASC',
    );
    return result.map((map) => GroupMember.fromMap(map)).toList();
  }

  Future<bool> isMember(int groupId, String username) async {
    final db = await database;
    final result = await db.query(
      'group_members',
      where: 'groupId = ? AND username = ?',
      whereArgs: [groupId, username],
    );
    return result.isNotEmpty;
  }

  Future<int> removeMember(int groupId, String username) async {
    final db = await database;
    return await db.delete(
      'group_members',
      where: 'groupId = ? AND username = ?',
      whereArgs: [groupId, username],
    );
  }

  // ==================== SESIONES ====================

  Future<int> createSession(GroupSession session) async {
    final db = await database;
    return await db.insert('group_sessions', session.toMap());
  }

  Future<List<GroupSession>> getGroupSessions(int groupId) async {
    final db = await database;
    final result = await db.query(
      'group_sessions',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'scheduledDate DESC',
    );
    return result.map((map) => GroupSession.fromMap(map)).toList();
  }

  Future<GroupSession?> getSession(int id) async {
    final db = await database;
    final result = await db.query('group_sessions', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return GroupSession.fromMap(result.first);
  }

  Future<int> updateSession(GroupSession session) async {
    final db = await database;
    return await db.update(
      'group_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete('group_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markSessionCompleted(int sessionId) async {
    final db = await database;
    return await db.update(
      'group_sessions',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // ==================== VALORACIONES ====================

  Future<int> createRating(SessionRating rating) async {
    final db = await database;
    return await db.insert(
      'session_ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SessionRating>> getSessionRatings(int sessionId) async {
    final db = await database;
    final result = await db.query(
      'session_ratings',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => SessionRating.fromMap(map)).toList();
  }

  Future<SessionRating?> getUserRating(int sessionId, String username) async {
    final db = await database;
    final result = await db.query(
      'session_ratings',
      where: 'sessionId = ? AND username = ?',
      whereArgs: [sessionId, username],
    );
    if (result.isEmpty) return null;
    return SessionRating.fromMap(result.first);
  }

  Future<Map<String, dynamic>> getSessionAverageRating(int sessionId) async {
    final ratings = await getSessionRatings(sessionId);
    if (ratings.isEmpty) {
      return {
        'average': 0.0,
        'count': 0,
        'historiaAvg': 0.0,
        'ambientacionAvg': 0.0,
        'jugabilidadAvg': 0.0,
        'gameMasterAvg': 0.0,
        'miedoAvg': 0.0,
      };
    }

    final overallAvg = ratings.map((r) => r.overallRating).reduce((a, b) => a + b) / ratings.length;

    double avgRating(List<int?> values) {
      final validValues = values.where((v) => v != null).map((v) => v!).toList();
      if (validValues.isEmpty) return 0.0;
      return validValues.reduce((a, b) => a + b) / validValues.length;
    }

    return {
      'average': overallAvg,
      'count': ratings.length,
      'historiaAvg': avgRating(ratings.map((r) => r.historiaRating).toList()),
      'ambientacionAvg': avgRating(ratings.map((r) => r.ambientacionRating).toList()),
      'jugabilidadAvg': avgRating(ratings.map((r) => r.jugabilidadRating).toList()),
      'gameMasterAvg': avgRating(ratings.map((r) => r.gameMasterRating).toList()),
      'miedoAvg': avgRating(ratings.map((r) => r.miedoRating).toList()),
    };
  }

  // ==================== FOTOS ====================

  Future<int> addPhoto(SessionPhoto photo) async {
    final db = await database;
    return await db.insert('session_photos', photo.toMap());
  }

  Future<List<SessionPhoto>> getSessionPhotos(int sessionId) async {
    final db = await database;
    final result = await db.query(
      'session_photos',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => SessionPhoto.fromMap(map)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete('session_photos', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== RANKING ====================

  Future<List<Map<String, dynamic>>> getGroupRanking(int groupId) async {
    final db = await database;
    // Obtener ranking basado en promedio de valoraciones de cada usuario
    final result = await db.rawQuery('''
      SELECT
        gm.username,
        COUNT(DISTINCT sr.sessionId) as sessionsRated,
        AVG(sr.overallRating) as averageRating,
        SUM(sr.overallRating) as totalPoints
      FROM group_members gm
      LEFT JOIN group_sessions gs ON gs.groupId = gm.groupId
      LEFT JOIN session_ratings sr ON sr.sessionId = gs.id AND sr.username = gm.username
      WHERE gm.groupId = ?
      GROUP BY gm.username
      ORDER BY averageRating DESC, sessionsRated DESC
    ''', [groupId]);

    return result;
  }

  // ==================== INVITACIONES ====================

  Future<int> createInvitation(GroupInvitation invitation) async {
    final db = await database;
    return await db.insert(
      'group_invitations',
      invitation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<GroupInvitation>> getPendingInvitations(String username) async {
    final db = await database;
    final result = await db.query(
      'group_invitations',
      where: 'recipientUsername = ? AND status = ?',
      whereArgs: [username, 'pending'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => GroupInvitation.fromMap(map)).toList();
  }

  Future<List<GroupInvitation>> getGroupInvitations(int groupId) async {
    final db = await database;
    final result = await db.query(
      'group_invitations',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => GroupInvitation.fromMap(map)).toList();
  }

  Future<int> updateInvitationStatus(int invitationId, String status) async {
    final db = await database;
    return await db.update(
      'group_invitations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [invitationId],
    );
  }

  Future<int> deleteInvitation(int id) async {
    final db = await database;
    return await db.delete('group_invitations', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getPendingInvitationsCount(String username) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM group_invitations WHERE recipientUsername = ? AND status = ?',
      [username, 'pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
