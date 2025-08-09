import 'package:flutter/foundation.dart';
import '../models/family.dart';
import 'base_api_service.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get list of families
  Future<List<Family>> getFamilies() async {
    try {
      final response = await _apiService.get<dynamic>('/family');
      List<dynamic> familiesJson;
      if (response is Map<String, dynamic>) {
        familiesJson = response['data'] as List<dynamic>;
      } else {
        familiesJson = response as List<dynamic>;
      }
      return familiesJson.map((json) => Family.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách họ: $e');
      }
      rethrow;
    }
  }

  Future<Family> getFamilyById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/family/$id');
      if (response is Map<String, dynamic>) {
        return Family.fromJson(response['data']);
      }
      return Family.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin họ: $e');
      }
      rethrow;
    }
  }
}
