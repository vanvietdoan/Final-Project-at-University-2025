import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/expert_profile.dart';
import '../screens/plants/plants_screen.dart';
import '../screens/disease/disease_screen.dart';
import '../screens/search/search_screen.dart';
import '../services/auth_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 4) {
      final authService = AuthService();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertProfile(expert: currentUser),
          ),
        );
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PlantsScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DiseaseScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          break;
        case 4:
          final authService = AuthService();
          final currentUser = authService.currentUser;

          if (currentUser == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ExpertProfile(expert: currentUser),
              ),
            );
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _handleNavigation(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_florist),
          label: 'Cây thuốc',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.healing), label: 'Bệnh'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tra cứu'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
      ],
    );
  }
}
