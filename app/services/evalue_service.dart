import 'package:flutter/foundation.dart';
import '../models/evalue.dart';
import 'base_api_service.dart';

class EvalueService {
  static final EvalueService _instance = EvalueService._internal();
  factory EvalueService() => _instance;
  EvalueService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Evalue>> getEvalues({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/evalue?page=$page&limit=$limit',
      );
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Evalue.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách đánh giá: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteEvalue(int id) async {
    try {
      await _apiService.delete<dynamic>('/evalue/$id');
      if (kDebugMode) {
        debugPrint('✅ Đã xoá đánh giá với ID $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi xoá đánh giá: $e');
      }
      rethrow;
    }
  }

  Future<List<Evalue>> getEvaluesByUser(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/evalue/user/$userId?page=$page&limit=$limit',
      );
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Evalue.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy đánh giá theo người dùng: $e');
      }
      rethrow;
    }
  }

  Future<Evalue> createEvalue({
    required String content,
    required int rating,
    required int userId,
    int? adviceId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'content': content,
        'rating': rating,
        'user_id': userId,
      };
      if (adviceId != null) requestData['advice_id'] = adviceId;

      final response = await _apiService.post<dynamic>('/evalue', requestData);

      if (response == null) {
        throw Exception('Không nhận được phản hồi từ server');
      }

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Evalue.fromJson(response['data']);
        }
        return Evalue.fromJson(response);
      }

      throw Exception('Định dạng phản hồi không hợp lệ');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tạo đánh giá: $e');
      }
      rethrow;
    }
  }

  Future<Evalue> updateEvalue(
    int id, {
    String? content,
    int? rating,
    int? adviceId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {};
      if (content != null) requestData['content'] = content;
      if (rating != null) requestData['rating'] = rating;
      if (adviceId != null) requestData['advice_id'] = adviceId;

      final response = await _apiService.put<dynamic>(
        '/evalue/$id',
        requestData,
      );

      if (response == null) {
        throw Exception('Không nhận được phản hồi từ server');
      }

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Evalue.fromJson(response['data']);
        }
        return Evalue.fromJson(response);
      }

      throw Exception('Định dạng phản hồi không hợp lệ');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật đánh giá: $e');
      }
      rethrow;
    }
  }

  Future<List<Evalue>> getEvalueByAdviceId(
    int adviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/evalue/advice/$adviceId?page=$page&limit=$limit',
      );
      final List<dynamic> data =
          response is Map<String, dynamic> ? response['data'] : response;
      return data.map((json) => Evalue.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy đánh giá theo lời khuyên: $e');
      }
      rethrow;
    }
  }
}
