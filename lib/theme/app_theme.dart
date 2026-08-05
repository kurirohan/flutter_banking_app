import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F6F4);
  static const Color surface = Color(0xFFFCFAFB);
  static const Color border = Color(0xFFE9E3EA);

  static const Color primaryDark = Color(0xFF4B314F);
  static const Color primary = Color(0xFF6F4A78);
  static const Color primaryLight = Color(0xFFB48BC7);

  static const Color accentPink = Color(0xFFE8B7D0);
  static const Color accentBlue = Color(0xFFBFE3F7);
  static const Color accentYellow = Color(0xFFF3E19A);

  static const Color textPrimary = Color(0xFF2F2432);
  static const Color textSecondary = Color(0xFF8B7C8F);

  static const Color success = Color(0xFF57B26A);
  static const Color error = Color(0xFFD96B6B);
  static const Color focus = Color(0xFF5B8DEF);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

