class Role {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int roleId;
  final String name;

  Role({
    this.createdAt,
    this.updatedAt,
    required this.roleId,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      roleId: json['role_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role_id': roleId,
      'name': name,
    };
  }
} 