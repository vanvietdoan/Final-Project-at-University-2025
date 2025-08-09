class Species {
  final int speciesId;
  final String name;
  final int genusId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Species({
    required this.speciesId,
    required this.name,
    required this.genusId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      speciesId: json['species_id'] ?? 0,
      name: json['name'] ?? '',
      genusId: json['genus_id'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'species_id': speciesId,
        'name': name,
        'genus_id': genusId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class SpeciesResponse {
  final String createdAt;
  final String updatedAt;
  final int speciesId;
  final String name;
  final int genusId;

  SpeciesResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.speciesId,
    required this.name,
    required this.genusId,
  });

  factory SpeciesResponse.fromJson(Map<String, dynamic> json) {
    return SpeciesResponse(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      speciesId: json['species_id'],
      name: json['name'],
      genusId: json['genus_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'species_id': speciesId,
      'name': name,
      'genus_id': genusId,
    };
  }
}
