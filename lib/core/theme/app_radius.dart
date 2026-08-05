// PayMaye — Centralized Border Radius Scale
//
// Each constant is named after the component role it's used for, so the
// whole app's roundness can be tuned from this one file. Values here lean
// deliberately generous (bubbly/pill-shaped) — that softness is a core
// part of the brand, not an incidental style choice.
class AppRadius {
  AppRadius._();

  // ── Named scale (maps to the project's Small/Medium/Large parameter) ──
  static const small = 12.0;
  static const medium = 20.0;
  static const large = 28.0;

  // ── Component-specific ─────────────────────────────────────────────
  static const button = 18.0; // full-width buttons (56px tall -> stadium-ish)
  static const pill = 999.0; // fully rounded / stadium shape
  static const input = 18.0;
  static const card = 24.0;
  static const cardLarge = 32.0;
  static const chip = 999.0;
  static const avatarSquare = 16.0;
  static const dialog = 28.0;
  static const pillActive = 8.0;
  static const pillInactive = 4.0;
}
