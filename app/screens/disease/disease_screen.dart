import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/disease_service.dart';
import '../../models/disease.dart';
import 'disease_detail_screen.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  final DiseaseService _diseaseService = DiseaseService();
  List<Disease> _diseases = [];
  List<Disease> _filteredDiseases = [];
  List<String> _symptoms = [];
  List<String> _selectedSymptoms = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showFilter = false;
  int _currentPage = 0;
  static const int _cardsPerPage = 12;

  List<Disease> get _paginatedDiseases {
    final startIndex = _currentPage * _cardsPerPage;
    final endIndex = startIndex + _cardsPerPage;
    return _filteredDiseases.length > startIndex
        ? _filteredDiseases.sublist(
            startIndex,
            endIndex > _filteredDiseases.length
                ? _filteredDiseases.length
                : endIndex)
        : [];
  }

  int get _totalPages => (_filteredDiseases.length / _cardsPerPage).ceil();

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    try {
      setState(() => _isLoading = true);
      final diseases = await _diseaseService.getDiseases();

      final allSymptoms = diseases
          .where((d) => d.symptoms != null)
          .map((d) => d.symptoms!.split(','))
          .expand((symptoms) => symptoms)
          .map((symptom) => symptom.trim())
          .where((symptom) => symptom.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _diseases = diseases;
        _filteredDiseases = diseases;
        _symptoms = allSymptoms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _filterDiseases() {
    setState(() {
      _filteredDiseases = _diseases.where((disease) {
        final matchesSearch =
            disease.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (disease.symptoms
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false);

        final matchesSymptoms = _selectedSymptoms.isEmpty ||
            _selectedSymptoms.every((symptom) =>
                disease.symptoms
                    ?.toLowerCase()
                    .contains(symptom.toLowerCase()) ??
                false);

        return matchesSearch && matchesSymptoms;
      }).toList();
      _currentPage = 0; // Reset to first page when filtering
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
      _filterDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bệnh....',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            _filterDiseases();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() => _showFilter = !_showFilter);
                        },
                        icon: Icon(
                          _showFilter
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                          color: _showFilter ? Colors.green : Colors.grey,
                        ),
                        tooltip: _showFilter ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
                      ),
                    ],
                  ),
                  if (_showFilter) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Tất cả'),
                          selected: _selectedSymptoms.isEmpty,
                          onSelected: (selected) {
                            setState(() => _selectedSymptoms.clear());
                            _filterDiseases();
                          },
                        ),
                        ..._symptoms.map((symptom) => FilterChip(
                              label: Text(symptom),
                              selected: _selectedSymptoms.contains(symptom),
                              onSelected: (selected) => _toggleSymptom(symptom),
                            )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDiseases.isEmpty
                      ? const Center(
                          child: Text('Không tìm thấy bệnh phù hợp'),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _paginatedDiseases.length,
                                itemBuilder: (context, index) {
                                  final disease = _paginatedDiseases[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DiseaseDetailScreen(
                                              diseaseId: disease.disease_id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (disease.images.isNotEmpty)
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                                child: Image.network(
                                                  disease.images.first.url
                                                      .replaceAll('http://',
                                                          'https://'),
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    debugPrint(
                                                        'Error loading disease image: $error');
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.error_outline,
                                                          size: 30,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              disease.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_totalPages > 1)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _currentPage > 0
                                          ? _previousPage
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                      color: _currentPage > 0
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    Text(
                                      'Trang ${_currentPage + 1} / $_totalPages',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _currentPage < _totalPages - 1
                                          ? _nextPage
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                      color: _currentPage < _totalPages - 1
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 2,
      ),
    );
  }
}
