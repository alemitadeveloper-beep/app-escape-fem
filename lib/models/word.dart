class Word {
  final int? id;
  final String text;
  final String genero;
  final String ubicacion;
  final String puntuacion;
  final String web;
  final double latitud;
  final double longitud;
  final bool isFavorite;
  final bool isPlayed;
  bool isPending;
  final String? review;
  final String? photoPath;
  final DateTime? datePlayed;
  final int? personalRating;
  final int? historiaRating;
  final int? ambientacionRating;
  final int? jugabilidadRating;
  final int? gameMasterRating;
  final int? miedoRating;
  final String? empresa; // Nuevo campo

  Word({
    this.id,
    required this.text,
    required this.genero,
    required this.ubicacion,
    required this.puntuacion,
    required this.web,
    required this.latitud,
    required this.longitud,
    this.isFavorite = false,
    this.isPlayed = false,
    this.isPending = false,
    this.review,
    this.photoPath,
    this.datePlayed,
    this.personalRating,
    this.historiaRating,
    this.ambientacionRating,
    this.jugabilidadRating,
    this.gameMasterRating,
    this.miedoRating,
    this.empresa,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    // 🔹 Función local corregida (sin guion bajo)
    final toDouble = (value) {
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    };

    return Word(
      id: map['id'],
      text: map['text'] ?? map['nombre'] ?? '',
      genero: map['genero'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      puntuacion: map['puntuacion'] ?? '',
      web: map['web'] ?? '',
      latitud: toDouble(map['latitud']),
      longitud: toDouble(map['longitud']),
      isFavorite: map['isFavorite'] == 1,
      isPlayed: map['isPlayed'] == 1,
      isPending: map['isPending'] == 1,
      review: map['review'],
      photoPath: map['photoPath'],
      datePlayed: map['datePlayed'] != null
          ? DateTime.tryParse(map['datePlayed'])
          : null,
      personalRating: map['personalRating'],
      historiaRating: map['historiaRating'],
      ambientacionRating: map['ambientacionRating'],
      jugabilidadRating: map['jugabilidadRating'],
      gameMasterRating: map['gameMasterRating'],
      miedoRating: map['miedoRating'],
      empresa: map['empresa'], // Nuevo
    );
  }

  get location => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'genero': genero,
      'ubicacion': ubicacion,
      'puntuacion': puntuacion,
      'web': web,
      'latitud': latitud,
      'longitud': longitud,
      'isFavorite': isFavorite ? 1 : 0,
      'isPending': isPending ? 1 : 0,
      'isPlayed': isPlayed ? 1 : 0,
      'review': review,
      'photoPath': photoPath,
      'datePlayed': datePlayed?.toIso8601String(),
      'personalRating': personalRating,
      'historiaRating': historiaRating,
      'ambientacionRating': ambientacionRating,
      'jugabilidadRating': jugabilidadRating,
      'gameMasterRating': gameMasterRating,
      'miedoRating': miedoRating,
      'empresa': empresa, // Nuevo
    };
  }

  Word copyWith({
    int? id,
    String? text,
    String? genero,
    String? ubicacion,
    String? puntuacion,
    String? web,
    double? latitud,
    double? longitud,
    bool? isFavorite,
    bool? isPlayed,
    bool? isPending,
    String? review,
    String? photoPath,
    DateTime? datePlayed,
    int? personalRating,
    int? historiaRating,
    int? ambientacionRating,
    int? jugabilidadRating,
    int? gameMasterRating,
    int? miedoRating,
    String? empresa,
  }) {
    return Word(
      id: id ?? this.id,
      text: text ?? this.text,
      genero: genero ?? this.genero,
      ubicacion: ubicacion ?? this.ubicacion,
      puntuacion: puntuacion ?? this.puntuacion,
      web: web ?? this.web,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      isFavorite: isFavorite ?? this.isFavorite,
      isPlayed: isPlayed ?? this.isPlayed,
      isPending: isPending ?? this.isPending,
      review: review ?? this.review,
      photoPath: photoPath ?? this.photoPath,
      datePlayed: datePlayed ?? this.datePlayed,
      personalRating: personalRating ?? this.personalRating,
      historiaRating: historiaRating ?? this.historiaRating,
      ambientacionRating: ambientacionRating ?? this.ambientacionRating,
      jugabilidadRating: jugabilidadRating ?? this.jugabilidadRating,
      gameMasterRating: gameMasterRating ?? this.gameMasterRating,
      miedoRating: miedoRating ?? this.miedoRating,
      empresa: empresa ?? this.empresa,
    );
  }
}
