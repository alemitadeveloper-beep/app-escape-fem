/// Modelo para representar un miembro de un grupo
class GroupMember {
  final int? id;
  final int groupId;
  final String username;
  final DateTime joinedAt;
  final bool isAdmin;

  GroupMember({
    this.id,
    required this.groupId,
    required this.username,
    DateTime? joinedAt,
    this.isAdmin = false,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'username': username,
      'joinedAt': joinedAt.toIso8601String(),
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      groupId: map['groupId'],
      username: map['username'],
      joinedAt: DateTime.parse(map['joinedAt']),
      isAdmin: map['isAdmin'] == 1,
    );
  }
}
