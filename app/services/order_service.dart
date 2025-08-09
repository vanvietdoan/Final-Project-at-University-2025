import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'base_api_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get list of orders
  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get<dynamic>('/orders');
      List<dynamic> ordersJson;
      if (response is Map<String, dynamic>) {
        ordersJson = response['data'] as List<dynamic>;
      } else {
        ordersJson = response as List<dynamic>;
      }
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách bộ: $e');
      }
      rethrow;
    }
  }

  Future<Order> getOrderById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/orders/$id');
      if (response is Map<String, dynamic>) {
        return Order.fromJson(response['data']);
      }
      return Order.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin bộ: $e');
      }
      rethrow;
    }
  }
}
