import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Preset dekorasi visual Genesis.id.
///
/// Menyediakan [BoxDecoration], [BoxShadow], dan gradient yang konsisten
/// di seluruh aplikasi. Tidak ada dekorasi ad-hoc — semua mengacu ke sini.
///
/// Penggunaan:
/// ```dart
/// Container(decoration: AppDecorations.cardElevated);
/// ```
abstract final class AppDecorations {
  // ══════════════════════════════════════════════════════════════════════
  // BORDER RADIUS PRESETS
  // ══════════════════════════════════════════════════════════════════════

  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusRound = BorderRadius.all(Radius.circular(100));

  // ══════════════════════════════════════════════════════════════════════
  // BOX SHADOW PRESETS
  // ══════════════════════════════════════════════════════════════════════

  /// Shadow halus — card biasa, container ringan.
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Shadow sedang — card yang terangkat, floating button.
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Shadow kuat — modal, bottom sheet, dialog.
  static const List<BoxShadow> shadowStrong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════
  // BOX DECORATION PRESETS
  // ══════════════════════════════════════════════════════════════════════

  /// Card standar — rounded corner + soft shadow.
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: radiusMedium,
        boxShadow: shadowSoft,
      );

  /// Card elevated — rounded corner + medium shadow (lebih terangkat).
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: radiusLarge,
        boxShadow: shadowMedium,
      );

  /// Container gradient Navy — splash, toolbar premium.
  static BoxDecoration get navyGradientBox => const BoxDecoration(
        gradient: AppColors.navyGradient,
      );

  /// Container gradient brand — area maskot, branding section.
  static BoxDecoration get brandGradientBox => const BoxDecoration(
        gradient: AppColors.brandGradient,
      );

  /// Container outlined — border halus tanpa shadow.
  static BoxDecoration get outlined => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: radiusMedium,
        border: Border.all(color: AppColors.divider, width: 1),
      );

  /// Input field container — subtle background + border.
  static BoxDecoration get inputField => BoxDecoration(
        color: AppColors.surface,
        borderRadius: radiusMedium,
        border: Border.all(color: AppColors.divider, width: 1),
      );

  /// Input field focus — navy border highlight.
  static BoxDecoration get inputFieldFocused => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: radiusMedium,
        border: Border.all(color: AppColors.navy600, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2148A0), // navy500 dengan opacity 10%
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );
}
