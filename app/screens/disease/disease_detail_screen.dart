import 'package:flutter/material.dart';
import '../../models/disease.dart' as disease_model;
import '../../models/advice.dart' hide User;
import '../../models/user.dart';
import '../../models/evalue.dart' as evalue_model;
import '../../services/disease_service.dart';
import '../../services/advice_service.dart';
import '../../services/auth_service.dart';
import '../../services/evalue_service.dart';
import '../../services/user_service.dart';
import '../../screens/plants/plant_detail_screen.dart';
import '../../screens/profile/visit_profile.dart';
import '../../screens/advice/advice_create_screen.dart';
import '../../screens/advice/advice_edit_screen.dart';
import '../../screens/evalue/evalue_create_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/advice_list_widget.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final int diseaseId;

  const DiseaseDetailScreen({super.key, required this.diseaseId});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final DiseaseService _diseaseService = DiseaseService();
  final AdviceService _adviceService = AdviceService();
  final AuthService _authService = AuthService();
  disease_model.Disease? _disease;
  List<Advice> _advices = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCurrentUser();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final disease = await _diseaseService.getDiseaseById(widget.diseaseId);
      final advices = await _adviceService.getAdvicesByDisease(
        widget.diseaseId,
      );
      setState(() {
        _disease = disease;
        _advices = advices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_disease?.name ?? 'Chi tiết bệnh')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _disease == null
              ? const Center(child: Text('Không tìm thấy thông tin bệnh'))
              : Column(
                children: [
                  if (_disease!.images.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _disease!.images.length,
                        itemBuilder: (context, index) {
                          final image = _disease!.images[index];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  image.url.replaceAll('http://', 'https://'),
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  debugPrint(
                                    'Error loading disease image: $exception',
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DiseaseDetails(disease: _disease!),
                        ),
                        Expanded(
                          flex: 1,
                          child: AdviceListWidget(
                            advices: _advices,
                            diseaseId: widget.diseaseId,
                            onRefresh: _loadData,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}

class DiseaseDetails extends StatelessWidget {
  final disease_model.Disease disease;

  const DiseaseDetails({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disease.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (disease.symptoms != null) ...[
            const Text(
              'Triệu chứng:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(disease.symptoms!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],
          if (disease.description != null) ...[
            const Text(
              'Mô tả:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(disease.description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],
          if (disease.instructions != null) ...[
            const Text(
              'Hướng dẫn điều trị:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(disease.instructions!, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}
