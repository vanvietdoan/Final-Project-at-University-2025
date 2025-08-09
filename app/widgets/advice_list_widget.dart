import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/advice.dart' as advice_model;
import '../models/user.dart';
import '../models/evalue.dart' as evalue_model;
import '../services/advice_service.dart';
import '../services/auth_service.dart';
import '../services/evalue_service.dart';
import '../services/user_service.dart';
import '../screens/advice/advice_create_screen.dart';
import '../screens/advice/advice_edit_screen.dart';
import '../screens/evalue/evalue_create_screen.dart';
import '../screens/profile/visit_profile.dart';
import '../screens/plants/plant_detail_screen.dart';
import '../screens/disease/disease_detail_screen.dart';
import 'package:intl/intl.dart';

class AdviceListWidget extends StatefulWidget {
  final List<advice_model.Advice> advices;
  final int? plantId;
  final int? diseaseId;
  final VoidCallback? onRefresh;

  const AdviceListWidget({
    super.key,
    required this.advices,
    this.plantId,
    this.diseaseId,
    this.onRefresh,
  });

  @override
  State<AdviceListWidget> createState() => _AdviceListWidgetState();
}

class _AdviceListWidgetState extends State<AdviceListWidget> {
  final _authService = AuthService();
  late List<advice_model.Advice> _advices;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _advices = widget.advices;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _navigateToCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AdviceCreateScreen(
              expertId: _currentUser!.id,
              plantId: widget.plantId,
              diseaseId: widget.diseaseId,
              fromPlantDetail: widget.plantId != null,
            ),
      ),
    );

    if (result == true && mounted) {
      // Reload the advice list
      final advices =
          widget.plantId != null
              ? await AdviceService().getAdvicesByPlant(widget.plantId!)
              : await AdviceService().getAdvicesByDisease(widget.diseaseId!);
      setState(() {
        _advices = advices;
      });
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    }
  }

  Future<void> _navigateToEditScreen(advice_model.Advice advice) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AdviceEditScreen(
              advice: advice,
              expertId: _currentUser!.id,
              fromPlantDetail: widget.plantId != null,
            ),
      ),
    );

    if (result == true && mounted) {
      // Reload the advice list
      final advices =
          widget.plantId != null
              ? await AdviceService().getAdvicesByPlant(widget.plantId!)
              : await AdviceService().getAdvicesByDisease(widget.diseaseId!);
      setState(() {
        _advices = advices;
      });
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lời khuyên từ chuyên gia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_currentUser != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCreateScreen,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo lời khuyên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _advices.length,
            itemBuilder: (context, index) {
              return AdviceCard(
                advice: _advices[index],
                currentUserId: _currentUser?.id,
                onEdit: _navigateToEditScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdviceCard extends StatelessWidget {
  final advice_model.Advice advice;
  final int? currentUserId;
  final Function(advice_model.Advice) onEdit;

  const AdviceCard({
    super.key,
    required this.advice,
    this.currentUserId,
    required this.onEdit,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm - dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _ensureHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  Future<void> _showEvaluations(BuildContext context) async {
    final evalueService = EvalueService();
    final userService = UserService();
    final authService = AuthService();
    try {
      final evaluations = await evalueService.getEvalueByAdviceId(
        advice.adviceId,
      );
      if (!context.mounted) return;

      // Fetch user details for each evaluation
      final userDetails = <int, User>{};
      for (final evalue in evaluations) {
        if (evalue.user?.userId != null &&
            !userDetails.containsKey(evalue.user!.userId)) {
          try {
            final user = await userService.getUserProfile(evalue.user!.userId);
            userDetails[evalue.user!.userId] = user;
          } catch (e) {
            debugPrint('Error fetching user details: $e');
          }
        }
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Đánh giá'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authService.currentUser != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context); // Close the dialog
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EvalueCreateScreen(
                                      adviceId: advice.adviceId,
                                    ),
                              ),
                            );
                            if (result == true) {
                              _showEvaluations(
                                context,
                              ); // Refresh the evaluations
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm đánh giá'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child:
                          evaluations.isEmpty
                              ? const Center(
                                child: Text('Chưa có đánh giá nào'),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: evaluations.length,
                                itemBuilder: (context, index) {
                                  final evalue = evaluations[index];
                                  final user = userDetails[evalue.user?.userId];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.green,
                                                backgroundImage:
                                                    user?.avatar?.isNotEmpty ==
                                                            true
                                                        ? NetworkImage(
                                                          _ensureHttps(
                                                            user!.avatar,
                                                          ),
                                                        )
                                                        : null,
                                                child:
                                                    user?.avatar?.isEmpty !=
                                                            false
                                                        ? const Icon(
                                                          Icons.person,
                                                          color: Colors.white,
                                                          size: 16,
                                                        )
                                                        : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                UserProfilePage(
                                                                  userId:
                                                                      user!.id,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    user?.full_name ??
                                                        'Người dùng',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    evalue.rating.toString(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(evalue.content),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(
                                              evalue.createdAt
                                                  .toIso8601String(),
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải đánh giá: ${e.toString()}')),
      );
    }
  }

  void _showAdviceDetail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(advice.title ?? 'Chi tiết lời khuyên'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (advice.user != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              advice.user!.avatar.isNotEmpty
                                  ? NetworkImage(
                                    _ensureHttps(advice.user!.avatar),
                                  )
                                  : null,
                          backgroundColor: Colors.green,
                          child:
                              advice.user!.avatar.isEmpty
                                  ? Text(
                                    advice.user!.fullName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                advice.user!.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                advice.user!.title,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    advice.content ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatDate(advice.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showAdviceDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (advice.user != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          advice.user!.avatar.isNotEmpty
                              ? NetworkImage(_ensureHttps(advice.user!.avatar))
                              : null,
                      backgroundColor: Colors.green,
                      child:
                          advice.user!.avatar.isEmpty
                              ? Text(
                                advice.user!.fullName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => UserProfilePage(
                                        userId: advice.user!.userId,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              advice.user!.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            advice.user!.title,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (currentUserId == advice.user?.userId)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(advice),
                        tooltip: 'Chỉnh sửa lời khuyên',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                advice.title ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                advice.content ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              if (advice.plant != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlantDetailScreen(
                              plantId: advice.plant!.plantId,
                            ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_florist,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          advice.plant!.name,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (advice.disease != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DiseaseDetailScreen(
                              diseaseId: advice.disease!.diseaseId,
                            ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.healing, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          advice.disease!.name,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(advice.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEvaluations(context),
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Xem đánh giá'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
