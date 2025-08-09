import 'order.dart';

class Family {
  final int familyId;
  final String name;
  final int orderId;
  final Order? order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Family({
    required this.familyId,
    required this.name,
    required this.orderId,
    this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      familyId: json['family_id'] as int,
      name: json['name'] as String,
      orderId: json['order_id'] as int,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'name': name,
      'order_id': orderId,
      'order': order?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class FamilyResponse {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int familyId;
  final String name;
  final int orderId;

  FamilyResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.familyId,
    required this.name,
    required this.orderId,
  });

  factory FamilyResponse.fromJson(Map<String, dynamic> json) {
    return FamilyResponse(
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      familyId: json['family_id'],
      name: json['name'],
      orderId: json['order_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'family_id': familyId,
      'name': name,
      'order_id': orderId,
    };
  }
}
