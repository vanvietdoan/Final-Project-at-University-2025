import 'family.dart';

class Genus {
  final int genusId;
  final String name;
  final int familyId;
  final Family? family;
  final DateTime createdAt;
  final DateTime updatedAt;

  Genus({
    required this.genusId,
    required this.name,
    required this.familyId,
    this.family,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Genus.fromJson(Map<String, dynamic> json) {
    return Genus(
      genusId: json['genus_id'] as int,
      name: json['name'] as String,
      familyId: json['family_id'] as int,
      family: json['family'] != null
          ? Family.fromJson(json['family'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genus_id': genusId,
      'name': name,
      'family_id': familyId,
      'family': family?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GenusResponse {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int genusId;
  final String name;
  final int familyId;

  GenusResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.genusId,
    required this.name,
    required this.familyId,
  });

  factory GenusResponse.fromJson(Map<String, dynamic> json) {
    return GenusResponse(
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      genusId: json['genus_id'],
      name: json['name'],
      familyId: json['family_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'genus_id': genusId,
      'name': name,
      'family_id': familyId,
    };
  }
}

// Filter class for Genus
class GenusFilter {
  final String? searchQuery;
  final int? familyId;
  final DateTime? startDate;
  final DateTime? endDate;

  GenusFilter({
    this.searchQuery,
    this.familyId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }

    if (familyId != null) {
      params['family_id'] = familyId;
    }

    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }

    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }

    return params;
  }
}
