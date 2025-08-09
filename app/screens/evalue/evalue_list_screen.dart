import 'package:flutter/material.dart';
import '../../models/evalue.dart';
import '../../services/evalue_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'evalue_create_screen.dart';
import 'evalue_edit_screen.dart';

class EvalueListScreen extends StatefulWidget {
  final int? userId;

  const EvalueListScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<EvalueListScreen> createState() => _EvalueListScreenState();
}

class _EvalueListScreenState extends State<EvalueListScreen> {
  final EvalueService _evalueService = EvalueService();
  final _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Evalue> _evalues = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvalues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvalues() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final evalues =
          widget.userId != null
              ? await _evalueService.getEvaluesByUser(widget.userId!)
              : await _evalueService.getEvalues();

      if (!mounted) return;

      setState(() {
        _evalues = evalues;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEvalue(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _evalueService.deleteEvalue(id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đánh giá thành công')),
      );

      _loadEvalues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa đánh giá: ${e.toString()}')),
      );
    }
  }

  Future<void> _navigateToEdit(Evalue evalue) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EvalueEditScreen(evalue: evalue)),
    );

    if (result == true) {
      _loadEvalues();
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const EvalueCreateScreen()),
    );

    if (result == true) {
      _loadEvalues();
    }
  }

  List<Evalue> get _filteredEvalues {
    if (_searchQuery.isEmpty) return _evalues;
    return _evalues
        .where(
          (evalue) =>
              evalue.content.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đánh giá'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvalues,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        tooltip: 'Tạo đánh giá mới',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEvalues,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                    : _filteredEvalues.isEmpty
                    ? const Center(child: Text('Không có đánh giá nào'))
                    : ListView.builder(
                      itemCount: _filteredEvalues.length,
                      itemBuilder: (context, index) {
                        final evalue = _filteredEvalues[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: ListTile(
                            title: Text(
                              evalue.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${evalue.rating}/5'),
                                  ],
                                ),
                                if (evalue.user != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16),
                                      const SizedBox(width: 4),
                                      Text(evalue.user!.fullName),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 4),
                                    Text(_formatDate(evalue.createdAt)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _navigateToEdit(evalue),
                                  tooltip: 'Chỉnh sửa',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteEvalue(evalue.id),
                                  tooltip: 'Xóa',
                                  color: Colors.red,
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
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
