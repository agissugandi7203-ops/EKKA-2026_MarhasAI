import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Header branding reusable untuk halaman auth.
///
/// Menampilkan ikon logo, judul, dan subtitle.
/// Digunakan di Login, Sign Up, Forgot Password, dll.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.eco_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo placeholder
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.navy100,
          ),
          child: Icon(icon, size: 36, color: AppColors.navy700),
        ),
        const SizedBox(height: AppConstants.spacing24),

        // Judul
        Text(
          title,
          style: AppTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing8),

        // Subtitle
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
