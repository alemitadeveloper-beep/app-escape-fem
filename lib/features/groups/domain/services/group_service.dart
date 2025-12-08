import '../../data/datasources/groups_database.dart';
import '../../data/models/group.dart';
import '../../data/models/group_member.dart';
import '../../data/models/group_session.dart';
import '../../data/models/session_rating.dart';
import '../../data/models/session_photo.dart';
import '../../data/models/group_invitation.dart';

/// Servicio para gestionar toda la lógica de negocio de grupos
class GroupService {
  final GroupsDatabase _db = GroupsDatabase.instance;

  // ==================== GRUPOS ====================

  /// Crear un nuevo grupo (solo admin)
  Future<int> createGroup({
    required String name,
    required String description,
    required String adminUsername,
    String? routeName,
    bool isPublic = true,
  }) async {
    final group = EscapeGroup(
      name: name,
      description: description,
      adminUsername: adminUsername,
      routeName: routeName,
      isPublic: isPublic,
    );

    final groupId = await _db.createGroup(group);

    // Añadir al admin como miembro
    await _db.addMember(GroupMember(
      groupId: groupId,
      username: adminUsername,
      isAdmin: true,
    ));

    return groupId;
  }

  /// Obtener todos los grupos
  Future<List<EscapeGroup>> getAllGroups() async {
    return await _db.getAllGroups();
  }

  /// Obtener grupos de un usuario
  Future<List<EscapeGroup>> getUserGroups(String username) async {
    return await _db.getGroupsByUsername(username);
  }

  /// Obtener un grupo específico
  Future<EscapeGroup?> getGroup(int id) async {
    return await _db.getGroup(id);
  }

  /// Actualizar grupo (solo admin)
  Future<bool> updateGroup(EscapeGroup group, String requestingUsername) async {
    // Verificar que es admin
    final originalGroup = await _db.getGroup(group.id!);
    if (originalGroup == null || originalGroup.adminUsername != requestingUsername) {
      return false;
    }

    await _db.updateGroup(group);
    return true;
  }

  /// Eliminar grupo (solo admin)
  Future<bool> deleteGroup(int groupId, String requestingUsername) async {
    final group = await _db.getGroup(groupId);
    if (group == null || group.adminUsername != requestingUsername) {
      return false;
    }

    await _db.deleteGroup(groupId);
    return true;
  }

  // ==================== MIEMBROS ====================

  /// Unirse a un grupo
  Future<bool> joinGroup(int groupId, String username) async {
    final group = await _db.getGroup(groupId);
    if (group == null) return false;

    // Si el grupo es privado, no se puede unir directamente
    if (!group.isPublic) return false;

    final isMember = await _db.isMember(groupId, username);
    if (isMember) return false;

    await _db.addMember(GroupMember(
      groupId: groupId,
      username: username,
    ));
    return true;
  }

  /// Salir de un grupo
  Future<bool> leaveGroup(int groupId, String username) async {
    final group = await _db.getGroup(groupId);
    if (group == null || group.adminUsername == username) {
      // El admin no puede salir sin eliminar el grupo
      return false;
    }

    await _db.removeMember(groupId, username);
    return true;
  }

