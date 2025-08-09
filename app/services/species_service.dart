import 'package:flutter/foundation.dart';
import '../models/species.dart';
import 'base_api_service.dart';

class SpeciesService {
  static final SpeciesService _instance = SpeciesService._internal();
  factory SpeciesService() => _instance;
  SpeciesService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Species>> getSpecies({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/species?page=$page&limit=$limit',
      );
      List<dynamic> speciesJson;
      if (response is Map<String, dynamic>) {
        speciesJson = response['data'] as List<dynamic>;
      } else {
        speciesJson = response as List<dynamic>;
      }
      return speciesJson.map((json) => Species.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách loài: $e');
      }
      rethrow;
    }
  }

  Future<Species> getSpeciesById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/species/$id');
      if (response is Map<String, dynamic>) {
        return Species.fromJson(response['data']);
      }
      return Species.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin loài: $e');
      }
      rethrow;
    }
  }
}
