/// Modelo para representar una foto subida por un miembro en una sesión
class SessionPhoto {
  final int? id;
  final int sessionId;
  final String username; // Quien subió la foto
  final String photoPath; // Ruta local de la foto
  final String? caption; // Descripción opcional
  final DateTime uploadedAt;

  SessionPhoto({
    this.id,
    required this.sessionId,
    required this.username,
    required this.photoPath,
    this.caption,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'username': username,
      'photoPath': photoPath,
      'caption': caption,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory SessionPhoto.fromMap(Map<String, dynamic> map) {
    return SessionPhoto(
      id: map['id'],
      sessionId: map['sessionId'],
      username: map['username'],
      photoPath: map['photoPath'],
      caption: map['caption'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
