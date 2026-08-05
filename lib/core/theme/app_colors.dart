// NexaBank — Centralized Color Palette
//
// Every color used anywhere in the app should be defined here, once.
// Screens/widgets should reference AppColors.* rather than declaring their
// own `Color(0xFF......)` literals or local `_primaryColor` constants —
// that redundancy is what made re-theming painful before this refactor.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────
  static const primary = Color(0xFF70555c);
  static const secondary = Color(0xFF988c7e);

  // ── Semantic (status) ───────────────────────────────────
  static const success = Color(0xFF2E7D32);
  static const successBackground = Color(0xFFE8F5E9);
  static const error = Color(0xFFC62828);
  static const warning = Color(0xFFE65100);

  // Aliases used specifically for transaction direction / transfer status.
  // Kept as separate names (rather than reusing success/error directly)
  // so the semantic meaning at each call site stays clear.
  static const creditColor = success;
  static const debitColor = error;
  static const pendingColor = warning;

  // ── Light theme surfaces ────────────────────────────────
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightSurface = Color(0xFFF5F7FA);

  // ── Dark theme surfaces ─────────────────────────────────
  static const darkPrimary = Color(0xFF7986CB);
  static const darkError = Color(0xFFEF5350);
  static const darkSurface = Color(0xFF1E1E2E);
  static const darkBackground = Color(0xFF0F0F1A);

  // ── Component-specific ──────────────────────────────────
  /// ChoiceChip selected-state color on the Accounts screen.
  static const chipSelected = Color(0xFF1A237E);

  /// Gradient base colors for account cards on the Home screen,
  /// indexed by account type (see `_AccountCard` in home_screen.dart).
  static const accountCardPalette = [
    Color(0xFF70555c),
    Color(0xFF4e4842),
    Color(0xFF5b5053),
  ];

  /// Category colors for the spending breakdown donut chart on Insights.
  static const chartPalette = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF00BCD4),
    Color(0xFF607D8B),
  ];
}
