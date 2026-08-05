// PayMaye Design System — Light & Dark Theme
//
// Colors and radii are sourced from AppColors / AppRadius (see
// app_colors.dart / app_radius.dart) rather than declared inline, so the
// whole app's look can be edited from those two files.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class PayMayeTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        brightness: Brightness.light,
        primary: AppColors.violet,
        secondary: AppColors.bubblegum,
        tertiary: AppColors.sunshine,
        error: AppColors.error,
        surface: AppColors.lightSurface,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      textTheme: _textTheme(Brightness.light),
      splashFactory: InkRipple.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.violet.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.violet,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.violet, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.violet,
          textStyle:
              GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fog,
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.inkFaint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.violet, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.violet.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fog,
        selectedColor: AppColors.violet,
        labelStyle:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.dialog)),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: AppColors.bubblegum,
        tertiary: AppColors.sunshine,
        error: AppColors.darkError,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(Brightness.dark),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
    );
  }

  static InputDecorationTheme get authInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
      floatingLabelStyle: const TextStyle(color: AppColors.authGradientEnd),
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
        borderSide: const BorderSide(color: AppColors.authGradientEnd, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? AppColors.ink : Colors.white;
    final mutedColor = brightness == Brightness.light
        ? AppColors.inkMuted
        : Colors.white.withValues(alpha: 0.7);

    final base = GoogleFonts.plusJakartaSansTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 40, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -1),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -0.5),
      headlineLarge: base.headlineLarge
          ?.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: baseColor),
      headlineMedium: base.headlineMedium
          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: baseColor),
      titleLarge: base.titleLarge
          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: baseColor),
      titleMedium: base.titleMedium
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: baseColor),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: mutedColor),
      labelLarge: base.labelLarge
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: baseColor),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12, color: mutedColor),
    );
  }
}