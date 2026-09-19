import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme Palette (Default)
  static const Color obsidianBackground = Color(0xFF0E0B16);
  static const Color midnightSurface = Color(0xFF161224);
  static const Color cardSurface = Color(0xFF1F1A33);
  static const Color cardBorder = Color(0xFF2E264C);

  // Mystical Accents
  static const Color astralGold = Color(0xFFE5C07B);
  static const Color radiantGold = Color(0xFFFFD166);
  static const Color sacredPurple = Color(0xFF9D7CD8);
  static const Color deepAmethyst = Color(0xFF7B4397);

  // Text Colors
  static const Color textPrimary = Color(0xFFF3EFFF);
  static const Color textSecondary = Color(0xFFA59EBE);
  static const Color textMuted = Color(0xFF6E678A);

  // Status Colors
  static const Color success = Color(0xFF51CF66);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFA94D);
  static const Color info = Color(0xFF4DABF7);

  // Gradients
  static const LinearGradient mysticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF161224),
      Color(0xFF0E0B16),
      Color(0xFF1F1A33),
    ],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [
      Color(0xFFE5C07B),
      Color(0xFFD4AF37),
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x339D7CD8),
      Color(0x110E0B16),
    ],
  );

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFF0EDFA);
  static const Color lightTextPrimary = Color(0xFF1A1528);
  static const Color lightTextSecondary = Color(0xFF5A5270);
  static const Color lightBorder = Color(0xFFE0DAF2);
}
