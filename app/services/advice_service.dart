import 'package:flutter/foundation.dart';
import '../models/advice.dart';
import 'base_api_service.dart';

class AdviceService {
  static final AdviceService _instance = AdviceService._internal();
  factory AdviceService() => _instance;
  AdviceService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Lấy danh sách lời khuyên với phân trang
  Future<List<Advice>> getAdvices({int page = 1, int limit = 10}) async {
    try {
      final response =
          await _apiService.get<dynamic>('/advice?page=$page&limit=$limit');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Advice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách lời khuyên: $e');
      }
      rethrow;
    }
  }

  /// Lấy lời khuyên theo ID
  Future<Advice> getAdviceById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/advice/$id');
      return response is Map<String, dynamic>
          ? Advice.fromJson(response['data'])
          : Advice.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy lời khuyên theo ID: $e');
      }
      rethrow;
    }
  }

  /// Lấy danh sách lời khuyên theo cây thuốc
  Future<List<Advice>> getAdvicesByPlant(int plantId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService
          .get<dynamic>('/advice/plant/$plantId?page=$page&limit=$limit');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Advice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy lời khuyên theo cây thuốc: $e');
      }
      rethrow;
    }
  }

  Future<List<Advice>> getAdvicesByUser(int userId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService
          .get<dynamic>('/advice/user/$userId?page=$page&limit=$limit');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Advice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy lời khuyên theo người dùng: $e');
      }
      rethrow;
    }
  }

  /// Lấy danh sách lời khuyên theo bệnh
  Future<List<Advice>> getAdvicesByDisease(int diseaseId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService
          .get<dynamic>('/advice/disease/$diseaseId?page=$page&limit=$limit');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Advice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy lời khuyên theo bệnh: $e');
      }
      rethrow;
    }
  }

  Future<List<ListUsetIDMostAdvice>> getUserMostAdvice() async {
    try {
      final response =
          await _apiService.get<dynamic>('/advice/user/most-advice');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => ListUsetIDMostAdvice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách lời khuyên theo bệnh: $e');
      }
      rethrow;
    }
  }

  /// Tìm kiếm lời khuyên
  Future<List<Advice>> searchAdvices(String query,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService
          .get<dynamic>('/advice/search?q=$query&page=$page&limit=$limit');
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Advice.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tìm kiếm lời khuyên: $e');
      }
      rethrow;
    }
  }

  /// Xoá lời khuyên
  Future<void> deleteAdvice(int id) async {
    try {
      await _apiService.delete<dynamic>('/advice/$id');
      if (kDebugMode) {
        debugPrint('✅ Đã xoá lời khuyên với ID $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi xoá lời khuyên: $e');
      }
      rethrow;
    }
  }

  /// Tạo lời khuyên mới
  Future<Advice> createAdvice({
    required String title,
    required String content,
    required int plantId,
    required int diseaseId,
    required int userId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'title': title,
        'content': content,
        'plant_id': plantId,
        'disease_id': diseaseId,
        'user_id': userId,
      };

      final response = await _apiService.post<dynamic>(
        '/advice',
        requestData,
      );

      if (response == null) {
        throw Exception('Không nhận được phản hồi từ server');
      }

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Advice.fromJson(response['data']);
        }
        return Advice.fromJson(response);
      }

      throw Exception('Định dạng phản hồi không hợp lệ');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tạo lời khuyên: $e');
      }
      rethrow;
    }
  }

  /// Cập nhật lời khuyên
  Future<Advice> updateAdvice(
    int id, {
    String? title,
    String? content,
    int? plantId,
    int? diseaseId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {};
      if (title != null) requestData['title'] = title;
      if (content != null) requestData['content'] = content;
      if (plantId != null) requestData['plant_id'] = plantId;
      if (diseaseId != null) requestData['disease_id'] = diseaseId;

      final response = await _apiService.put<dynamic>(
        '/advice/$id',
        requestData,
      );

      if (response is Map<String, dynamic>) {
        return Advice.fromJson(response['data'] ?? response);
      }
      return Advice.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật lời khuyên: $e');
      }
      rethrow;
    }
  }
}
