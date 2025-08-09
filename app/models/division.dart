class Division {
  final int divisionId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Division({
    required this.divisionId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo từ JSON
  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      divisionId: json['division_id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'division_id': divisionId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
