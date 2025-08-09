import 'package:flutter/foundation.dart';
import '../models/report.dart';
import 'base_api_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final BaseApiService _apiService = BaseApiService();

  Future<List<Report>> getReports() async {
    try {
      final response = await _apiService.get<dynamic>('/report');
      if (kDebugMode) {
        debugPrint('Raw response type: ${response.runtimeType}');
        debugPrint('Raw response: $response');
      }

      List<dynamic> reportsJson;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          reportsJson = response['data'] as List<dynamic>;
        } else {
          throw Exception('Response does not contain data field');
        }
      } else if (response is List) {
        reportsJson = response;
      } else {
        throw Exception('Invalid response format');
      }

      return reportsJson.map((json) {
        try {
          return Report.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error parsing report: $e');
            debugPrint('Problematic JSON: $json');
          }
          rethrow;
        }
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<Report> getReportById(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/report/$id');
      if (kDebugMode) {
        debugPrint('Raw response type: ${response.runtimeType}');
        debugPrint('Raw response: $response');
      }

      Map<String, dynamic> reportJson;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          reportJson = response['data'] as Map<String, dynamic>;
        } else {
          reportJson = response;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return Report.fromJson(reportJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<List<Report>> getUserReports(int userId) async {
    try {
      final response = await _apiService.get<dynamic>('/report/user/$userId');
      if (kDebugMode) {
        debugPrint('Raw response type: ${response.runtimeType}');
        debugPrint('Raw response: $response');
      }

      List<dynamic> reportsJson;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          reportsJson = response['data'] as List<dynamic>;
        } else {
          throw Exception('Response does not contain data field');
        }
      } else if (response is List) {
        reportsJson = response;
      } else {
        throw Exception('Invalid response format');
      }

      return reportsJson.map((json) {
        try {
          return Report.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error parsing report: $e');
            debugPrint('Problematic JSON: $json');
          }
          rethrow;
        }
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy danh sách báo cáo của người dùng: $e');
      }
      rethrow;
    }
  }

  Future<Report> createReport(Report report) async {
    try {
      final response = await _apiService.post('/report', report.toJson());
      if (kDebugMode) {
        debugPrint('Raw response type: ${response.runtimeType}');
        debugPrint('Raw response: $response');
      }

      Map<String, dynamic> reportJson;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          reportJson = response['data'] as Map<String, dynamic>;
        } else {
          reportJson = response;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return Report.fromJson(reportJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tạo báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<void> updateReportStatus(int id, String status) async {
    try {
      await _apiService.put('/report/$id/status', {'status': status});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật trạng thái báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<Report> getReportByUserId(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/report/user/$id');
      if (response is Map<String, dynamic>) {
        return Report.fromJson(response['data']);
      }
      return Report.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<Report> getReportByPlantId(int id) async {
    try {
      final response = await _apiService.get<dynamic>('/report/plant/$id');
      if (response is Map<String, dynamic>) {
        return Report.fromJson(response['data']);
      }
      return Report.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi lấy thông tin báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<Report> updateReport(int id, Report report) async {
    try {
      final response = await _apiService.put('/report/$id', report.toJson());
      if (kDebugMode) {
        debugPrint('Raw response type: ${response.runtimeType}');
        debugPrint('Raw response: $response');
      }

      Map<String, dynamic> reportJson;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          reportJson = response['data'] as Map<String, dynamic>;
        } else {
          reportJson = response;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return Report.fromJson(reportJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật báo cáo: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteReport(int id) async {
    try {
      await _apiService.delete('/report/$id');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi xóa báo cáo: $e');
      }
      rethrow;
    }
  }
}
