import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF42B883); // Vue Green
  static const Color primaryDark = Color(0xFF3AA876); // Darker Vue Green
  static const Color primaryLight = Color(0xFF008053); // Dark Green

  // Secondary Colors
  static const Color secondary = Color(0xFF2C3E50); // Dark Blue
  static const Color accent = Color(0xFFFFE4C4); // Bisque

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFF8F9FA); // Light Gray

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50); // Dark Blue
  static const Color textSecondary = Color(0xFF6C757D); // Gray
  static const Color textLight = Color(0xFFFFFFFF); // White

  // Action Colors
  static const Color success = Color(0xFF42B883); // Vue Green
  static const Color error = Color(0xFFDC3545); // Red
  static const Color errorDark = Color(0xFFC82333); // Dark Red
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color info = Color(0xFF17A2B8); // Blue

  // Border Colors
  static const Color border = Color(0xFFDEE2E6); // Light Gray
  static const Color borderDark = Color(0xFFCED4DA); // Darker Gray

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42B883), Color(0xFF3AA876)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hover Colors
  static const Color hoverPrimary = Color(0xFF3AA876); // Darker Vue Green
  static const Color hoverSecondary = Color(0xFF1A2A3A); // Darker Blue
  static const Color hoverAccent = Color(0xFFFFD4B8); // Lighter Bisque
}
