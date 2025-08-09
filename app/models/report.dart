class Report {
  final int? reportId;
  final String? plantName;
  final String? plantEnglishName;
  final String? plantDescription;
  final String? plantInstructions;
  final String? plantBenefits;
  final int? plantSpeciesId;
  final String? propose;
  final String? summary;
  final int? status;
  final String? proof;
  final int? plantId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    this.reportId,
    this.plantName,
    this.plantEnglishName,
    this.plantDescription,
    this.plantInstructions,
    this.plantBenefits,
    this.plantSpeciesId,
    this.propose,
    this.summary,
    this.status,
    this.proof,
    this.plantId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] as int?,
      plantName: json['plant_name'] as String?,
      plantEnglishName: json['plant_english_name'] as String?,
      plantDescription: json['plant_description'] as String?,
      plantInstructions: json['plant_instructions'] as String?,
      plantBenefits: json['plant_benefits'] as String?,
      plantSpeciesId: json['plant_species_id'] as int?,
      propose: json['propose'] as String?,
      summary: json['summary'] as String?,
      status: json['status'] as int?,
      proof: json['proof'] as String?,
      plantId: json['plant_id'] as int?,
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'plant_name': plantName,
      'plant_english_name': plantEnglishName,
      'plant_description': plantDescription,
      'plant_instructions': plantInstructions,
      'plant_benefits': plantBenefits,
      'plant_species_id': plantSpeciesId,
      'propose': propose,
      'summary': summary,
      'status': status,
      'proof': proof,
      'plant_id': plantId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class SpeciesResponse {
  final String createdAt;
  final String updatedAt;
  final int speciesId;
  final String name;
  final int genusId;
  final String propose;
  final String summary;
  final int status;
  final String proof;
  final int plantId;
  final int userId;

  SpeciesResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.speciesId,
    required this.name,
    required this.genusId,
    required this.propose,
    required this.summary,
    required this.status,
    required this.proof,
    required this.plantId,
    required this.userId,
  });

  factory SpeciesResponse.fromJson(Map<String, dynamic> json) {
    return SpeciesResponse(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      speciesId: json['species_id'],
      name: json['name'],
      genusId: json['genus_id'],
      propose: json['propose'],
      summary: json['summary'],
      status: json['status'],
      proof: json['proof'],
      plantId: json['plant_id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'species_id': speciesId,
      'name': name,
      'genus_id': genusId,
      'propose': propose,
      'summary': summary,
      'status': status,
      'proof': proof,
      'plant_id': plantId,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
