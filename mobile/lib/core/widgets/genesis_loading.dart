import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Loading indicator bermerek Genesis.id.
///
/// Menampilkan spinner dengan teks opsional di bawahnya.
/// Cocok untuk full-page loading atau inline loading state.
///
/// Penggunaan:
/// ```dart
/// // Full page
/// GenesisLoading(message: 'Memuat profil...');
///
/// // Compact (tanpa pesan)
/// GenesisLoading();
/// ```
class GenesisLoading extends StatelessWidget {
  final String? message;
  final double size;

  const GenesisLoading({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.navy700,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
