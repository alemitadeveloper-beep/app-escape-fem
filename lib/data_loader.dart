import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models/word.dart';

Future<List<Word>> loadWordsFromJson() async {
  final String response = await rootBundle.loadString('assets/escape_rooms.json');
  final List<dynamic> data = json.decode(response);

  return data.map((item) {
    return Word(
      text: item['nombre'] ?? '',
      genero: item['genero'] ?? '',
      ubicacion: item['ubicacion'] ?? '',
      puntuacion: item['puntuacion'] ?? '',
      web: item['web'] ?? '',
      latitud: 0.0, // Puedes actualizar con coordenadas reales más adelante
      longitud: 0.0,
      isFavorite: false,
      isPlayed: false,
      review: null,
      photoPath: null,
      datePlayed: null,
      personalRating: null,
    );
  }).toList();
}
