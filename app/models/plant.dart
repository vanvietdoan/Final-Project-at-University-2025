class PlantImage {
  final int pictureId;
  final String url;

  PlantImage({
    required this.pictureId,
    required this.url,
  });

  factory PlantImage.fromJson(Map<String, dynamic> json) {
    return PlantImage(
      pictureId: json['picture_id'] ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'picture_id': pictureId,
        'url': url,
      };
}

class Plant {
  final int plantId;
  final String name;
  final String? englishName;
  final String? description;
  final String? benefits;
  final String? instructions;
  final int? speciesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PlantImage>? images;

  Plant({
    required this.plantId,
    required this.name,
    this.englishName,
    this.description,
    this.benefits,
    this.instructions,
    this.speciesId,
    this.createdAt,
    this.updatedAt,
    this.images,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'],
      name: json['name'],
      englishName: json['english_name'],
      description: json['description']?.toString(),
      benefits: json['benefits']?.toString(),
      instructions: json['instructions']?.toString(),
      speciesId: json['species_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => PlantImage.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'plant_id': plantId,
        'name': name,
        'english_name': englishName,
        if (description != null) 'description': description,
        if (benefits != null) 'benefits': benefits,
        if (instructions != null) 'instructions': instructions,
        if (speciesId != null) 'species_id': speciesId,
        if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
        if (images != null) 'images': images!.map((e) => e.toJson()).toList(),
      };
}
