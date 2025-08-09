import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import 'base_api_service.dart';

class PlantService {
  static final PlantService _instance = PlantService._internal();
  factory PlantService() => _instance;
  PlantService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Get plant by ID
  Future<Plant> getPlantById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/plants/$id');
      if (response is Map<String, dynamic>) {
        return Plant.fromJson(response['data'] ?? response);
      }
      return Plant.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin cây: $e');
      }
      rethrow;
    }
  }

  /// Get list of plants
  Future<List<Plant>> getPlants({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/plants?page=$page&limit=$limit',
      );
      List<dynamic> plantsJson;
      if (response is Map<String, dynamic>) {
        plantsJson = response['data'] as List<dynamic>;
      } else {
        plantsJson = response as List<dynamic>;
      }
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Plant>> getNewPlants() async {
    try {
      final response = await _apiService.get<dynamic>(
        '/plants/new-plants',
      );

      List<dynamic> plantsJson;
      if (response is Map<String, dynamic>) {
        plantsJson = response['data'] as List<dynamic>;
      } else {
        plantsJson = response as List<dynamic>;
      }
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
   Future<List<Plant>> getMultiUsePlants() async {
    try {
      final response = await _apiService.get<dynamic>(
        '/plants/multiple-benefits',
      );
      
      List<dynamic> plantsJson;
      if (response is Map<String, dynamic>) {
        plantsJson = response['data'] as List<dynamic>;
      } else {
        plantsJson = response as List<dynamic>;
      }
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search plants
  Future<List<Plant>> searchPlants(String query,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/plants/search?q=$query&page=$page&limit=$limit',
      );
      List<dynamic> plantsJson;
      if (response is Map<String, dynamic>) {
        plantsJson = response['data'] as List<dynamic>;
      } else {
        plantsJson = response as List<dynamic>;
      }
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get plants with filter
  Future<List<Plant>> getPlantSearch(String query) async {
    try {
      final response = await _apiService.get<dynamic>(
        '/plants/filter-plant?$query',
      );
      List<dynamic> plantsJson;
      if (response is Map<String, dynamic>) {
        plantsJson = response['data'] as List<dynamic>;
      } else {
        plantsJson = response as List<dynamic>;
      }
      return plantsJson.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
