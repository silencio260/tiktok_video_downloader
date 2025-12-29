import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF000000); // Pure Black
  static const Color accentColor = Color(0xFFFFFFFF); // White accent
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blackWithOpacity = Color(0xB3000000);
  static const Color cardColor = Color(0xFF1A1A1A); // Dark grey for cards
  static const Color error = Color(0xFFEF4444);
  static const Color textSecondary = Color(0xFF8E8E93); // Grey text

  static LinearGradient splashGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000000), Color(0xFF0F172A)],
  );

  // Legacy colors (to be removed/refactored)
  static const Color light = Color(0xFFF6F6F6);
  static const Color grey = Color(0xFFD9D9D9);
}
