import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import 'package:intl/intl.dart';
import 'report_edit_screen.dart';
import 'report_create_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'package:flutter/foundation.dart';
import '../plants/plant_detail_screen.dart';
import '../../services/auth_service.dart';

class ManageReportScreen extends StatefulWidget {
  final int userId;

  const ManageReportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ManageReportScreen> createState() => _ManageReportScreenState();
}

class _ManageReportScreenState extends State<ManageReportScreen> {
  final _reportService = ReportService();
  final _plantService = PlantService();
  final _searchController = TextEditingController();
  final _authService = AuthService();

  List<Report> _reports = [];
  List<Report> _filteredReports = [];
  Map<int, String> _plantNames = {}; // Cache for plant names
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  int? _selectedPlantId;
  int? _selectedStatus;

  List<Map<String, dynamic>> get _uniquePlants {
    final Map<int, Map<String, dynamic>> uniqueMap = {};
    for (var report in _reports) {
      uniqueMap[report.plantId ?? 0] = {
        'id': report.plantId ?? 0,
        'name': report.plantName ?? '',
      };
    }
    return uniqueMap.values.toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        debugPrint('📥 Đang tải danh sách báo cáo cho user: ${widget.userId}');
      }
      final reports = await _reportService.getUserReports(widget.userId);

      // Load plant names for all reports
      for (var report in reports) {
        if (report.plantId != null &&
            !_plantNames.containsKey(report.plantId)) {
          try {
            final plant = await _plantService.getPlantById(report.plantId!);
            _plantNames[report.plantId!] = plant.name ?? 'Không có tên';
          } catch (e) {
            _plantNames[report.plantId!] = 'Không có tên';
            if (kDebugMode) {
              debugPrint('❌ Lỗi khi tải thông tin cây ${report.plantId}: $e');
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Đã tải ${reports.length} báo cáo');
      }

      if (!mounted) return;
      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi khi tải danh sách báo cáo: $e');
      }
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Không thể tải danh sách báo cáo. Vui lòng thử lại sau.';
        _isLoading = false;
      });
    }
  }

  void _filterReports() {
    setState(() {
      _filteredReports = _reports.where((report) {
        // Search in title and content
        final matchesSearch = _searchQuery.isEmpty ||
            (report.plantName?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()) ||
            (report.summary?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase());

        // Filter by plant
        final matchesPlant =
            _selectedPlantId == null || report.plantId == _selectedPlantId;

        // Filter by status
        final matchesStatus = _selectedStatus == null ||
            (_selectedStatus == -1 && report.status == null) ||
            report.status == _selectedStatus;

        final matches = matchesSearch && matchesPlant && matchesStatus;
        if (matches) {
          debugPrint('Report matches filter: ${report.plantName}');
        }
        return matches;
      }).toList();

      // Sort by date (newest first)
      _filteredReports.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      debugPrint('Filtered reports count: ${_filteredReports.length}');
    });
  }

  Future<void> _editReport(Report report) async {
    if (report.status != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Không thể chỉnh sửa báo cáo đã được duyệt hoặc đang duyệt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    debugPrint('Editing report: ${report.reportId} - ${report.plantName}');
    _navigateToEditScreen(report);
  }

  Future<void> _deleteReport(Report report) async {
    if (report.status != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa báo cáo đã được duyệt hoặc đang duyệt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    debugPrint(
        'Attempting to delete report: ${report.reportId} - ${report.plantName}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa báo cáo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _reportService.deleteReport(report.reportId ?? 0);
        _loadReports();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa báo cáo thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa báo cáo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case null:
        return 'Chờ duyệt';
      case 0:
        return 'Đang duyệt';
      case 1:
        return 'Đã duyệt';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case null:
        return Colors.orange;
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _navigateToEditScreen(Report report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportEditScreen(
          report: report,
          userId: widget.userId,
        ),
      ),
    );

    if (result == true) {
      _loadReports(); // Reload the list if report was updated
    }
  }

  void _navigateToCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportCreateScreen(
          userId: widget.userId,
        ),
      ),
    );

    if (result == true) {
      _loadReports(); // Reload the list if new report was created
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Danh sách báo cáo (${_filteredReports.length}/${_reports.length})'),
        actions: [
          if (_authService.currentUser != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportCreateScreen(
                      userId: _authService.currentUser!.id,
                    ),
                  ),
                );
                if (result == true) {
                  _loadReports();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tiêu đề hoặc nội dung',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _filterReports();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterReports();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filter dropdowns
                Row(
                  children: [
                    // Plant filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedPlantId,
                        decoration: const InputDecoration(
                          labelText: 'Lọc theo cây',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tất cả cây'),
                          ),
                          ..._uniquePlants.map((plant) {
                            return DropdownMenuItem<int>(
                              value: plant['id'] as int,
                              child: Text(plant['name'] as String),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPlantId = value;
                            _filterReports();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Tất cả trạng thái'),
                          ),
                          DropdownMenuItem<int?>(
                            value: -1, // Sử dụng -1 cho trạng thái chờ duyệt
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Chờ duyệt'),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int?>(
                            value: 0,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Đang duyệt'),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int?>(
                            value: 1,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Đã duyệt'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _filterReports();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadReports,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _filteredReports.isEmpty
                        ? const Center(
                            child: Text('Không tìm thấy báo cáo nào'),
                          )
                        : ListView.builder(
                            itemCount: _filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = _filteredReports[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  report.plantName ??
                                                      'Không có tên',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  report.plantEnglishName ??
                                                      'Không có tên tiếng Anh',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  report.status),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getStatusText(report.status),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Mô tả: ${report.plantDescription ?? 'Không có mô tả'}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(report.createdAt ?? DateTime.now())}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PlantDetailScreen(
                                                            plantId: report
                                                                    .plantId ??
                                                                0,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.eco,
                                                          color: Colors.green,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            _plantNames[report
                                                                    .plantId] ??
                                                                'Không có tên cây',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (report.status == null)
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () =>
                                                      _editReport(report),
                                                  tooltip: 'Chỉnh sửa',
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              if (report.status == null)
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () =>
                                                      _deleteReport(report),
                                                  tooltip: 'Xóa',
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
