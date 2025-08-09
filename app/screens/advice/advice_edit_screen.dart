import 'package:flutter/material.dart';
import '../../models/advice.dart' as advice_model;
import '../../models/plant.dart' as plant_model;
import '../../models/disease.dart' as disease_model;
import '../../services/advice_service.dart';
import '../../services/plant_service.dart';
import '../../services/disease_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class AdviceEditScreen extends StatefulWidget {
  final advice_model.Advice advice;
  final int expertId;
  final bool fromPlantDetail;

  const AdviceEditScreen({
    super.key,
    required this.advice,
    required this.expertId,
    this.fromPlantDetail = false,
  });

  @override
  State<AdviceEditScreen> createState() => _AdviceEditScreenState();
}

class _AdviceEditScreenState extends State<AdviceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _adviceService = AdviceService();
  final _plantService = PlantService();
  final _diseaseService = DiseaseService();

  List<plant_model.Plant> _plants = [];
  List<disease_model.Disease> _diseases = [];
  plant_model.Plant? _selectedPlant;
  disease_model.Disease? _selectedDisease;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load plants and diseases
      final plants = await _plantService.getPlants();
      final diseases = await _diseaseService.getDiseases();

      // Set initial values
      _titleController.text = widget.advice.title ?? '';
      _contentController.text = widget.advice.content ?? '';

      // Find matching plant in the loaded plants list
      if (widget.advice.plant != null) {
        _selectedPlant = plants.firstWhere(
          (p) => p.plantId == widget.advice.plant!.plantId,
          orElse: () => plants.first,
        );
      }

      // Find matching disease in the loaded diseases list
      if (widget.advice.disease != null) {
        _selectedDisease = diseases.firstWhere(
          (d) => d.disease_id == widget.advice.disease!.diseaseId,
          orElse: () => diseases.first,
        );
      }

      setState(() {
        _plants = plants;
        _diseases = diseases;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAdvice() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _adviceService.updateAdvice(
        widget.advice.adviceId,
        title: _titleController.text,
        content: _contentController.text,
        plantId: _selectedPlant?.plantId ?? 0,
        diseaseId: _selectedDisease?.disease_id ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật lời khuyên thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Always return true to indicate success, regardless of where it was opened from
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật lời khuyên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa lời khuyên'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tiêu đề';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<plant_model.Plant>(
                      value: _selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Cây thuốc',
                        border: OutlineInputBorder(),
                      ),
                      items: _plants.map((plant) {
                        return DropdownMenuItem<plant_model.Plant>(
                          value: plant,
                          child: Text(plant.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlant = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn cây thuốc';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<disease_model.Disease>(
                      value: _selectedDisease,
                      decoration: const InputDecoration(
                        labelText: 'Bệnh',
                        border: OutlineInputBorder(),
                      ),
                      items: _diseases.map((disease) {
                        return DropdownMenuItem<disease_model.Disease>(
                          value: disease,
                          child: Text(disease.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDisease = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn bệnh';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAdvice,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cập nhật lời khuyên',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
