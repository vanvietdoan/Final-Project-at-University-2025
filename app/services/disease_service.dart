import 'package:flutter/foundation.dart';
import '../models/disease.dart';
import 'base_api_service.dart';

class DiseaseService {
  static final DiseaseService _instance = DiseaseService._internal();
  factory DiseaseService() => _instance;
  DiseaseService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get list of diseases
  Future<List<Disease>> getDiseases({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/diseases?page=$page&limit=$limit',
      );

      return response.map((e) => Disease.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách bệnh: $e');
      }
      rethrow;
    }
  }

  /// Get disease by ID
  Future<Disease> getDiseaseById(int id) async {
    try {
      final response =
          await _apiService.get<Map<String, dynamic>>('/diseases/$id');
      return Disease.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin bệnh: $e');
      }
      rethrow;
    }
  }

  /// Search diseases
  Future<List<Disease>> searchDiseases(String query,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/diseases/search?q=$query&page=$page&limit=$limit',
      );

      return response
          .map((e) => Disease.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tìm kiếm bệnh: $e');
      }
      rethrow;
    }
  }
}
