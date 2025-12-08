/// Modelo para representar una valoración individual de un miembro en una sesión
class SessionRating {
  final int? id;
  final int sessionId;
  final String username;
  final int overallRating; // Puntuación general (1-5)
  final int? historiaRating;
  final int? ambientacionRating;
  final int? jugabilidadRating;
  final int? gameMasterRating;
  final int? miedoRating;
  final String? review; // Comentario del usuario
  final DateTime createdAt;

  SessionRating({
    this.id,
    required this.sessionId,
    required this.username,
    required this.overallRating,
    this.historiaRating,
    this.ambientacionRating,
    this.jugabilidadRating,
    this.gameMasterRating,
    this.miedoRating,
    this.review,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'username': username,
      'overallRating': overallRating,
      'historiaRating': historiaRating,
      'ambientacionRating': ambientacionRating,
      'jugabilidadRating': jugabilidadRating,
      'gameMasterRating': gameMasterRating,
      'miedoRating': miedoRating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SessionRating.fromMap(Map<String, dynamic> map) {
    return SessionRating(
      id: map['id'],
      sessionId: map['sessionId'],
      username: map['username'],
      overallRating: map['overallRating'],
      historiaRating: map['historiaRating'],
      ambientacionRating: map['ambientacionRating'],
      jugabilidadRating: map['jugabilidadRating'],
      gameMasterRating: map['gameMasterRating'],
      miedoRating: map['miedoRating'],
      review: map['review'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  double get averageDetailedRating {
    final ratings = [
      historiaRating,
      ambientacionRating,
      jugabilidadRating,
      gameMasterRating,
      miedoRating,
    ].where((r) => r != null).map((r) => r!).toList();

    if (ratings.isEmpty) return overallRating.toDouble();
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
