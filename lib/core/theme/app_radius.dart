// NexaBank — Centralized Border Radius Scale
//
// Each constant is named after the component role it's used for, and holds
// the exact value already in use across the app — so this refactor doesn't
// change how anything currently looks, it just gives every value one place
// to be edited. Adjust here to restyle globally (e.g. all inputs, all
// cards) instead of hunting through each screen.
class AppRadius {
  AppRadius._();

  // ── Named scale (maps to the project's Small/Medium/Large parameter) ──
  static const small = 8.0;
  static const medium = 14.0;
  static const large = 20.0;

  // ── Component-specific (kept explicit so visuals don't shift) ─────────
  static const button = 14.0;
  static const input = 12.0;
  static const card = 16.0;
  static const cardLarge = 20.0;
  static const chip = 18.0;
  static const avatarSquare = 10.0;
  static const dialog = 20.0;
  static const pillActive = 4.0;
  static const pillInactive = 3.0;
}
