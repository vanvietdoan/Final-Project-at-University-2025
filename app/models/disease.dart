
class DiseaseImage {
  final int picture_id;
  final String name;
  final String url;
  final String? description;
  final int? plant_id;
  final int? disease_id;
  final String? created_at;
  final String? updated_at;

  DiseaseImage({
    required this.picture_id,
    required this.name,
    required this.url,
    this.description,
    this.plant_id,
    this.disease_id,
    this.created_at,
    this.updated_at,
  });

  factory DiseaseImage.fromJson(Map<String, dynamic> json) {
    return DiseaseImage(
      picture_id: json['picture_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString(),
      plant_id: json['plant_id'],
      disease_id: json['disease_id'],
      created_at: json['created_at']?.toString(),
      updated_at: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'picture_id': picture_id,
        'name': name,
        'url': url,
        if (description != null) 'description': description,
        if (plant_id != null) 'plant_id': plant_id,
        if (disease_id != null) 'disease_id': disease_id,
        if (created_at != null) 'created_at': created_at,
        if (updated_at != null) 'updated_at': updated_at,
      };
}

class Disease {
  final int disease_id;
  final String name;
  final String? description;
  final String? symptoms;
  final String? instructions;
  final List<DiseaseImage> images;
  final String? created_at;
  final String? updated_at;

  Disease({
    required this.disease_id,
    required this.name,
    this.description,
    this.symptoms,
    this.instructions,
    required this.images,
    this.created_at,
    this.updated_at,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      disease_id: json['disease_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      symptoms: json['symptoms']?.toString(),
      instructions: json['instructions']?.toString(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => DiseaseImage.fromJson(e))
              .toList() ??
          [],
      created_at: json['created_at']?.toString(),
      updated_at: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'disease_id': disease_id,
        'name': name,
        if (description != null) 'description': description,
        if (symptoms != null) 'symptoms': symptoms,
        if (instructions != null) 'instructions': instructions,
        'images': images.map((e) => e.toJson()).toList(),
        if (created_at != null) 'created_at': created_at,
        if (updated_at != null) 'updated_at': updated_at,
      };
}
