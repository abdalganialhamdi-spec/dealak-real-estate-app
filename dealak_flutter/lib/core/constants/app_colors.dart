import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D7C5F);
  static const Color primaryLight = Color(0xFF26A980);
  static const Color primaryDark = Color(0xFF065A44);
  static const Color secondary = Color(0xFFE8983E);
  static const Color secondaryLight = Color(0xFFF5B870);
  static const Color accent = Color(0xFF3B82F6);

  static const Color backgroundLight = Color(0xFFF8FAFB);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF1E2538);

  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color cardBackground = cardLight;
  static const Color divider = dividerLight;

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDarkPrimary = Color(0xFFE5E7EB);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2D3748);
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  static const Color sale = Color(0xFF3B82F6);
  static const Color rent = Color(0xFF10B981);
  static const Color dailyRent = Color(0xFFF59E0B);

  static const Color available = Color(0xFF10B981);
  static const Color sold = Color(0xFFEF4444);
  static const Color pending = Color(0xFFF59E0B);
  static const Color reserved = Color(0xFF8B5CF6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D7C5F), Color(0xFF26A980)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D7C5F), Color(0xFF1D976C), Color(0xFF93F9B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE8983E), Color(0xFFF5B870)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1F2E), Color(0xFF0F1419)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
