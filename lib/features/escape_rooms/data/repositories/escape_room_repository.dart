import '../models/word.dart';
import '../datasources/word_database.dart';
import '../datasources/firestore_user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Repository para acceso a datos de escape rooms
/// Abstrae la capa de base de datos y proporciona una API limpia
/// Sincroniza datos entre SQLite (local) y Firestore (cloud)
class EscapeRoomRepository {
  final WordDatabase _database = WordDatabase.instance;
  FirestoreUserDataService? _firestoreService;

  /// Inicializar servicio de Firestore si el usuario está autenticado
  Future<void> _ensureFirestoreService() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: FirebaseAuth.currentUser = ${user?.email ?? "NULL"}');
    if (user != null && _firestoreService == null) {
      _firestoreService = FirestoreUserDataService(userId: user.uid);
      print('✅ FirestoreUserDataService inicializado para usuario: ${user.email}');
    }
  }

  // ===== Operaciones de lectura =====

  /// Obtiene todos los escape rooms
  Future<List<Word>> getAllEscapeRooms() async {
    return await _database.readAllWords();
  }

  /// Obtiene un escape room por ID
  Future<Word?> getEscapeRoomById(int id) async {
    return await _database.readById(id);
  }

  /// Obtiene los escape rooms favoritos
  Future<List<Word>> getFavorites() async {
    return await _database.readFavorites();
  }

  /// Obtiene los escape rooms jugados
  Future<List<Word>> getPlayed() async {
    return await _database.readPlayed();
  }

  /// Obtiene los escape rooms pendientes
  Future<List<Word>> getPending() async {
    return await _database.readPending();
  }

  // ===== Operaciones de escritura =====

  /// Marca/desmarca un escape room como favorito
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    // Actualizar en SQLite (local)
    await _database.toggleFavorite(id, isFavorite);

    // Sincronizar con Firestore (cloud)
    await _ensureFirestoreService();
    print('🔍 DEBUG: _firestoreService is ${_firestoreService != null ? "initialized" : "NULL"}');
    if (_firestoreService != null) {
      try {
        print('🔄 Sincronizando favorito $id con Firestore (isFavorite: $isFavorite)...');
        if (isFavorite) {
          await _firestoreService!.addFavorite(id);
          print('✅ Favorito $id sincronizado con Firestore');
        } else {
          await _firestoreService!.removeFavorite(id);
          print('✅ Favorito $id eliminado de Firestore');
        }
      } catch (e) {
        print('⚠️ Error al sincronizar favorito con Firestore: $e');
        // Continuar sin fallar - los datos locales ya están actualizados
      }
    } else {
      print('⚠️ No se puede sincronizar con Firestore: usuario no autenticado');
    }
  }

  /// Marca/desmarca un escape room como jugado
  Future<void> togglePlayed(int id, bool isPlayed) async {
    // Actualizar en SQLite (local)
    await _database.togglePlayed(id, isPlayed);

    // Sincronizar con Firestore (cloud)
    await _ensureFirestoreService();
    if (_firestoreService != null) {
      try {
        if (!isPlayed) {
          await _firestoreService!.removeFromPlayed(id);
        }
        // Si isPlayed = true, se sincronizará cuando se agregue la review
      } catch (e) {
        print('⚠️ Error al sincronizar jugado con Firestore: $e');
      }
    }
  }

  /// Marca/desmarca un escape room como pendiente
  Future<void> togglePending(int id, bool isPending) async {
    // Actualizar en SQLite (local)
    await _database.togglePending(id, isPending);

    // Sincronizar con Firestore (cloud)
    await _ensureFirestoreService();
    if (_firestoreService != null) {
      try {
        if (isPending) {
          await _firestoreService!.addToPending(id);
        } else {
          await _firestoreService!.removeFromPending(id);
        }
      } catch (e) {
        print('⚠️ Error al sincronizar pendiente con Firestore: $e');
      }
    }
  }

  /// Actualiza la reseña de un escape room jugado
  Future<void> updateReview({
    required int id,
    required DateTime datePlayed,
    required int personalRating,
    required String review,
    String? photoPath,
    required int historiaRating,
    required int ambientacionRating,
    required int jugabilidadRating,
    required int gameMasterRating,
    required int miedoRating,
  }) async {
    print('🔍 updateReview llamado para escape room $id');

    // Actualizar en SQLite (local)
    await _database.updateReview(
      id,
      datePlayed,
      personalRating,
      review,
      photoPath,
      historiaRating,
      ambientacionRating,
      jugabilidadRating,
      gameMasterRating,
      miedoRating,
    );
    print('✅ Review actualizada en SQLite para escape room $id');

    // Sincronizar con Firestore (cloud)
    await _ensureFirestoreService();
    print('🔍 DEBUG: _firestoreService is ${_firestoreService != null ? "initialized" : "NULL"}');
    if (_firestoreService != null) {
      try {
        print('🔄 Sincronizando review de escape room $id con Firestore...');
        await _firestoreService!.markAsPlayed(
          escapeRoomId: id,
          datePlayed: datePlayed.toIso8601String(),
          personalRating: personalRating,
          review: review,
          historiaRating: historiaRating,
          ambientacionRating: ambientacionRating,
          jugabilidadRating: jugabilidadRating,
          gameMasterRating: gameMasterRating,
          miedoRating: miedoRating,
        );
        print('✅ Review de escape room $id sincronizada con Firestore');
      } catch (e) {
        print('⚠️ Error al sincronizar review con Firestore: $e');
      }
    } else {
      print('⚠️ No se puede sincronizar review con Firestore: usuario no autenticado');
    }
  }

  /// Marca un escape room como jugado con fecha
  Future<void> markAsPlayed(Word word, {
    String? review,
    String? photoPath,
    DateTime? datePlayed,
    int? personalRating,
  }) async {
    await _database.markAsPlayed(
      word,
      review: review,
      photoPath: photoPath,
      datePlayed: datePlayed,
      personalRating: personalRating,
    );
  }

  // ===== Operaciones de creación/eliminación =====

  /// Crea un nuevo escape room
  Future<Word> createEscapeRoom(Word word) async {
    return await _database.create(word);
  }

  /// Actualiza un escape room existente
  Future<int> updateEscapeRoom(Word word) async {
    return await _database.update(word);
  }

  /// Elimina un escape room
  Future<int> deleteEscapeRoom(int id) async {
    return await _database.delete(id);
  }
}
