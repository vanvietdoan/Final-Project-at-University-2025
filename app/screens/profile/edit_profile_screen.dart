import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _authService = AuthService();

  late TextEditingController _full_nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _titleController;

  bool _isLoading = false;
  String? _avatarPath;
  String? _proofPath;
  String? _avatarUrl;
  String? _proofUrl;
  int? _userId;
  int? _roleId;
  bool _active = true;

  Future<void> _reloadUserData() async {
    if (_userId != null) {
      try {
        final updatedUser = await _userService.getUserProfile(_userId!);
        setState(() {
          _avatarUrl = updatedUser.avatar;
          _proofUrl = updatedUser.proof;
          _full_nameController.text = updatedUser.full_name ?? '';
          _emailController.text = updatedUser.email ?? '';
          _specialtyController.text = updatedUser.specialty ?? '';
          _titleController.text = updatedUser.title ?? '';
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Lỗi tải lại thông tin người dùng: $e');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('user in edit profile screen: ${widget.user?.id}');
    _active = widget.user?.active ?? true;
    _avatarUrl = widget.user?.avatar;
    _proofUrl = widget.user?.proof;
    _userId = widget.user?.id;
    _roleId = widget.user?.role?.roleId;

    _full_nameController = TextEditingController(
      text: widget.user?.full_name ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _specialtyController = TextEditingController(
      text: widget.user?.specialty ?? '',
    );
    _titleController = TextEditingController(text: widget.user?.title ?? '');
  }

  @override
  void dispose() {
    _full_nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Check file size (max 5MB)
        final file = File(image.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước ảnh không được vượt quá 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Show preview dialog
        if (mounted) {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Xem trước ảnh'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Bạn có muốn sử dụng ảnh này không?'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Xác nhận'),
                  ),
                ],
              );
            },
          );

          if (confirm == true) {
            setState(() {
              _avatarPath = image.path; // Store the local path temporarily
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  Future<void> _pickProofFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();

        // Check file size (max 10MB)
        if (sizeInBytes > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước file không được vượt quá 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _isLoading = true;
        });

        try {
          final proofResponse = await _userService.uploadProof(
            result.files.single.path!,
          );
          if (kDebugMode) {
            debugPrint('📤 Proof upload response: $proofResponse');
          }

          if (proofResponse['url'] != null) {
            setState(() {
              _proofUrl = proofResponse['url'];
              _proofPath = null; // Clear local path after successful upload
            });

            // Reload user data after successful upload
            await _reloadUserData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tải bằng cấp thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Lỗi tải lên bằng cấp: $e');
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải lên bằng cấp: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking proof file: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl = widget.user?.avatar;
      String? proofUrl = widget.user?.proof;

      // Upload new avatar if selected
      if (_avatarPath != null) {
        final uploadResult = await _userService.uploadAvatar(_avatarPath!);
        if (uploadResult != null && uploadResult['url'] != null) {
          avatarUrl = uploadResult['url'];
        }
      }

      // Clean URLs if they contain host part
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        if (avatarUrl.contains('http://') || avatarUrl.contains('https://')) {
          avatarUrl = avatarUrl.split('/').last;
        }
      }

      if (proofUrl != null && proofUrl.isNotEmpty) {
        if (proofUrl.contains('http://') || proofUrl.contains('https://')) {
          proofUrl = proofUrl.split('/').last;
        }
      }

      // Prepare user data
      final userData = {
        'full_name': _full_nameController.text,
        'title': _titleController.text,
        'specialty': _specialtyController.text,
        'avatar': avatarUrl ?? '',
        'proof': proofUrl ?? '',
        'active': widget.user?.active ?? true,
      };

      // Update user profile
      final response = await _userService.updateUserProfile(
        widget.user!.id,
        userData,
      );

      // Create User object from response
      final updatedUser = User.fromJson(response['data']);

      // Update current user in AuthService
      _authService.updateCurrentUser(updatedUser);

      // Update avatar stream
      if (avatarUrl != null) {
        _authService.updateAvatar(avatarUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
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
        backgroundColor: const Color(0xFFF7FBF1),
        elevation: 0,
        leading: BackButton(color: Colors.green),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _avatarPath != null
                                      ? FileImage(File(_avatarPath!))
                                      : (_avatarUrl != null &&
                                          _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(
                                            _avatarUrl!.replaceAll(
                                              'http://',
                                              'https://',
                                            ),
                                          )
                                          as ImageProvider<Object>
                                      : null,
                              child:
                                  (_avatarPath == null &&
                                          (_avatarUrl == null ||
                                              _avatarUrl!.isEmpty))
                                      ? Text(
                                        _full_nameController.text.isNotEmpty
                                            ? _full_nameController.text
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(fontSize: 32),
                                      )
                                      : null,
                              onBackgroundImageError: (exception, stackTrace) {
                                debugPrint('Error loading avatar: $exception');
                              },
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      _buildTextField(
                        label: 'Họ và tên',
                        controller: _full_nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Chức danh',
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập chức danh';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Chuyên ngành',
                        controller: _specialtyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập chuyên ngành';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Proof File Section
                      const Text(
                        'Giấy tờ chứng minh',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_proofUrl != null && _proofUrl!.isNotEmpty) ...[
                        InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse(_proofUrl!);
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Giấy tờ hiện tại: ${_proofUrl!.split('/').last}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.download, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      InkWell(
                        onTap: _pickProofFile,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _proofPath != null
                                      ? _proofPath!.split('/').last
                                      : 'Chọn file PDF',
                                  style: TextStyle(
                                    decoration:
                                        _proofPath != null
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Icon(
                                _proofPath != null
                                    ? Icons.upload_file
                                    : Icons.add,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hỗ trợ: PDF (Tối đa 10MB)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Lưu thay đổi'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
