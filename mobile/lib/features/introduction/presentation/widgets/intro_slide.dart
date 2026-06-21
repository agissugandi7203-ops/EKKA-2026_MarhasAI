import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget slide individual untuk introduction.
///
/// Menampilkan ikon/ilustrasi (placeholder), judul, dan deskripsi
/// dengan warna aksen yang dapat dikustomisasi per slide.
class IntroSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const IntroSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePaddingH,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi placeholder — akan diganti dengan Lottie/SVG
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              size: 80,
              color: accentColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacing48),

          // Judul
          Text(
            title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.navy900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
