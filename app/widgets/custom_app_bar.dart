import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/expert_profile.dart';
import '../services/base_api_service.dart';
import 'notification_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo app bên trái
          Row(children: [Image.asset('assets/images/logo.png', height: 100)]),
          // Avatar và tên user bên phải
          Row(
            children: [
              if (currentUser != null) ...[
                NotificationButton(userId: currentUser.id),
                Text(
                  currentUser.full_name,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: () async {
                  if (currentUser == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ExpertProfile(expert: currentUser),
                      ),
                    );

                    // Reload if profile was updated
                    if (result == true) {
                      setState(() {});
                    }
                  }
                },
                child: StreamBuilder<String>(
                  stream: _authService.avatarStream,
                  initialData: currentUser?.avatar,
                  builder: (context, snapshot) {
                    final avatarUrl = snapshot.data;
                    if (kDebugMode) {
                      debugPrint('Avatar URL in StreamBuilder: $avatarUrl');
                    }

                    String? finalAvatarUrl;
                    if (avatarUrl != null && avatarUrl.isNotEmpty) {
                      if (avatarUrl.startsWith('http://') ||
                          avatarUrl.startsWith('https://')) {
                        finalAvatarUrl = avatarUrl.replaceAll(
                          'http://',
                          'https://',
                        );
                      } else {
                        finalAvatarUrl = '${BaseApiService.baseUrl}/$avatarUrl';
                      }
                    }

                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          finalAvatarUrl != null
                              ? NetworkImage(finalAvatarUrl)
                              : null,
                      child:
                          finalAvatarUrl == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Error loading avatar: $exception');
                        debugPrint('Failed URL: $finalAvatarUrl');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
