import 'package:flutter/material.dart';

/// Palet warna terpusat Genesis.id.
///
/// Setiap warna dipilih secara deliberate berdasarkan tujuan psikologis:
/// - **Navy**: Kepercayaan, otoritas, profesionalisme (UI utama)
/// - **Burgundy**: Keberanian, passion, aksi (maskot & branding)
/// - **Emerald**: Alam, keberhasilan, lingkungan (tema aplikasi)
/// - **Gold**: Prestasi, pencapaian, premium (gamifikasi)
///
/// Penggunaan:
/// ```dart
/// Container(color: AppColors.navyDeep);
/// Text('Halo', style: TextStyle(color: AppColors.textPrimary));
/// ```
abstract final class AppColors {
  // ══════════════════════════════════════════════════════════════════════
  // PRIMARY — Navy (UI Utama: toolbar, tombol, heading)
  // ══════════════════════════════════════════════════════════════════════

  /// Navy paling gelap — status bar, gradient paling bawah.
  static const Color navy900 = Color(0xFF0A1628);

  /// Navy gelap — AppBar, primary container, card gelap.
  static const Color navy800 = Color(0xFF0F2042);

  /// Navy sedang gelap — tombol utama, CTA pressed state.
  static const Color navy700 = Color(0xFF152D5C);

  /// Navy sedang — link interaktif, secondary action.
  static const Color navy600 = Color(0xFF1B3A76);

  /// Navy base — highlight, active indicator, selected tab.
  static const Color navy500 = Color(0xFF2148A0);

  /// Navy terang — badge background, chip filled.
  static const Color navy200 = Color(0xFFB3C5E6);

  /// Navy paling terang — subtle background, hover state.
  static const Color navy100 = Color(0xFFE8EDF5);

  /// Navy hampir putih — page background alternatif.
  static const Color navy50 = Color(0xFFF4F6FA);

  // ══════════════════════════════════════════════════════════════════════
  // MASCOT — Burgundy (Maskot & Branding: splash, intro, karakter)
  // ══════════════════════════════════════════════════════════════════════

  /// Burgundy paling gelap — shadow maskot, gradient bawah.
  static const Color burgundy900 = Color(0xFF3D0010);

  /// Burgundy utama — warna maskot primer.
  static const Color burgundy700 = Color(0xFF800020);

  /// Burgundy sedang — aksen maskot, tombol branding.
  static const Color burgundy500 = Color(0xFFA3324B);

  /// Burgundy terang — background badge maskot.
  static const Color burgundy300 = Color(0xFFD4758A);

  /// Burgundy paling terang — subtle blush background.
  static const Color burgundy100 = Color(0xFFF5E0E5);

  /// Burgundy hampir putih — card background maskot area.
  static const Color burgundy50 = Color(0xFFFDF2F5);

  // ══════════════════════════════════════════════════════════════════════
  // ACCENT — Gamifikasi & Lingkungan
  // ══════════════════════════════════════════════════════════════════════

  /// Gold premium — badge highlight, achievement, XP indicator.
  static const Color gold = Color(0xFFC8922A);

  /// Gold terang — background area gamifikasi.
  static const Color goldLight = Color(0xFFF5E6C8);

  /// Gold paling terang — subtle achievement bg.
  static const Color gold50 = Color(0xFFFDF8EF);

  /// Emerald utama — sukses, streak aktif, tema lingkungan.
  static const Color emerald = Color(0xFF1B7A4E);

  /// Emerald terang — success background.
  static const Color emeraldLight = Color(0xFFD1F0E0);

  // ══════════════════════════════════════════════════════════════════════
  // SEMANTIC — Status & Feedback
  // ══════════════════════════════════════════════════════════════════════

  /// Error merah — validasi gagal, aksi destruktif.
  static const Color error = Color(0xFFC62828);

  /// Error background — subtle error container.
  static const Color errorLight = Color(0xFFFDE8E8);

  /// Warning amber — status perlu perhatian.
  static const Color warning = Color(0xFFD4930A);

  /// Warning background — subtle warning container.
  static const Color warningLight = Color(0xFFFFF3D6);

  /// Info — menggunakan navy500 sebagai info color.
  static const Color info = navy500;

  // ══════════════════════════════════════════════════════════════════════
  // SURFACE — Background & Container
  // ══════════════════════════════════════════════════════════════════════

  /// Background utama halaman — warm white, bukan cold white.
  static const Color surface = Color(0xFFFAFAF8);

  /// Card/container background.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Divider & border halus.
  static const Color divider = Color(0xFFE8E6E1);

  /// Disabled background.
  static const Color disabled = Color(0xFFF0EDEA);

  // ══════════════════════════════════════════════════════════════════════
  // TEXT — Tipografi
  // ══════════════════════════════════════════════════════════════════════

  /// Teks utama — heading, body text.
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Teks sekunder — subtitle, hint, caption.
  static const Color textSecondary = Color(0xFF64748B);

  /// Teks disabled — placeholder, inactive label.
  static const Color textDisabled = Color(0xFF94A3B8);

  /// Teks di atas warna gelap (Navy/Burgundy).
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Teks di atas warna terang/aksen.
  static const Color textOnLight = Color(0xFF1A1A2E);

  // ══════════════════════════════════════════════════════════════════════
  // GRADIENT PRESETS
  // ══════════════════════════════════════════════════════════════════════

  /// Gradient utama Navy untuk splash & toolbar.
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy800, navy900],
  );

  /// Gradient branding Burgundy-Navy untuk maskot area.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [burgundy700, navy800],
  );

  /// Gradient lembut untuk card/container premium.
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cardBackground, surface],
  );
}
