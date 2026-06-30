import 'package:flutter/material.dart';

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
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size * 0.5,
            height: size * 0.5,
            child: const CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E4095)),
              backgroundColor: Color(0xFFF1F5F9),
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
