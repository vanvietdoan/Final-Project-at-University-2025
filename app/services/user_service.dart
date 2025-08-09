import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import 'base_api_service.dart';
import 'dart:io';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final BaseApiService _apiService = BaseApiService();
  final _dio = dio.Dio();

  /// Get user profile by ID
  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/$userId',
      );
      if (response['data'] != null) {
        return User.fromJson(response['data']);
      }
      throw Exception('Không tìm thấy thông tin người dùng');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Remove null values from user data
      final cleanUserData = Map<String, dynamic>.from(userData);
      if (cleanUserData['user'] != null) {
        final user = Map<String, dynamic>.from(cleanUserData['user']);
        user.removeWhere((key, value) => value == null);
        cleanUserData['user'] = user;
      }

      if (kDebugMode) {
        debugPrint('📤 Cleaned user data: $cleanUserData');
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        '/users/$userId',
        cleanUserData,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  /// Get users list with pagination
  Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users?page=$page&limit=$limit',
      );
      final List<dynamic> usersJson = response['data'] as List<dynamic>;
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách người dùng: $e');
      }
      rethrow;
    }
  }

  /// Register user

  /// Search users
  Future<List<User>> searchUsers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/search?q=$query&page=$page&limit=$limit',
      );
      final List<dynamic> usersJson = response['data'] as List<dynamic>;
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tìm kiếm người dùng: $e');
      }
      rethrow;
    }
  }

  /// Change user password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _apiService.post<Map<String, dynamic>>('/auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi đổi mật khẩu: $e');
      }

      // Check if the error is due to invalid old password
      if (e.toString().contains('Invalid old password')) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }

      rethrow;
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post<Map<String, dynamic>>('/auth/forgot-password', {
        'email': email,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi quên mật khẩu: $e');
      }
      rethrow;
    }
  }

  /// Upload avatar image
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split('/').last;

      // Create form data with proper content type
      final formData = dio.FormData.fromMap({
        'avatar': await dio.MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      if (kDebugMode) {
        debugPrint('📤 Uploading avatar: $fileName');
        debugPrint('📤 Token: ${_apiService.token}');
      }

      // Configure Dio for file upload
      _dio.options.headers = {
        'Authorization': 'Bearer ${_apiService.token}',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '${BaseApiService.baseUrl}/upload/avatar',
        data: formData,
        options: dio.Options(
          validateStatus: (status) {
            return status! < 500;
          },
          followRedirects: true,
          maxRedirects: 5,
        ),
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            debugPrint(
              '📤 Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      if (kDebugMode) {
        debugPrint('📥 Upload response status: ${response.statusCode}');
        debugPrint('📥 Upload response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('Không nhận được phản hồi từ server');
        }
        return response.data!;
      } else {
        final errorMessage = response.data?['message'] ?? 'Lỗi tải lên ảnh';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tải lên ảnh đại diện: $e');
      }
      rethrow;
    }
  }

  /// Upload proof document
  Future<Map<String, dynamic>> uploadProof(String filePath) async {
    try {
      final fileName = filePath.split('/').last;

      final formData = dio.FormData.fromMap({
        'proof': await dio.MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      });

      if (kDebugMode) {
        debugPrint('📤 Uploading proof: $fileName');
        debugPrint('📤 Token: ${_apiService.token}');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '${BaseApiService.baseUrl}/upload/proof',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer ${_apiService.token}',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (kDebugMode) {
        debugPrint('📥 Upload response status: ${response.statusCode}');
        debugPrint('📥 Upload response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ?? {};
      } else {
        throw Exception(response.data?['message'] ?? 'Lỗi tải lên giấy tờ');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tải lên giấy tờ chứng minh: $e');
      }
      rethrow;
    }
  }
}
