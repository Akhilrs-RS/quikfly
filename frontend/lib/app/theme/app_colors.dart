import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2B66F6);
  static const Color primaryDark = Color(0xFF1A46C4);
  static const Color primaryLight = Color(0xFFEEF4FF);
  
  // Background & Surfaces
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F4F7);
  static const Color darkCard = Color(0xFF101828);

  // Borders & Dividers
  static const Color border = Color(0xFFEAECF0);
  static const Color borderLight = Color(0xFFF2F4F7);

  // Text Colors
  static const Color textPrimary = Color(0xFF1D2939);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Accents
  static const Color accentGreen = Color(0xFF12B76A);
  static const Color accentOrange = Color(0xFFF79009);
  static const Color accentPurple = Color(0xFF7A5AF8);
  static const Color accentRed = Color(0xFFF04438);

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF101828).withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF101828).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
