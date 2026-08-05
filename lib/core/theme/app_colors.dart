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

  // ── Auth screens (login/signup) ─────────────────────────
  // Matches the reference Figma banking UI kit: deep navy/indigo
  // background, soft pink→violet gradient accents, warm yellow blob.
  static const authBackground = Color(0xFF1B1140);
  static const authAccentYellow = Color(0xFFF6D875);
  static const authGradientStart = Color(0xFFEBB6DE);
  static const authGradientEnd = Color(0xFF6C63E0);
  static const authGradient = [authGradientStart, authGradientEnd];

  /// Pastel badge colors for form-field icons on the auth screens —
  /// echoes the colorful contact avatars (pink/blue/teal/lavender) in
  /// the reference kit's Transfer screen.
  static const authBadgeBlue = Color(0xFF7FA8F5);
  static const authBadgePink = Color(0xFFF07FB0);
  static const authBadgeTeal = Color(0xFF4FC9AE);
  static const authBadgeLavender = Color(0xFFA98CE0);

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

  // ── Home screen (Soft Premium Banking / Modern Plum Fintech) ───
  // Scoped to the Home dashboard the same way auth* is scoped to the
  // auth flow — this screen has its own premium palette instead of the
  // app-wide mauve `primary`/`secondary`.
  static const homePrimaryDeepPlum = Color(0xFF4B314F);
  static const homePrimaryPurple = Color(0xFF6F4A78);
  static const homeSecondaryLavender = Color(0xFFB48BC7);

  static const homeBackground = Color(0xFFF8F6F4);
  static const homeSurface = Color(0xFFFCFAFB);
  static const homeBorder = Color(0xFFE9E3EA);

  static const homeAccentPink = Color(0xFFE8B7D0);
  static const homeAccentBlue = Color(0xFFBFE3F7);
  static const homeAccentYellow = Color(0xFFF3E19A);

  static const homeTextPrimary = Color(0xFF2F2432);
  static const homeTextSecondary = Color(0xFF8B7C8F);

  static const homeSuccess = Color(0xFF57B26A);
  static const homeError = Color(0xFFD96B6B);
  static const homeFocus = Color(0xFF5B8DEF);

  /// NexaBank Primary Gradient — used for the hero/account card carousel.
  static const homePrimaryGradient = [
    homePrimaryDeepPlum,
    homePrimaryPurple,
    homeSecondaryLavender,
  ];

  /// Hero Card Gradient — two-stop variant for smaller accents.
  static const homeHeroCardGradient = [
    homePrimaryDeepPlum,
    homePrimaryPurple,
  ];
}
