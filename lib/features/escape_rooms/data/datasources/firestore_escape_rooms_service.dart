import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';

/// Servicio para gestionar el catálogo global de escape rooms en Firestore
/// Esta es una colección pública compartida por todos los usuarios
class FirestoreEscapeRoomsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Subir todos los escape rooms a Firestore (migración inicial)
  /// IMPORTANTE: Solo ejecutar una vez para migrar datos
  Future<void> uploadAllEscapeRooms(List<Word> escapeRooms) async {
    print('🔄 Iniciando subida de ${escapeRooms.length} escape rooms a Firestore...');

    // Usar batch para optimizar escrituras (máximo 500 por batch)
    const batchSize = 500;
    int uploaded = 0;

    for (int i = 0; i < escapeRooms.length; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize < escapeRooms.length) ? i + batchSize : escapeRooms.length;

      for (int j = i; j < end; j++) {
        final word = escapeRooms[j];
        if (word.id == null) continue;

        final docRef = _firestore.collection('escapeRooms').doc(word.id.toString());

        batch.set(docRef, {
          'id': word.id,
          'text': word.text,
          'empresa': word.empresa,
          'ubicacion': word.ubicacion,
          'genero': word.genero,
          'puntuacion': word.puntuacion,
          'web': word.web,
          'latitud': word.latitud,
          'longitud': word.longitud,
          'precio': word.precio,
          'jugadores': word.jugadores,
          'duracion': word.duracion,
          'numJugadoresMin': word.numJugadoresMin,
          'numJugadoresMax': word.numJugadoresMax,
          'dificultad': word.dificultad,
          'telefono': word.telefono,
          'email': word.email,
          'provincia': word.provincia,
          'descripcion': word.descripcion,
          'imagenUrl': word.imagenUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      uploaded += (end - i);
      print('✅ Subidos $uploaded/${escapeRooms.length} escape rooms');
    }

    print('✅ Migración completada: $uploaded escape rooms subidos a Firestore');
  }

  /// Obtener todos los escape rooms desde Firestore
  Future<List<Map<String, dynamic>>> getAllEscapeRooms() async {
    try {
      final snapshot = await _firestore
          .collection('escapeRooms')
          .orderBy('id')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error al obtener escape rooms: $e');
      return [];
    }
  }

  /// Obtener un escape room específico por ID
  Future<Map<String, dynamic>?> getEscapeRoomById(int id) async {
    try {
      final doc = await _firestore
          .collection('escapeRooms')
          .doc(id.toString())
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Error al obtener escape room $id: $e');
      return null;
    }
  }

  /// Agregar o actualizar un escape room
  Future<void> upsertEscapeRoom(Word word) async {
    if (word.id == null) {
      throw Exception('El escape room debe tener un ID');
    }

    await _firestore.collection('escapeRooms').doc(word.id.toString()).set({
      'id': word.id,
      'text': word.text,
      'empresa': word.empresa,
      'ubicacion': word.ubicacion,
      'genero': word.genero,
      'puntuacion': word.puntuacion,
      'web': word.web,
      'latitud': word.latitud,
      'longitud': word.longitud,
      'precio': word.precio,
      'jugadores': word.jugadores,
      'duracion': word.duracion,
      'numJugadoresMin': word.numJugadoresMin,
      'numJugadoresMax': word.numJugadoresMax,
      'dificultad': word.dificultad,
      'telefono': word.telefono,
      'email': word.email,
      'provincia': word.provincia,
      'descripcion': word.descripcion,
      'imagenUrl': word.imagenUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('✅ Escape room ${word.id} actualizado en Firestore');
  }

  /// Eliminar un escape room
  Future<void> deleteEscapeRoom(int id) async {
    await _firestore.collection('escapeRooms').doc(id.toString()).delete();
    print('✅ Escape room $id eliminado de Firestore');
  }

  /// Obtener estadísticas del catálogo
  Future<Map<String, dynamic>> getCatalogStats() async {
    try {
      final snapshot = await _firestore.collection('escapeRooms').get();

      final cities = <String>{};
      final companies = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['ubicacion'] != null) cities.add(data['ubicacion']);
        if (data['empresa'] != null) companies.add(data['empresa']);
      }

      return {
        'totalEscapeRooms': snapshot.docs.length,
        'totalCities': cities.length,
        'totalCompanies': companies.length,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {};
    }
  }
}
