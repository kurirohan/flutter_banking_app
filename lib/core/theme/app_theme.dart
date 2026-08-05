// NexaBank Design System — Light & Dark Theme
//
// Colors and radii are sourced from AppColors / AppRadius (see
// app_colors.dart / app_radius.dart) rather than declared inline, so the
// whole app's look can be edited from those two files.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class NexaBankTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.lightSurface,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      textTheme: _textTheme(Brightness.light),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: AppColors.secondary,
        error: AppColors.darkError,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(Brightness.dark),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light ? AppColors.primary : Colors.white;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: baseColor, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: baseColor, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: baseColor),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: baseColor),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14, color: baseColor.withOpacity(0.7)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      labelMedium: TextStyle(fontSize: 12, color: baseColor.withOpacity(0.6)),
    );
  }
}
