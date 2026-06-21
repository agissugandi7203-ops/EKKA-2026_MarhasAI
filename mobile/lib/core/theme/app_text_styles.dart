import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Sistem tipografi terpusat Genesis.id.
///
/// Font yang dipilih:
/// - **Nunito**: Heading & display — letterform bulat (soft), friendly, approachable.
/// - **Plus Jakarta Sans**: Body & label — modern, readability tinggi, origin Indonesia.
///
/// Kedua font ini memiliki terminasi bulat (rounded terminals) yang memberikan
/// kesan "soft" sesuai identitas visual Genesis.id.
///
/// Penggunaan:
/// ```dart
/// Text('Judul', style: AppTextStyles.headlineLarge);
/// Text('Body', style: AppTextStyles.bodyMedium);
/// ```
abstract final class AppTextStyles {
  // ══════════════════════════════════════════════════════════════════════
  // DISPLAY & HEADING — Nunito (soft, rounded, friendly)
  // ══════════════════════════════════════════════════════════════════════

  /// Display besar — splash screen title, hero text.
  static TextStyle displayLarge = GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Display sedang — section hero, onboarding title.
  static TextStyle displayMedium = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Headline besar — page title utama.
  static TextStyle headlineLarge = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  /// Headline sedang — section header.
  static TextStyle headlineMedium = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Headline kecil — card title, dialog title.
  static TextStyle headlineSmall = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ══════════════════════════════════════════════════════════════════════
  // TITLE — Nunito (transisi heading ke body)
  // ══════════════════════════════════════════════════════════════════════

  /// Title besar — toolbar title, prominent card title.
  static TextStyle titleLarge = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// Title sedang — list item title, sub-section.
  static TextStyle titleMedium = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  // ══════════════════════════════════════════════════════════════════════
  // BODY — Plus Jakarta Sans (modern, readable, Indonesian origin)
  // ══════════════════════════════════════════════════════════════════════

  /// Body besar — konten utama, paragraf.
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  /// Body sedang — konten sekunder, deskripsi.
  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Body kecil — caption, timestamp, metadata.
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ══════════════════════════════════════════════════════════════════════
  // LABEL — Plus Jakarta Sans (tombol, chip, badge)
  // ══════════════════════════════════════════════════════════════════════

  /// Label besar — primary button text.
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    height: 1.4,
    letterSpacing: 0.3,
  );

  /// Label sedang — secondary button, tab, chip.
  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// Label kecil — badge text, tag, overline.
  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );
}
