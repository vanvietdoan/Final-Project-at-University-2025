import 'package:flutter/foundation.dart';
import '../models/genus.dart';
import 'base_api_service.dart';

class GenusService {
  static final GenusService _instance = GenusService._internal();
  factory GenusService() => _instance;
  GenusService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Genus>> getGenuses({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/genus?page=$page&limit=$limit',
      );
      List<dynamic> generaJson;
      if (response is Map<String, dynamic>) {
        generaJson = response['data'] as List<dynamic>;
      } else {
        generaJson = response as List<dynamic>;
      }
      return generaJson.map((json) => Genus.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách chi: $e');
      }
      rethrow;
    }
  }

  Future<Genus> getGenusById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/genus/$id');
      if (response is Map<String, dynamic>) {
        return Genus.fromJson(response['data']);
      }
      return Genus.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin chi: $e');
      }
      rethrow;
    }
  }
}
