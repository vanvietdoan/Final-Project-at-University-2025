import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import '../../widgets/custom_bottom_nav.dart';

class ReportCreateScreen extends StatefulWidget {
  final int userId;
  final int? plantId;

  const ReportCreateScreen({
    super.key,
    required this.userId,
    this.plantId,
  });

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportService = ReportService();
  final _plantService = PlantService();
  bool _isLoading = false;
  List<Plant> _plants = [];
  Plant? _selectedPlant;

  final _plantNameController = TextEditingController();
  final _plantEnglishNameController = TextEditingController();
  final _plantDescriptionController = TextEditingController();
  final _plantInstructionsController = TextEditingController();
  final _plantBenefitsController = TextEditingController();
  final _proposeController = TextEditingController();
  final _summaryController = TextEditingController();
  final _proofController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      final plants = await _plantService.getPlants();
      setState(() {
        _plants = plants;
        if (widget.plantId != null) {
          _selectedPlant = plants.firstWhere(
            (plant) => plant.plantId == widget.plantId,
            orElse: () => plants.first,
          );
          _fillAllFields();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách cây: ${e.toString()}')),
        );
      }
    }
  }

  void _fillAllFields() {
    if (_selectedPlant == null) return;

    setState(() {
      _plantNameController.text = _selectedPlant?.name ?? '';
      _plantEnglishNameController.text = _selectedPlant?.englishName ?? '';
      _plantDescriptionController.text = _selectedPlant?.description ?? '';
      _plantInstructionsController.text = _selectedPlant?.instructions ?? '';
      _plantBenefitsController.text = _selectedPlant?.benefits ?? '';
    });
  }

  void _fillField(TextEditingController controller, String value) {
    setState(() {
      controller.text = value;
    });
  }

  void _clearField(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  Widget _buildFieldWithButtons({
    required TextEditingController controller,
    required String label,
    required String? plantValue,
    int maxLines = 1,
    required String? Function(String?)? validator,
    bool showClearButton = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: plantValue != null
                  ? IconButton(
                      icon: const Icon(Icons.content_copy, size: 20),
                      onPressed: () => _fillField(controller, plantValue),
                      tooltip: 'Điền thông tin từ cây',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
            ),
            maxLines: maxLines,
            validator: validator,
          ),
        ),
        if (showClearButton)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _clearField(controller),
            tooltip: 'Xóa nội dung',
          ),
      ],
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantEnglishNameController.dispose();
    _plantDescriptionController.dispose();
    _plantInstructionsController.dispose();
    _plantBenefitsController.dispose();
    _proposeController.dispose();
    _summaryController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newReport = Report(
        reportId: 0,
        plantName: _plantNameController.text,
        plantEnglishName: _plantEnglishNameController.text,
        plantDescription: _plantDescriptionController.text,
        plantInstructions: _plantInstructionsController.text,
        plantBenefits: _plantBenefitsController.text,
        plantSpeciesId: _selectedPlant?.speciesId ?? 0,
        propose: _proposeController.text,
        summary: _summaryController.text,
        status: null, // Chờ duyệt
        proof: _proofController.text,
        plantId: _selectedPlant?.plantId ?? 0,
        userId: widget.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _reportService.createReport(newReport);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo báo cáo: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo báo cáo mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plant selection dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Plant>(
                      value: _selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Chọn cây',
                        border: OutlineInputBorder(),
                      ),
                      items: _plants.map((plant) {
                        return DropdownMenuItem<Plant>(
                          value: plant,
                          child: Text(plant.name ?? 'Không có tên'),
                        );
                      }).toList(),
                      onChanged: (Plant? plant) {
                        setState(() {
                          _selectedPlant = plant;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn cây' : null,
                    ),
                  ),
                  if (_selectedPlant != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _fillAllFields,
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Điền tất cả'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // Form fields with fill/clear buttons
              _buildFieldWithButtons(
                controller: _plantNameController,
                label: 'Tên cây',
                plantValue: _selectedPlant?.name,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập tên cây' : null,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _plantEnglishNameController,
                label: 'Tên tiếng Anh',
                plantValue: _selectedPlant?.englishName,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Vui lòng nhập tên tiếng Anh'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _plantDescriptionController,
                label: 'Mô tả',
                plantValue: _selectedPlant?.description,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _plantInstructionsController,
                label: 'Hướng dẫn',
                plantValue: _selectedPlant?.instructions,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập hướng dẫn' : null,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _plantBenefitsController,
                label: 'Lợi ích',
                plantValue: _selectedPlant?.benefits,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập lợi ích' : null,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _proposeController,
                label: 'Đề xuất',
                plantValue: null,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập đề xuất' : null,
                showClearButton: false,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _summaryController,
                label: 'Tóm tắt',
                plantValue: null,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập tóm tắt' : null,
                showClearButton: false,
              ),
              const SizedBox(height: 16),
              _buildFieldWithButtons(
                controller: _proofController,
                label: 'Bằng chứng',
                plantValue: null,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập bằng chứng' : null,
                showClearButton: false,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Tạo báo cáo'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
