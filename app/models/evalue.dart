import 'user.dart';

class Evalue {
  final int id;
  final String content;
  final int rating;
  final DateTime createdAt;
  final User? user;
  final int? adviceId;

  Evalue({
    required this.id,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.user,
    this.adviceId,
  });

  factory Evalue.fromJson(Map<String, dynamic> json) {
    return Evalue(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      adviceId: json['advice_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      if (adviceId != null) 'advice_id': adviceId,
    };
  }

  Evalue copyWith({
    int? id,
    String? content,
    int? rating,
    DateTime? createdAt,
    User? user,
    int? adviceId,
  }) {
    return Evalue(
      id: id ?? this.id,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      adviceId: adviceId ?? this.adviceId,
    );
  }
}

class Advice {
  final int adviceId;
  final String? createdAt;
  final String? updatedAt;
  final String? title;
  final String? content;
  final String? instructions;
  final Plant? plant;
  final Disease? disease;
  final User? user;

  Advice({
    required this.adviceId,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.content,
    this.instructions,
    this.plant,
    this.disease,
    this.user,
  });

  factory Advice.createDefault() {
    return Advice(
      adviceId: 0,
      createdAt: '',
      updatedAt: '',
      title: '',
      content: '',
      instructions: '',
      plant: Plant(plantId: 0, name: ''),
      disease: Disease(diseaseId: 0, name: ''),
      user: User(userId: 0, fullName: '', title: '', avatar: ''),
    );
  }

  factory Advice.fromJson(Map<String, dynamic> json) {
    return Advice(
      adviceId: json['advice_id'] ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      title: json['title']?.toString(),
      content: json['content']?.toString(),
      instructions: json['instructions']?.toString(),
      plant: json['plant'] != null ? Plant.fromJson(json['plant']) : null,
      disease:
          json['disease'] != null ? Disease.fromJson(json['disease']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advice_id': adviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (instructions != null) 'instructions': instructions,
      if (plant != null) 'plant': plant!.toJson(),
      if (disease != null) 'disease': disease!.toJson(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class Plant {
  final int plantId;
  final String name;

  Plant({required this.plantId, required this.name});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'plant_id': plantId, 'name': name};
  }
}

class Disease {
  final int diseaseId;
  final String name;

  Disease({required this.diseaseId, required this.name});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      diseaseId: json['disease_id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'disease_id': diseaseId, 'name': name};
  }
}

class ListUsetIDMostAdvice {
  final int userId;
  final int totalAdvice;

  ListUsetIDMostAdvice({required this.userId, required this.totalAdvice});

  factory ListUsetIDMostAdvice.fromJson(Map<String, dynamic> json) {
    return ListUsetIDMostAdvice(
      userId: json['user_id'] ?? 0,
      totalAdvice: json['total_advice'] ?? 0,
    );
  }
}

class User {
  final int userId;
  final String fullName;
  final String title;
  final String avatar;

  User({
    required this.userId,
    required this.fullName,
    required this.title,
    this.avatar = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      title: json['title'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'title': title,
      'avatar': avatar,
    };
  }
}
