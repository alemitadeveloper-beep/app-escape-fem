/// Modelo para representar un grupo de escape rooms
class EscapeGroup {
  final int? id;
  final String name;
  final String description;
  final String adminUsername; // Quien creó el grupo
  final String? routeName; // Ej: "Ruta País Vasco"
  final DateTime createdAt;
  final bool isActive;
  final bool isPublic; // true = cualquiera puede unirse, false = solo por invitación

  EscapeGroup({
    this.id,
    required this.name,
    required this.description,
    required this.adminUsername,
    this.routeName,
    DateTime? createdAt,
    this.isActive = true,
    this.isPublic = true, // Por defecto público
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminUsername': adminUsername,
      'routeName': routeName,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'isPublic': isPublic ? 1 : 0,
    };
  }

  factory EscapeGroup.fromMap(Map<String, dynamic> map) {
    return EscapeGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      adminUsername: map['adminUsername'],
      routeName: map['routeName'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] == 1,
      isPublic: (map['isPublic'] ?? 1) == 1, // Default a público si no existe
    );
  }

  EscapeGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? adminUsername,
    String? routeName,
    DateTime? createdAt,
    bool? isActive,
    bool? isPublic,
  }) {
    return EscapeGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminUsername: adminUsername ?? this.adminUsername,
      routeName: routeName ?? this.routeName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
