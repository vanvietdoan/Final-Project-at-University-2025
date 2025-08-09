import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/evalue.dart';
import '../../models/advice.dart' as advice_model;
import '../../services/evalue_service.dart';
import '../../services/advice_service.dart';

class EvalueEditScreen extends StatefulWidget {
  final Evalue evalue;

  const EvalueEditScreen({Key? key, required this.evalue}) : super(key: key);

  @override
  State<EvalueEditScreen> createState() => _EvalueEditScreenState();
}

class _EvalueEditScreenState extends State<EvalueEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _evalueService = EvalueService();
  final _adviceService = AdviceService();
  bool _isLoading = false;
  bool _isLoadingAdvice = true;
  List<advice_model.Advice> _advices = [];
  advice_model.Advice? _selectedAdvice;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.evalue.content;
    _rating = widget.evalue.rating.toDouble();
    _loadAdvices();
  }

  Future<void> _loadAdvices() async {
    try {
      final advices = await _adviceService.getAdvices();
      if (!mounted) return;

      setState(() {
        _advices = advices;
        _isLoadingAdvice = false;
        if (widget.evalue.adviceId != null) {
          _selectedAdvice = advices.firstWhere(
            (a) => a.adviceId == widget.evalue.adviceId,
            orElse: () => advices.first,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingAdvice = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Lỗi khi tải danh sách lời khuyên: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEvalue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedAdvice == null) {
        throw Exception('Vui lòng chọn lời khuyên');
      }

      await _evalueService.updateEvalue(
        widget.evalue.id,
        content: _contentController.text,
        rating: _rating.toInt(),
        adviceId: _selectedAdvice!.adviceId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật đánh giá thành công')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật đánh giá: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa đánh giá'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveEvalue,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: _isLoadingAdvice
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<advice_model.Advice>(
                      value: _selectedAdvice,
                      decoration: const InputDecoration(
                        labelText: 'Lời khuyên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      items: _advices.map((advice) {
                        return DropdownMenuItem<advice_model.Advice>(
                          value: advice,
                          child: Text(advice.title ?? 'Không có tiêu đề'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAdvice = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn lời khuyên';
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đánh giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 40,
                            glow: false,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ),
                        if (_rating > 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${_rating.toInt()}/5 sao',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveEvalue,
                      child: const Text('Lưu thay đổi'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
