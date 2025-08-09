class PlantClass {
  final int classId;
  final String name;
  final int divisionId;

  PlantClass({
    required this.classId,
    required this.name,
    required this.divisionId,
  });

  factory PlantClass.fromJson(Map<String, dynamic> json) {
    return PlantClass(
      classId: json['class_id'],
      name: json['name'],
      divisionId: json['division_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'name': name,
      'division_id': divisionId,
    };
  }
}

class Class {
  final int classId;
  final String name;
  final int divisionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.classId,
    required this.name,
    required this.divisionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      classId: json['class_id'] ?? 0,
      name: json['name'] ?? '',
      divisionId: json['division_id'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'name': name,
        'division_id': divisionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
