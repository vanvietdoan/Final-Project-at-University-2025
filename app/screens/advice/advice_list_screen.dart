import 'package:flutter/material.dart';
import '../../models/advice.dart';
import '../../models/user.dart';
import '../../services/advice_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'advice_edit_screen.dart';
import 'advice_create_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

class ManageAdviceScreen extends StatefulWidget {
  final int expertId;

  const ManageAdviceScreen({
    super.key,
    required this.expertId,
  });

  @override
  State<ManageAdviceScreen> createState() => _ManageAdviceScreenState();
}

class _ManageAdviceScreenState extends State<ManageAdviceScreen> {
  final _adviceService = AdviceService();
  final _searchController = TextEditingController();

  List<Advice> _advices = [];
  List<Advice> _filteredAdvices = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  int? _selectedPlantId;
  int? _selectedDiseaseId;

  // Get unique plants and diseases from advices
  List<Map<String, dynamic>> get _uniquePlants {
    final Map<int, Map<String, dynamic>> uniqueMap = {};
    for (var advice in _advices) {
      if (advice.plant != null) {
        uniqueMap[advice.plant!.plantId] = {
          'id': advice.plant!.plantId,
          'name': advice.plant!.name,
        };
      }
    }
    return uniqueMap.values.toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  List<Map<String, dynamic>> get _uniqueDiseases {
    final Map<int, Map<String, dynamic>> uniqueMap = {};
    for (var advice in _advices) {
      if (advice.disease != null) {
        uniqueMap[advice.disease!.diseaseId] = {
          'id': advice.disease!.diseaseId,
          'name': advice.disease!.name,
        };
      }
    }
    return uniqueMap.values.toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  @override
  void initState() {
    super.initState();
    _loadAdvices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdvices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('expertId in manage advice screen: ${widget.expertId}');
      final advices = await _adviceService.getAdvicesByUser(widget.expertId);
      setState(() {
        _advices = advices;
        _filterAdvices();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAdvices() {
    setState(() {
      _filteredAdvices = _advices.where((advice) {
        // Search in title and content
        final matchesSearch = _searchQuery.isEmpty ||
            (advice.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            (advice.content
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);

        // Filter by plant
        final matchesPlant = _selectedPlantId == null ||
            advice.plant?.plantId == _selectedPlantId;

        // Filter by disease
        final matchesDisease = _selectedDiseaseId == null ||
            advice.disease?.diseaseId == _selectedDiseaseId;

        return matchesSearch && matchesPlant && matchesDisease;
      }).toList();

      // Sort by date (newest first)
      _filteredAdvices.sort((a, b) {
        final dateA =
            a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(0);
        final dateB =
            b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(0);
        return dateB.compareTo(dateA);
      });
    });
  }

  Future<void> _editAdvice(Advice advice) async {
    _navigateToEditScreen(advice);
  }

  Future<void> _deleteAdvice(Advice advice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lời khuyên này?'),
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
        await _adviceService.deleteAdvice(advice.adviceId);
        _loadAdvices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa lời khuyên thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa lời khuyên: ${e.toString()}'),
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

  void _navigateToEditScreen(Advice advice) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdviceEditScreen(
          advice: advice,
          expertId: widget.expertId,
        ),
      ),
    );

    if (result == true) {
      _loadAdvices(); // Reload the list if advice was updated
    }
  }

  void _navigateToCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdviceCreateScreen(
          expertId: widget.expertId,
        ),
      ),
    );

    if (result == true) {
      _loadAdvices(); // Reload the list if new advice was created
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lời khuyên'),
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
                                _filterAdvices();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterAdvices();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filter dropdowns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedPlantId,
                        isExpanded: true,
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
                              child: Text(
                                plant['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPlantId = value;
                            _filterAdvices();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Disease filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedDiseaseId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Lọc theo bệnh',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tất cả bệnh'),
                          ),
                          ..._uniqueDiseases.map((disease) {
                            return DropdownMenuItem<int>(
                              value: disease['id'] as int,
                              child: Text(
                                disease['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDiseaseId = value;
                            _filterAdvices();
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
                              onPressed: _loadAdvices,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _filteredAdvices.isEmpty
                        ? const Center(
                            child: Text('Không tìm thấy lời khuyên nào'),
                          )
                        : ListView.builder(
                            itemCount: _filteredAdvices.length,
                            itemBuilder: (context, index) {
                              final advice = _filteredAdvices[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    advice.title ?? 'Không có tiêu đề',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cây: ${advice.plant?.name ?? 'Không xác định'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Bệnh: ${advice.disease?.name ?? 'Không xác định'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Ngày tạo: ${_formatDate(advice.createdAt)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editAdvice(advice),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _deleteAdvice(advice),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            advice.content ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _editAdvice(advice),
                                                icon: const Icon(Icons.edit,
                                                    size: 18),
                                                label: const Text('Chỉnh sửa'),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _deleteAdvice(advice),
                                                icon: const Icon(Icons.delete,
                                                    size: 18),
                                                label: const Text('Xóa'),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
