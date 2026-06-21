import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Ilustrasi placeholder untuk halaman setup.
///
/// Menampilkan ikon besar dengan background lingkaran berwarna.
/// Akan diganti dengan Lottie animation atau SVG ilustrasi.
class SetupIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SetupIllustration({
    super.key,
    required this.icon,
    this.color = AppColors.navy700,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(
        icon,
        size: 64,
        color: color,
      ),
    );
  }
}
