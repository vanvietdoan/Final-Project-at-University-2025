import 'package:flutter/foundation.dart';
import '../models/class.dart';
import 'base_api_service.dart';

class ClassService {
  static final ClassService _instance = ClassService._internal();
  factory ClassService() => _instance;
  ClassService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get list of classes
  Future<List<Class>> getClasses() async {
    try {
      final response = await _apiService.get<dynamic>('/classes');
      List<dynamic> classesJson;
      if (response is Map<String, dynamic>) {
        classesJson = response['data'] as List<dynamic>;
      } else {
        classesJson = response as List<dynamic>;
      }
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách lớp: $e');
      }
      rethrow;
    }
  }

  Future<Class> getClassById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/classes/$id');
      if (response is Map<String, dynamic>) {
        return Class.fromJson(response['data']);
      }
      return Class.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin lớp: $e');
      }
      rethrow;
    }
  }
}
