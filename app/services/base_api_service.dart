import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BaseApiService {
  //static const String baseUrl = 'http://157.20.58.220:2204/api';
  //static const String baseUrl = 'http://localhost:2204/api';
  static const String baseUrl = 'https://medicalplant.apivui.click/api';

  static const Duration timeout = Duration(seconds: 30);

  // Singleton pattern
  static final BaseApiService _instance = BaseApiService._internal();
  factory BaseApiService() => _instance;
  BaseApiService._internal();

  // Auth token storage
  String? _token;

  // Get auth token
  String? get token => _token;

  // Set auth token
  void setToken(String token) {
    _token = token;
  }

  // Clear auth data
  void clearToken() {
    _token = null;
  }

  // Get headers with auth token
  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Generic GET method
  Future<T> get<T>(String endpoint, {Map<String, String>? headers}) async {
    if (kDebugMode) {
      debugPrint('🌐 GET ${endpoint} : $baseUrl$endpoint');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {..._headers(), ...?headers},
          )
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint('📥 Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as T;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        clearToken();
        _navigateToLogin();
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error: $e');
      }
      rethrow;
    }
  }

  // Generic POST method
  Future<T> post<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 POST: $baseUrl$endpoint');
      debugPrint('📤 Request data: $data');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {..._headers(), ...?headers},
            body: json.encode(data),
          )
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint('📥 Response ${endpoint} status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          throw Exception('Empty response body');
        }
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Null ${endpoint} response data');
        }
        return data as T;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        clearToken();
        _navigateToLogin();
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Failed to post data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error ${endpoint} : $e');
      }
      rethrow;
    }
  }

  // Generic PUT method
  Future<T> put<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 PUT ${endpoint} : $baseUrl$endpoint');
      debugPrint('📤 Request data ${endpoint} : $data');
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {..._headers(), ...?headers},
            body: json.encode(data),
          )
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint('📥 Response ${endpoint} status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty ${endpoint} response body');
        }
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Null ${endpoint} response data');
        }
        return data as T;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        clearToken();
        _navigateToLogin();
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Failed to update ${endpoint} data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error ${endpoint} : $e');
      }
      rethrow;
    }
  }

  // Generic DELETE method
  Future<T> delete<T>(String endpoint, {Map<String, String>? headers}) async {
    if (kDebugMode) {
      debugPrint('🌐 DELETE ${endpoint} : $baseUrl$endpoint');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {..._headers(), ...?headers},
          )
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint('📥 Response ${endpoint} status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) {
          return {} as T;
        }
        final data = json.decode(response.body);
        return data as T;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        clearToken();
        _navigateToLogin();
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ??
              'Failed to delete ${endpoint} data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error ${endpoint} : $e');
      }
      rethrow;
    }
  }

  // // Get list of plants
  // Future<List<Plant>> getPlants() async {
  //   try {
  //     final response = await get<List<dynamic>>('/plants');
  //     return response.map((json) => Plant.fromJson(json)).toList();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('Error fetching plants: $e');
  //     }
  //     rethrow;
  //   }
  // }

  // // Get plant details by ID
  // Future<Plant> getPlantById(int id) async {
  //   try {
  //     final response = await get<Map<String, dynamic>>('/plants/$id');
  //     if (response == null) {
  //       throw Exception('Không tìm thấy thông tin cây thuốc');
  //     }
  //     return Plant.fromJson(response);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('Error fetching plant details: $e');
  //     }
  //     rethrow;
  //   }
  // }

  void _navigateToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
