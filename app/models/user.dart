import 'role.dart';

class User {
  final int id;
  final String full_name;
  final String title;
  final String proof;
  final String specialty;
  final bool active;
  final String avatar;
  final String email;
  final Role? role;

  User({
    required this.id,
    required this.full_name,
    required this.title,
    required this.proof,
    required this.specialty,
    required this.active,
    required this.avatar,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userId = json['id'] ?? json['user_id'];
    if (userId == null || userId == 0) {
      throw Exception('User ID is missing or invalid');
    }

    Role? role;
    if (json['role'] != null) {
      if (json['role'] is String) {
        // For login response where role is just a string
        role = Role(
          roleId: 0, // Default role ID for string roles
          name: json['role'],
        );
      } else {
        // For user profile where role is an object
        role = Role.fromJson(json['role']);
      }
    }

    return User(
      id: userId,
      full_name: json['full_name'] ?? '',
      title: json['title'] ?? '',
      proof: json['proof'] ?? '',
      specialty: json['specialty'] ?? '',
      active: json['active'] ?? false,
      avatar: json['avatar'] ?? '',
      email: json['email'] ?? '',
      role: role,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': full_name,
    'title': title,
    'proof': proof,
    'specialty': specialty,
    'active': active,
    'avatar': avatar,
    'email': email,
    'role': role?.toJson(),
  };

  User copyWith({
    int? id,
    String? full_name,
    String? email,
    String? title,
    String? specialty,
    bool? active,
    String? avatar,
    String? proof,
    Role? role,
  }) {
    return User(
      id: id ?? this.id,
      full_name: full_name ?? this.full_name,
      email: email ?? this.email,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      active: active ?? this.active,
      avatar: avatar ?? this.avatar,
      proof: proof ?? this.proof,
      role: role ?? this.role,
    );
  }
}

class UserRegister {
  final String email;
  final String password;
  final String fullName;
  final String specialty;
  final String workplace;

  UserRegister({
    required this.email,
    required this.password,
    required this.fullName,
    required this.specialty,
    required this.workplace,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'specialty': specialty,
      'workplace': workplace,
    };
  }
}
