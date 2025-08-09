import 'package:flutter/foundation.dart';
import 'dart:async';
import 'base_api_service.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final BaseApiService _apiService = BaseApiService();
  User? _currentUser;
  final _avatarController = StreamController<String>.broadcast();

  User? get currentUser => _currentUser;
  Stream<String> get avatarStream => _avatarController.stream;

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        {'email': email, 'password': password},
      );

      // Store the token
      final token = response['token'] as String;
      _apiService.setToken(token);

      // Get user data from login response
      final userData = response['user'] as Map<String, dynamic>;
      debugPrint('User data from login response: $userData');
      debugPrint('User ID from login response: ${userData['id']}');

      // Get complete user profile using the ID from login response
      final userProfile = await getUserProfile(userData['id']);
      debugPrint('User profile after getUserProfile: ${userProfile.toJson()}');
      _currentUser = userProfile;

      return _currentUser!;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      throw Exception('Đăng nhập thất bại');
    }
  }

  Future<Map<String, dynamic>> register(UserRegister user) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/register',
        user.toJson(),
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi đăng ký: $e');
      }
      rethrow;
    }
  }

  Future<User> getUserProfile(int userId) async {
    try {
      debugPrint('Getting user profile for ID: $userId');
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/$userId',
      );
      debugPrint('User profile response: $response');

      // Check if response has data field, otherwise use the response directly
      if (response['data'] != null) {
        final userProfile = User.fromJson(response['data']);
        debugPrint(
          'User profile after getUserProfile: ${userProfile.toJson()}',
        );
        return userProfile;
      } else {
        return User.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    if (!email.contains('@')) {
      throw Exception('Email không hợp lệ');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Get the current user's email
      final userEmail = _currentUser?.email ?? '';

      await _apiService.post<Map<String, dynamic>>('/auth/logout', {
        'email': userEmail,
      });

      _apiService.clearToken();
      _currentUser = null;
      if (kDebugMode) {
        debugPrint('✅ Đã đăng xuất');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi đăng xuất: $e');
      }
      // Still clear local data even if API call fails
      _apiService.clearToken();
      _currentUser = null;
    }
  }

  void updateAvatar(String avatarUrl) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatar: avatarUrl);
      _avatarController.add(avatarUrl);
      notifyListeners();
      if (kDebugMode) {
        debugPrint('✅ Đã cập nhật avatar: $avatarUrl');
      }
    }
  }

  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
    if (kDebugMode) {
      debugPrint('✅ Đã cập nhật thông tin người dùng');
      debugPrint('Current user avatar: ${_currentUser?.avatar}');
    }
  }

  @override
  void dispose() {
    _avatarController.close();
    super.dispose();
  }
}
