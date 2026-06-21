import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Link navigasi di footer halaman auth.
///
/// Contoh: "Belum punya akun? **Daftar**"
class AuthFooterLink extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onPressed;

  const AuthFooterLink({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefixText,
          style: AppTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            linkText,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.navy600,
            ),
          ),
        ),
      ],
    );
  }
}