  /// Obtener miembros de un grupo
  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    return await _db.getGroupMembers(groupId);
  }

  /// Verificar si un usuario es miembro
  Future<bool> isMember(int groupId, String username) async {
    return await _db.isMember(groupId, username);
  }

  // ==================== SESIONES ====================

  /// Crear una nueva sesión (solo admin o miembros)
  Future<int?> createSession({
    required int groupId,
    required int escapeRoomId,
    required String escapeRoomName,
    required DateTime scheduledDate,
    String? notes,
    required String requestingUsername,
  }) async {
    // Verificar que es miembro
    final isMember = await _db.isMember(groupId, requestingUsername);
    if (!isMember) return null;

    final session = GroupSession(
      groupId: groupId,
      escapeRoomId: escapeRoomId,
      escapeRoomName: escapeRoomName,
      scheduledDate: scheduledDate,
      notes: notes,
    );

    return await _db.createSession(session);
  }

  /// Obtener sesiones de un grupo
  Future<List<GroupSession>> getGroupSessions(int groupId) async {
    return await _db.getGroupSessions(groupId);
  }

  /// Obtener una sesión específica
  Future<GroupSession?> getSession(int sessionId) async {
    return await _db.getSession(sessionId);
  }

  /// Actualizar sesión
  Future<bool> updateSession(GroupSession session, String requestingUsername) async {
    // Verificar que es miembro del grupo
    final isMember = await _db.isMember(session.groupId, requestingUsername);
    if (!isMember) return false;

    await _db.updateSession(session);
    return true;
  }

  /// Marcar sesión como completada
  Future<bool> markSessionCompleted(int sessionId, String requestingUsername) async {
    final session = await _db.getSession(sessionId);
    if (session == null) return false;

    final isMember = await _db.isMember(session.groupId, requestingUsername);
    if (!isMember) return false;

    await _db.markSessionCompleted(sessionId);
    return true;
  }

  /// Eliminar sesión (solo admin)
  Future<bool> deleteSession(int sessionId, String requestingUsername) async {
    final session = await _db.getSession(sessionId);
    if (session == null) return false;

    final group = await _db.getGroup(session.groupId);
    if (group == null || group.adminUsername != requestingUsername) {
      return false;
    }

    await _db.deleteSession(sessionId);
    return true;
  }

  // ==================== VALORACIONES ====================

  /// Crear o actualizar valoración
  Future<bool> rateSession({
    required int sessionId,
    required String username,
    required int overallRating,
    int? historiaRating,
    int? ambientacionRating,
    int? jugabilidadRating,
    int? gameMasterRating,
    int? miedoRating,
    String? review,
  }) async {
    final session = await _db.getSession(sessionId);
    if (session == null) return false;

    // Verificar que es miembro del grupo
    final isMember = await _db.isMember(session.groupId, username);
    if (!isMember) return false;

    final rating = SessionRating(
      sessionId: sessionId,
      username: username,
      overallRating: overallRating,
      historiaRating: historiaRating,
      ambientacionRating: ambientacionRating,
      jugabilidadRating: jugabilidadRating,
      gameMasterRating: gameMasterRating,
      miedoRating: miedoRating,
      review: review,
    );

    await _db.createRating(rating);
    return true;
  }

  /// Obtener valoraciones de una sesión
  Future<List<SessionRating>> getSessionRatings(int sessionId) async {
    return await _db.getSessionRatings(sessionId);
  }

  /// Obtener valoración de un usuario en una sesión
  Future<SessionRating?> getUserRating(int sessionId, String username) async {
    return await _db.getUserRating(sessionId, username);
  }

  /// Obtener puntuación promedio de una sesión
  Future<Map<String, dynamic>> getSessionAverageRating(int sessionId) async {
    return await _db.getSessionAverageRating(sessionId);
  }

  // ==================== FOTOS ====================

  /// Subir foto a una sesión
  Future<bool> addPhoto({
    required int sessionId,
    required String username,
    required String photoPath,
    String? caption,
  }) async {
    final session = await _db.getSession(sessionId);
    if (session == null) return false;

    // Verificar que es miembro del grupo
    final isMember = await _db.isMember(session.groupId, username);
    if (!isMember) return false;

    final photo = SessionPhoto(
      sessionId: sessionId,
      username: username,
      photoPath: photoPath,
      caption: caption,
    );

    await _db.addPhoto(photo);
    return true;
  }

  /// Obtener fotos de una sesión
  Future<List<SessionPhoto>> getSessionPhotos(int sessionId) async {
    return await _db.getSessionPhotos(sessionId);
  }

  /// Eliminar foto (solo quien la subió o admin del grupo)
  Future<bool> deletePhoto(int photoId, int sessionId, String requestingUsername) async {
    final photos = await _db.getSessionPhotos(sessionId);
    final photo = photos.firstWhere((p) => p.id == photoId, orElse: () => throw Exception('Photo not found'));

    // Verificar permisos: solo el dueño o el admin pueden eliminar
    if (photo.username != requestingUsername) {
      final session = await _db.getSession(sessionId);
      if (session == null) return false;

      final group = await _db.getGroup(session.groupId);
      if (group == null || group.adminUsername != requestingUsername) {
        return false;
      }
    }

    await _db.deletePhoto(photoId);
    return true;
  }

  // ==================== RANKING ====================

  /// Obtener ranking del grupo
  Future<List<Map<String, dynamic>>> getGroupRanking(int groupId) async {
    return await _db.getGroupRanking(groupId);
  }

  // ==================== INVITACIONES ====================

  /// Enviar invitación a un usuario para unirse al grupo
  Future<bool> sendInvitation({
    required int groupId,
    required String recipientUsername,
    required String senderUsername,
    String? message,
  }) async {
    // Verificar que el sender es admin
    final group = await _db.getGroup(groupId);
    if (group == null || group.adminUsername != senderUsername) {
      return false;
    }

    // Verificar que el destinatario no sea ya miembro
    final isMember = await _db.isMember(groupId, recipientUsername);
    if (isMember) {
      return false;
    }

    final invitation = GroupInvitation(
      groupId: groupId,
      groupName: group.name,
      senderUsername: senderUsername,
      recipientUsername: recipientUsername,
      message: message,
    );

    await _db.createInvitation(invitation);
    return true;
  }

  /// Obtener invitaciones pendientes de un usuario
  Future<List<GroupInvitation>> getPendingInvitations(String username) async {
    return await _db.getPendingInvitations(username);
  }

  /// Obtener número de invitaciones pendientes
  Future<int> getPendingInvitationsCount(String username) async {
    return await _db.getPendingInvitationsCount(username);
  }

  /// Aceptar invitación
  Future<bool> acceptInvitation(int invitationId, String username) async {
    final invitations = await _db.getPendingInvitations(username);
    final invitation = invitations.where((i) => i.id == invitationId).firstOrNull;

    if (invitation == null || invitation.recipientUsername != username) {
      return false;
    }

    // Añadir como miembro
    await _db.addMember(GroupMember(
      groupId: invitation.groupId,
      username: username,
    ));

    // Actualizar estado de la invitación
    await _db.updateInvitationStatus(invitationId, 'accepted');
    return true;
  }

  /// Rechazar invitación
  Future<bool> rejectInvitation(int invitationId, String username) async {
    final invitations = await _db.getPendingInvitations(username);
    final invitation = invitations.where((i) => i.id == invitationId).firstOrNull;

    if (invitation == null || invitation.recipientUsername != username) {
      return false;
    }

    await _db.updateInvitationStatus(invitationId, 'rejected');
    return true;
  }

  /// Obtener invitaciones enviadas de un grupo
  Future<List<GroupInvitation>> getGroupInvitations(int groupId) async {
    return await _db.getGroupInvitations(groupId);
  }
}
