import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../models/notify.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../services/notify_sevice.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../auth/login_screen.dart';
import '../advice/advice_list_screen.dart';
import '../home_screen.dart';
import '../../widgets/custom_app_bar.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../report/report_list_screen.dart';
import '../evalue/evalue_list_screen.dart';
import '../../widgets/notification_button.dart';

class ExpertProfile extends StatefulWidget {
  final User expert;

  const ExpertProfile({Key? key, required this.expert}) : super(key: key);

  @override
  ExpertProfileState createState() => ExpertProfileState();
}

class ExpertProfileState extends State<ExpertProfile> {
  late TextEditingController _full_nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _titleController;
  bool _isEditing = false;
  late Future<User> _expertFuture;
  final UserService _userService = UserService();
  final NotifyService _notifyService = NotifyService();
  List<Notify> _notifications = [];
  bool _isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    _full_nameController = TextEditingController(text: widget.expert.full_name);
    _emailController = TextEditingController(text: widget.expert.email);
    _specialtyController = TextEditingController(text: widget.expert.specialty);
    _titleController = TextEditingController(text: widget.expert.title);
    _loadExpertData();
    _loadNotifications();
  }

  Future<void> _loadExpertData() async {
    setState(() {
      _expertFuture = _userService.getUserProfile(widget.expert.id);
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoadingNotifications = true;
    });
    try {
      final notifications = await _notifyService.getNotifyByUser(
        widget.expert.id,
      );
      setState(() {
        _notifications = notifications;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải thông báo: $e')));
      }
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  Future<void> _markAsRead(int notifyId) async {
    try {
      await _notifyService.markAsRead(notifyId);
      _loadNotifications(); // Reload notifications after marking as read
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đánh dấu thông báo: $e')));
      }
    }
  }

  Future<void> _deleteNotification(int notifyId) async {
    try {
      await _notifyService.deleteNotification(notifyId);
      _loadNotifications(); // Reload notifications after deletion
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi xóa thông báo: $e')));
      }
    }
  }

  @override
  void dispose() {
    _full_nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chuyên gia'),
        automaticallyImplyLeading: false,
        actions: [
          NotificationButton(userId: widget.expert.id),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _expertFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          }

          final expert = snapshot.data!;
          _full_nameController.text = expert.full_name;
          _emailController.text = expert.email;
          _specialtyController.text = expert.specialty;
          _titleController.text = expert.title;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section with enhanced styling
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              expert.avatar.isNotEmpty
                                  ? NetworkImage(
                                    expert.avatar.replaceAll(
                                      'http://',
                                      'https://',
                                    ),
                                  )
                                  : null,
                          child:
                              expert.avatar.isEmpty
                                  ? Text(
                                    expert.full_name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.grey,
                                    ),
                                  )
                                  : null,
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Error loading avatar: $exception');
                          },
                        ),
                      ),
                      if (expert.avatar.isNotEmpty)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Role Badge with enhanced styling
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      expert.role?.name ?? 'Chuyên gia',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Information with enhanced styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoSection('Họ và tên', expert.full_name),
                      _buildInfoSection('Email', expert.email),
                      _buildInfoSection('Chức danh', expert.title),
                      _buildInfoSection('Chuyên ngành', expert.specialty),
                    ],
                  ),
                ),

                // Proof File Section with enhanced styling
                if (expert.proof.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Giấy tờ chứng minh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse(expert.proof);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể mở file'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              expert.proof,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.download,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Account Status with enhanced styling
                if (!expert.active)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tài khoản chưa được kích hoạt',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                // Action Buttons with enhanced styling
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _manageAdvice,
                        icon: Icons.lightbulb_outline,
                        label: 'Quản lý lời khuyên',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _manageReport,
                        icon: Icons.assignment,
                        label: 'Quản lý báo cáo',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _editProfile,
                        icon: Icons.edit,
                        label: 'Chỉnh sửa thông tin',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _changePassword,
                        icon: Icons.lock_outline,
                        label: 'Đổi mật khẩu',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _manageEvalues,
                        icon: Icons.star_outline,
                        label: 'Quản lý đánh giá',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _editProfile() {
    debugPrint('expert in edit profile screen: ${widget.expert.id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: widget.expert),
      ),
    ).then((_) {
      // Reload data after returning from edit screen
      _loadExpertData();
    });
  }

  void _manageAdvice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAdviceScreen(expertId: widget.expert.id),
      ),
    );
  }

  void _manageReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageReportScreen(userId: widget.expert.id),
      ),
    );
  }

  void _manageEvalues() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvalueListScreen(userId: widget.expert.id),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final authService = AuthService();
    authService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
