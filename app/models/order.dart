class Order {
  final int orderId;
  final String name;
  final int classId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.orderId,
    required this.name,
    required this.classId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] as int,
      name: json['name'] as String,
      classId: json['class_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'name': name,
      'class_id': classId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderResponse {
  final String createdAt;
  final String updatedAt;
  final int orderId;
  final String name;
  final int classId;

  OrderResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.orderId,
    required this.name,
    required this.classId,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      orderId: json['order_id'],
      name: json['name'],
      classId: json['class_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_id': orderId,
      'name': name,
      'class_id': classId,
    };
  }
}
