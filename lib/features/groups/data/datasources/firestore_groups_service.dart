import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para manejar grupos en Firestore
class FirestoreGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirestoreGroupsService({required this.userId});

  // ============= GRUPOS =============

  /// Crear un nuevo grupo
  Future<String> createGroup({
    required String name,
    required String description,
    required String adminUsername,
    String? routeName,
    bool isPublic = true,
  }) async {
    try {
      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'description': description,
        'adminUid': userId,
        'adminUsername': adminUsername,
        'routeName': routeName,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isPublic': isPublic,
      });

      // Agregar al creador como miembro admin
      await addMember(
        groupId: docRef.id,
        username: adminUsername,
        isAdmin: true,
      );

      print('✅ Grupo creado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al crear grupo: $e');
      rethrow;
    }
  }

  /// Actualizar información del grupo
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? routeName,
    bool? isPublic,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (routeName != null) updates['routeName'] = routeName;
      if (isPublic != null) updates['isPublic'] = isPublic;
      if (isActive != null) updates['isActive'] = isActive;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('groups').doc(groupId).update(updates);
      print('✅ Grupo actualizado: $groupId');
    } catch (e) {
      print('❌ Error al actualizar grupo: $e');
      rethrow;
    }
  }

  /// Eliminar un grupo
  Future<void> deleteGroup(String groupId) async {
    try {
      // Firestore eliminará automáticamente las subcolecciones si configuramos las reglas
      await _firestore.collection('groups').doc(groupId).delete();
      print('✅ Grupo eliminado: $groupId');
    } catch (e) {
      print('❌ Error al eliminar grupo: $e');
      rethrow;
    }
  }

  /// Obtener un grupo por ID
  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      print('❌ Error al obtener grupo: $e');
      return null;
    }
  }

  /// Obtener grupos donde el usuario es miembro
  Stream<List<Map<String, dynamic>>> getMyGroups() {
    return _firestore
        .collection('groups')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> groups = [];

      for (var doc in snapshot.docs) {
        // Verificar si el usuario es miembro
        final memberDoc = await _firestore
            .collection('groups')
            .doc(doc.id)
            .collection('members')
            .doc(userId)
            .get();

        if (memberDoc.exists) {
          final data = doc.data();
          data['id'] = doc.id;
          groups.add(data);
        }
      }

      return groups;
    });
  }

  // ============= MIEMBROS =============

  /// Agregar miembro a un grupo
  Future<void> addMember({
    required String groupId,
    required String username,
    bool isAdmin = false,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .set({
        'username': username,
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': isAdmin,
      });
      print('✅ Miembro agregado al grupo: $groupId');
    } catch (e) {
      print('❌ Error al agregar miembro: $e');
      rethrow;
    }
  }

  /// Eliminar miembro de un grupo
  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .delete();
      print('✅ Miembro eliminado del grupo: $groupId');
    } catch (e) {
      print('❌ Error al eliminar miembro: $e');
      rethrow;
    }
  }

  /// Obtener miembros de un grupo
  Stream<List<Map<String, dynamic>>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============= SESIONES =============

  /// Crear una sesión en un grupo
  Future<String> createSession({
    required String groupId,
    required int escapeRoomId,
    required String escapeRoomName,
    required String scheduledDate,
    String? notes,
  }) async {
    try {
      final docRef = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .add({
        'escapeRoomId': escapeRoomId,
        'escapeRoomName': escapeRoomName,
        'scheduledDate': scheduledDate,
        'notes': notes,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Sesión creada: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al crear sesión: $e');
      rethrow;
    }
  }

  /// Actualizar una sesión
  Future<void> updateSession({
    required String groupId,
    required String sessionId,
    String? scheduledDate,
    String? notes,
    bool? isCompleted,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (scheduledDate != null) updates['scheduledDate'] = scheduledDate;
      if (notes != null) updates['notes'] = notes;
      if (isCompleted != null) updates['isCompleted'] = isCompleted;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .doc(sessionId)
          .update(updates);
      print('✅ Sesión actualizada: $sessionId');
    } catch (e) {
      print('❌ Error al actualizar sesión: $e');
      rethrow;
    }
  }

  /// Eliminar una sesión
  Future<void> deleteSession({
    required String groupId,
    required String sessionId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .doc(sessionId)
          .delete();
      print('✅ Sesión eliminada: $sessionId');
    } catch (e) {
      print('❌ Error al eliminar sesión: $e');
      rethrow;
    }
  }

  /// Obtener sesiones de un grupo
  Stream<List<Map<String, dynamic>>> getGroupSessions(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('sessions')
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============= VALORACIONES DE SESIÓN =============

  /// Agregar valoración a una sesión
  Future<void> addSessionRating({
    required String groupId,
    required String sessionId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .doc(sessionId)
          .collection('ratings')
          .doc(userId)
          .set({
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Valoración agregada a sesión: $sessionId');
    } catch (e) {
      print('❌ Error al agregar valoración: $e');
      rethrow;
    }
  }

  /// Obtener valoraciones de una sesión
  Stream<List<Map<String, dynamic>>> getSessionRatings({
    required String groupId,
    required String sessionId,
  }) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('sessions')
        .doc(sessionId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============= FOTOS DE SESIÓN =============

  /// Agregar foto a una sesión
  Future<String> addSessionPhoto({
    required String groupId,
    required String sessionId,
    required String url,
    String? caption,
  }) async {
    try {
      final docRef = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .doc(sessionId)
          .collection('photos')
          .add({
        'url': url,
        'uploadedBy': userId,
        'caption': caption,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Foto agregada a sesión: $sessionId');
      return docRef.id;
    } catch (e) {
      print('❌ Error al agregar foto: $e');
      rethrow;
    }
  }

  /// Eliminar foto de una sesión
  Future<void> deleteSessionPhoto({
    required String groupId,
    required String sessionId,
    required String photoId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('sessions')
          .doc(sessionId)
          .collection('photos')
          .doc(photoId)
          .delete();
      print('✅ Foto eliminada de sesión: $sessionId');
    } catch (e) {
      print('❌ Error al eliminar foto: $e');
      rethrow;
    }
  }

  /// Obtener fotos de una sesión
  Stream<List<Map<String, dynamic>>> getSessionPhotos({
    required String groupId,
    required String sessionId,
  }) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('sessions')
        .doc(sessionId)
        .collection('photos')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============= INVITACIONES =============

  /// Enviar invitación a un grupo
  Future<String> sendInvitation({
    required String groupId,
    required String groupName,
    required String senderUsername,
    required String recipientUid,
    required String recipientUsername,
    String? message,
  }) async {
    try {
      final docRef = await _firestore.collection('invitations').add({
        'groupId': groupId,
        'groupName': groupName,
        'senderUid': userId,
        'senderUsername': senderUsername,
        'recipientUid': recipientUid,
        'recipientUsername': recipientUsername,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'message': message,
      });

      print('✅ Invitación enviada: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al enviar invitación: $e');
      rethrow;
    }
  }

  /// Aceptar invitación
  Future<void> acceptInvitation(String invitationId) async {
    try {
      final invitationDoc =
          await _firestore.collection('invitations').doc(invitationId).get();

      if (!invitationDoc.exists) {
        throw Exception('Invitación no encontrada');
      }

      final data = invitationDoc.data()!;
      final groupId = data['groupId'] as String;
      final username = data['recipientUsername'] as String;

      // Marcar invitación como aceptada
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Agregar usuario al grupo
      await addMember(groupId: groupId, username: username);

      print('✅ Invitación aceptada: $invitationId');
    } catch (e) {
      print('❌ Error al aceptar invitación: $e');
      rethrow;
    }
  }

  /// Rechazar invitación
  Future<void> declineInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Invitación rechazada: $invitationId');
    } catch (e) {
      print('❌ Error al rechazar invitación: $e');
      rethrow;
    }
  }

  /// Obtener invitaciones pendientes del usuario
  Stream<List<Map<String, dynamic>>> getMyInvitations() {
    return _firestore
        .collection('invitations')
        .where('recipientUid', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
