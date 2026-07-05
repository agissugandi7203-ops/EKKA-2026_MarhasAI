/// Konstanta global Genesis.id.
///
/// Semua "magic number" disimpan di sini agar mudah diubah secara terpusat
/// tanpa harus mencari-cari di seluruh widget tree.
abstract final class AppConstants {
  // ══════════════════════════════════════════════════════════════════════
  // SPACING — Kelipatan 4 (Material Design spacing grid)
  // ══════════════════════════════════════════════════════════════════════

  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing64 = 64;

  // ══════════════════════════════════════════════════════════════════════
  // PAGE PADDING — Jarak konten dari tepi layar
  // ══════════════════════════════════════════════════════════════════════

  static const double pagePaddingH = 24;
  static const double pagePaddingV = 16;

  // ══════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ══════════════════════════════════════════════════════════════════════

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusRound = 100;

  // ══════════════════════════════════════════════════════════════════════
  // ANIMATION DURATION
  // ══════════════════════════════════════════════════════════════════════

  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  /// Durasi splash screen sebelum navigasi otomatis.
  static const Duration splashDuration = Duration(seconds: 3);

  /// Durasi countdown OTP resend.
  static const int otpResendSeconds = 60;

  // ══════════════════════════════════════════════════════════════════════
  // FORM RULES — Selaras dengan backend DTO validation
  // ══════════════════════════════════════════════════════════════════════

  static const int passwordMinLength = 8;
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 20;
  static const int fullNameMaxLength = 50;

  // ══════════════════════════════════════════════════════════════════════
  // SHARED PREFERENCES KEYS
  // ══════════════════════════════════════════════════════════════════════

  static const String keyHasSeenIntro = 'has_seen_intro';

  // ══════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ══════════════════════════════════════════════════════════════════════

  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // ══════════════════════════════════════════════════════════════════════
  // APP VERSION
  // ══════════════════════════════════════════════════════════════════════
  static const String appVersion = '1.0.0';
}
