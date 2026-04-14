import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Green theme from Figma
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color accentGreen = Color(0xFF66BB6A);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Border Colors
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Quality Colors
  static const Color excellent = Color(0xFF2E7D32);
  static const Color good = Color(0xFF66BB6A);
  static const Color medium = Color(0xFFFF9800);
  static const Color poor = Color(0xFFF44336);

  // Transparent
  static const Color transparent = Colors.transparent;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
  );
}
