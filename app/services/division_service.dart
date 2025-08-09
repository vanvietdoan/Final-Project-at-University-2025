import 'package:flutter/foundation.dart';
import '../models/division.dart';
import 'base_api_service.dart';

class DivisionService {
  static final DivisionService _instance = DivisionService._internal();
  factory DivisionService() => _instance;
  DivisionService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Division>> getDivisions({int page = 1, int limit = 10}) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching divisions with page=$page, limit=$limit');
      }

      final response = await _apiService.get<dynamic>(
        '/divisions?page=$page&limit=$limit',
      );

      if (kDebugMode) {
        debugPrint('Raw division response: $response');
        debugPrint('Response type: ${response.runtimeType}');
      }

      List<dynamic> divisionsJson;
      if (response is List<dynamic>) {
        divisionsJson = response;
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      if (kDebugMode) {
        debugPrint('Processed divisions: ${divisionsJson.length} items');
      }

      return divisionsJson.map((json) => Division.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching divisions: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  Future<Division> getDivisionById(int id) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching division with id: $id');
      }

      final response = await _apiService.get<dynamic>('/divisions/$id');

      if (kDebugMode) {
        debugPrint('Raw division detail response: $response');
        debugPrint('Response type: ${response.runtimeType}');
      }

      if (response is Map<String, dynamic>) {
        return Division.fromJson(response);
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching division detail: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }
}
