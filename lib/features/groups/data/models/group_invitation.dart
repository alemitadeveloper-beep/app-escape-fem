/// Modelo para representar una invitación a un grupo
class GroupInvitation {
  final int? id;
  final int groupId;
  final String groupName; // Para mostrar en notificaciones
  final String senderUsername; // Quien envió la invitación
  final String recipientUsername; // Quien recibe la invitación
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message; // Mensaje opcional del admin

  GroupInvitation({
    this.id,
    required this.groupId,
    required this.groupName,
    required this.senderUsername,
    required this.recipientUsername,
    DateTime? createdAt,
    this.status = 'pending',
    this.message,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'senderUsername': senderUsername,
      'recipientUsername': recipientUsername,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'message': message,
    };
  }

  factory GroupInvitation.fromMap(Map<String, dynamic> map) {
    return GroupInvitation(
      id: map['id'],
      groupId: map['groupId'],
      groupName: map['groupName'],
      senderUsername: map['senderUsername'],
      recipientUsername: map['recipientUsername'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'],
      message: map['message'],
    );
  }

  GroupInvitation copyWith({
    int? id,
    int? groupId,
    String? groupName,
    String? senderUsername,
    String? recipientUsername,
    DateTime? createdAt,
    String? status,
    String? message,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      senderUsername: senderUsername ?? this.senderUsername,
      recipientUsername: recipientUsername ?? this.recipientUsername,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
