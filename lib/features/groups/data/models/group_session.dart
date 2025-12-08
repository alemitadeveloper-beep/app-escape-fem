/// Modelo para representar una sesión de escape room en un grupo
class GroupSession {
  final int? id;
  final int groupId;
  final int escapeRoomId; // ID del escape room de la tabla words
  final String escapeRoomName;
  final DateTime scheduledDate;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  GroupSession({
    this.id,
    required this.groupId,
    required this.escapeRoomId,
    required this.escapeRoomName,
    required this.scheduledDate,
    this.notes,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'escapeRoomId': escapeRoomId,
      'escapeRoomName': escapeRoomName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupSession.fromMap(Map<String, dynamic> map) {
    return GroupSession(
      id: map['id'],
      groupId: map['groupId'],
      escapeRoomId: map['escapeRoomId'],
      escapeRoomName: map['escapeRoomName'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  GroupSession copyWith({
    int? id,
    int? groupId,
    int? escapeRoomId,
    String? escapeRoomName,
    DateTime? scheduledDate,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GroupSession(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      escapeRoomId: escapeRoomId ?? this.escapeRoomId,
      escapeRoomName: escapeRoomName ?? this.escapeRoomName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
