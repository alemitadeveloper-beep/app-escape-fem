import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';

/// Servicio para manejar los datos específicos del usuario en Firestore
/// (favoritos, jugados, pendientes)
class FirestoreUserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirestoreUserDataService({required this.userId});

  // ============= FAVORITOS =============

  /// Agregar escape room a favoritos
  Future<void> addFavorite(int escapeRoomId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(escapeRoomId.toString())
          .set({
        'escapeRoomId': escapeRoomId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Favorito agregado: $escapeRoomId');
    } catch (e) {
      print('❌ Error al agregar favorito: $e');
      rethrow;
    }
  }

  /// Eliminar escape room de favoritos
  Future<void> removeFavorite(int escapeRoomId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(escapeRoomId.toString())
          .delete();
      print('✅ Favorito eliminado: $escapeRoomId');
    } catch (e) {
      print('❌ Error al eliminar favorito: $e');
      rethrow;
    }
  }

  /// Verificar si un escape room está en favoritos
  Future<bool> isFavorite(int escapeRoomId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(escapeRoomId.toString())
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ Error al verificar favorito: $e');
      return false;
    }
  }

  /// Obtener todos los IDs de favoritos del usuario
  Future<List<int>> getFavoriteIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['escapeRoomId'] as int)
          .toList();
    } catch (e) {
      print('❌ Error al obtener favoritos: $e');
      return [];
    }
  }

  // ============= JUGADOS =============

  /// Marcar escape room como jugado con valoración
  Future<void> markAsPlayed({
    required int escapeRoomId,
    required String datePlayed,
    int? personalRating,
    String? review,
    int? historiaRating,
    int? ambientacionRating,
    int? jugabilidadRating,
    int? gameMasterRating,
    int? miedoRating,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('played')
          .doc(escapeRoomId.toString())
          .set({
        'escapeRoomId': escapeRoomId,
        'datePlayed': datePlayed,
        'personalRating': personalRating,
        'review': review,
        'historiaRating': historiaRating,
        'ambientacionRating': ambientacionRating,
        'jugabilidadRating': jugabilidadRating,
        'gameMasterRating': gameMasterRating,
        'miedoRating': miedoRating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Escape room marcado como jugado: $escapeRoomId');
    } catch (e) {
      print('❌ Error al marcar como jugado: $e');
      rethrow;
    }
  }

  /// Eliminar escape room de jugados
  Future<void> removeFromPlayed(int escapeRoomId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('played')
          .doc(escapeRoomId.toString())
          .delete();
      print('✅ Escape room eliminado de jugados: $escapeRoomId');
    } catch (e) {
      print('❌ Error al eliminar de jugados: $e');
      rethrow;
    }
  }

  /// Obtener datos de un escape room jugado
  Future<Map<String, dynamic>?> getPlayedData(int escapeRoomId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('played')
          .doc(escapeRoomId.toString())
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Error al obtener datos de jugado: $e');
      return null;
    }
  }

  /// Obtener todos los IDs de escape rooms jugados
  Future<List<int>> getPlayedIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('played')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['escapeRoomId'] as int)
          .toList();
    } catch (e) {
      print('❌ Error al obtener jugados: $e');
      return [];
    }
  }

  // ============= PENDIENTES =============

  /// Agregar escape room a pendientes
  Future<void> addToPending(int escapeRoomId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pending')
          .doc(escapeRoomId.toString())
          .set({
        'escapeRoomId': escapeRoomId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Escape room agregado a pendientes: $escapeRoomId');
    } catch (e) {
      print('❌ Error al agregar a pendientes: $e');
      rethrow;
    }
  }

  /// Eliminar escape room de pendientes
  Future<void> removeFromPending(int escapeRoomId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pending')
          .doc(escapeRoomId.toString())
          .delete();
      print('✅ Escape room eliminado de pendientes: $escapeRoomId');
    } catch (e) {
      print('❌ Error al eliminar de pendientes: $e');
      rethrow;
    }
  }

  /// Obtener todos los IDs de escape rooms pendientes
  Future<List<int>> getPendingIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pending')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['escapeRoomId'] as int)
          .toList();
    } catch (e) {
      print('❌ Error al obtener pendientes: $e');
      return [];
    }
  }

  // ============= SINCRONIZACIÓN =============

  /// Sincronizar todos los datos del usuario desde SQLite a Firestore
  Future<void> syncFromSQLite(List<Word> words) async {
    try {
      print('🔄 Iniciando sincronización a Firestore...');

      // Sincronizar favoritos
      for (var word in words.where((w) => w.isFavorite)) {
        if (word.id != null) {
          await addFavorite(word.id!);
        }
      }

      // Sincronizar jugados
      for (var word in words.where((w) => w.isPlayed)) {
        if (word.id != null) {
          await markAsPlayed(
            escapeRoomId: word.id!,
            datePlayed: word.datePlayed?.toIso8601String() ?? DateTime.now().toIso8601String(),
            personalRating: word.personalRating,
            review: word.review,
            historiaRating: word.historiaRating,
            ambientacionRating: word.ambientacionRating,
            jugabilidadRating: word.jugabilidadRating,
            gameMasterRating: word.gameMasterRating,
            miedoRating: word.miedoRating,
          );
        }
      }

      // Sincronizar pendientes
      for (var word in words.where((w) => w.isPending)) {
        if (word.id != null) {
          await addToPending(word.id!);
        }
      }

      print('✅ Sincronización completada');
    } catch (e) {
      print('❌ Error en sincronización: $e');
      rethrow;
    }
  }
}
