// PayMaye — Centralized Color Palette
//
// Every color used anywhere in the app should be defined here, once.
// Screens/widgets should reference AppColors.* rather than declaring their
// own `Color(0xFF......)` literals or local `_primaryColor` constants —
// that redundancy is what made re-theming painful before this refactor.
//
// Token system: bubbly violet brand, pink + sunshine-yellow accents,
// near-black violet ink for text, lavender-white surfaces.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────
  static const violet = Color(0xFF6E5AF0); // primary
  static const violetDeep = Color(0xFF4B39D6); // gradient / pressed end
  static const orchid = Color(0xFFB98CF2); // gradient midtone
  static const bubblegum = Color(0xFFFF6FA8); // pink accent
  static const sunshine = Color(0xFFFFC94D); // yellow accent

  static const primary = violet;
  static const secondary = bubblegum;
  static const accent = sunshine;

  // ── Ink (text) ───────────────────────────────────────────
  static const ink = Color(0xFF211B3D);
  static const inkMuted = Color(0xFF6F6C90);
  static const inkFaint = Color(0xFFA6A3C4);

  // ── Semantic (status) ────────────────────────────────────
  static const success = Color(0xFF2FBE8F);
  static const successBackground = Color(0xFFE1F8EF);
  static const error = Color(0xFFFF5C72);
  static const errorBackground = Color(0xFFFFE7EA);
  static const warning = Color(0xFFFFB020);
  static const warningBackground = Color(0xFFFFF3DC);

  // Aliases used specifically for transaction direction / transfer status.
  // Kept as separate names (rather than reusing success/error directly)
  // so the semantic meaning at each call site stays clear.
  static const creditColor = success;
  static const debitColor = ink;
  static const pendingColor = warning;

  // ── Light theme surfaces ────────────────────────────────
  static const lightBackground = Color(0xFFF6F4FF);
  static const lightSurface = Color(0xFFFFFFFF);

  /// Faint lavender fill used for subtle containers (avatar backdrops,
  /// list-row backgrounds, dividers) that need to read as "on-brand" but
  /// quieter than a full violet tint.
  static const fog = Color(0xFFF0EDFB);
  static const outline = Color(0xFFE7E3F7);

  // ── Dark theme surfaces ─────────────────────────────────
  static const darkPrimary = Color(0xFF9C8CFF);
  static const darkError = Color(0xFFFF8095);
  static const darkSurface = Color(0xFF211C3B);
  static const darkBackground = Color(0xFF15122A);

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
  static const chipSelected = violet;

  /// Gradient stops for the hero balance / account cards on the Home
  /// screen, indexed by account type (see `_AccountCard` in
  /// home_screen.dart). Each entry is a [start, end] gradient pair.
  static const accountCardGradients = [
    [violet, orchid],
    [Color(0xFFFF7CB4), sunshine],
    [Color(0xFF5B4FE0), bubblegum],
  ];

  /// Soft pastel backgrounds paired with a matching foreground tone —
  /// used for quick-action icons and category avatars so each item gets
  /// its own bubbly color instead of one repeated brand tint.
  static const pastelPalette = [
    [Color(0xFFEDE9FE), violet],
    [Color(0xFFFFE3EF), bubblegum],
    [Color(0xFFFFF3DC), Color(0xFFC98A1F)],
    [Color(0xFFE1F8EF), success],
    [Color(0xFFE3F1FF), Color(0xFF2F87D6)],
  ];

  /// Category colors for the spending breakdown donut chart on Insights.
  static const chartPalette = [
    violet,
    bubblegum,
    sunshine,
    success,
    orchid,
    Color(0xFF2F87D6),
    inkFaint,
  ];
}