import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFFFF4F8B);
  static const Color secondary = Color(0xFFFF80AB);
  static const Color accent = Color(0xFFE91E63);

  // Background
  static const Color background = Color(0xFFFFF5F8);

  // Cards
  static const Color white = Colors.white;

  // Text
  static const Color black = Color(0xFF1D1D1D);
  static const Color grey = Color(0xFF757575);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF4F8B),
      Color(0xFFFF80AB),
    ],
  );
}