import 'package:flutter/foundation.dart';
import '../models/notify.dart';
import 'base_api_service.dart';

class NotifyService {
  static final NotifyService _instance = NotifyService._internal();
  factory NotifyService() => _instance;
  NotifyService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<Notify> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.put<dynamic>(
        '/notify/update/$notificationId',
        {'is_read': true},
      );

      if (kDebugMode) {
        debugPrint('Mark as read response: $response');
      }

      if (response == null) {
        throw Exception('Không nhận được phản hồi từ server');
      }

      if (response is Map<String, dynamic>) {
        if (response['data'] != null) {
          return Notify.fromJson(response['data']);
        }
        return Notify.fromJson(response);
      } else {
        throw Exception('Định dạng phản hồi không hợp lệ');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error marking notification as read: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiService.delete('/notify/$notificationId');
      // Nếu không có exception, coi như xóa thành công
      return;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting notification: $e');
      }
      rethrow;
    }
  }

  Future<List<Notify>> getNotifyByUser([int? id]) async {
    if (kDebugMode) {
      debugPrint('Fetching notifications from API...');
    }

    try {
      final userId = id;
      if (userId == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      if (kDebugMode) {
        debugPrint('Fetching notifications for user ID: $userId...');
      }

      final response = await _apiService.get<dynamic>('/notify/$userId');

      if (kDebugMode) {
        debugPrint('Notifications response: $response');
      }

      if (response == null) {
        throw Exception('Không nhận được phản hồi từ server');
      }

      List<dynamic> notificationsJson;
      if (response is Map<String, dynamic>) {
        if (response['data'] != null) {
          notificationsJson = response['data'] as List<dynamic>;
        } else {
          throw Exception('Không tìm thấy dữ liệu thông báo');
        }
      } else if (response is List) {
        notificationsJson = response;
      } else {
        throw Exception('Định dạng phản hồi không hợp lệ');
      }

      return notificationsJson.map((json) => Notify.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in getNotifyByUser: $e');
      }
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/notify/read-all', {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all notifications as read: $e');
      }
      rethrow;
    }
  }
}
