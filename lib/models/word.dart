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
  final String? empresa;

  // Nuevos campos del scraping
  final String? precio;
  final String? jugadores;
  final String? duracion;
  final String? descripcion;
  final int? numJugadoresMin;
  final int? numJugadoresMax;
  final String? dificultad;
  final String? telefono;
  final String? email;
  final String? provincia; // Provincia extraída de coordenadas o ubicación
  final String? imagenUrl; // URL de imagen del escape room o empresa

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
    this.precio,
    this.jugadores,
    this.duracion,
    this.descripcion,
    this.numJugadoresMin,
    this.numJugadoresMax,
    this.dificultad,
    this.telefono,
    this.email,
    this.provincia,
    this.imagenUrl,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    String? cleanString(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      if (str.isEmpty ||
          str == 'No disponible' ||
          str == '/' ||
          str == '#' ||
          str.toLowerCase() == 'null') {
        return null;
      }
      return str;
    }

    return Word(
      id: map['id'],
      text: cleanString(map['text'] ?? map['nombre']) ?? '',
      genero: cleanString(map['genero']) ?? '',
      ubicacion: cleanString(map['ubicacion']) ?? '',
      puntuacion: cleanString(map['puntuacion']) ?? '',
      web: cleanString(map['web']) ?? '',
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
      empresa: cleanString(map['empresa']),
      precio: cleanString(map['precio']),
      jugadores: cleanString(map['jugadores']),
      duracion: cleanString(map['duracion']),
      descripcion: cleanString(map['descripcion']),
      numJugadoresMin: map['numJugadoresMin'],
      numJugadoresMax: map['numJugadoresMax'],
      dificultad: cleanString(map['dificultad']),
      telefono: cleanString(map['telefono']),
      email: cleanString(map['email']),
      provincia: cleanString(map['provincia']),
      imagenUrl: cleanString(map['imagenUrl']),
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
      'empresa': empresa,
      'precio': precio,
      'jugadores': jugadores,
      'duracion': duracion,
      'descripcion': descripcion,
      'numJugadoresMin': numJugadoresMin,
      'numJugadoresMax': numJugadoresMax,
      'dificultad': dificultad,
      'telefono': telefono,
      'email': email,
      'provincia': provincia,
      'imagenUrl': imagenUrl,
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
    String? precio,
    String? jugadores,
    String? duracion,
    String? descripcion,
    int? numJugadoresMin,
    int? numJugadoresMax,
    String? dificultad,
    String? telefono,
    String? email,
    String? provincia,
    String? imagenUrl,
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
      precio: precio ?? this.precio,
      jugadores: jugadores ?? this.jugadores,
      duracion: duracion ?? this.duracion,
      descripcion: descripcion ?? this.descripcion,
      numJugadoresMin: numJugadoresMin ?? this.numJugadoresMin,
      numJugadoresMax: numJugadoresMax ?? this.numJugadoresMax,
      dificultad: dificultad ?? this.dificultad,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      provincia: provincia ?? this.provincia,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
