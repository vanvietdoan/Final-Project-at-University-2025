class Notify {
  final int notifyId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  Notify({
    required this.notifyId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
  });

  factory Notify.fromJson(Map<String, dynamic> json) {
    return Notify(
      notifyId: json['notify_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'notify_id': notifyId,
    'title': title,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_read': isRead,
  };
}

class NotifyResponse {
  final int notifyId;
  final int userId;
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  NotifyResponse({
    required this.notifyId,
    required this.userId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifyResponse.fromJson(Map<String, dynamic> json) {
    return NotifyResponse(
      notifyId: json['notify_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notify_id': notifyId,
      'user_id': userId,
      'title': title,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
