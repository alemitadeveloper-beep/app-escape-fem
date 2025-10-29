import '../models/word.dart';
import '../datasources/word_database.dart';

/// Repository para acceso a datos de escape rooms
/// Abstrae la capa de base de datos y proporciona una API limpia
class EscapeRoomRepository {
  final WordDatabase _database = WordDatabase.instance;

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
    await _database.toggleFavorite(id, isFavorite);
  }

  /// Marca/desmarca un escape room como jugado
  Future<void> togglePlayed(int id, bool isPlayed) async {
    await _database.togglePlayed(id, isPlayed);
  }

  /// Marca/desmarca un escape room como pendiente
  Future<void> togglePending(int id, bool isPending) async {
    await _database.togglePending(id, isPending);
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
