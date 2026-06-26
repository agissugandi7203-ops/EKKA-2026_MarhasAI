import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tombol utama reusable Genesis.id.
///
/// Tiga varian:
/// - [GenesisButtonVariant.primary] — Navy filled (CTA utama)
/// - [GenesisButtonVariant.secondary] — Outlined (aksi sekunder)
/// - [GenesisButtonVariant.text] — Text only (link-like)
///
/// Mendukung:
/// - Loading state (circular indicator otomatis)
/// - Disabled state
/// - Full-width mode
/// - Prefix icon
///
/// Penggunaan:
/// ```dart
/// GenesisButton(
///   text: 'Masuk',
///   onPressed: () => _handleLogin(),
///   isLoading: state is AuthLoading,
/// );
/// ```
class GenesisButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GenesisButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;

  const GenesisButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = GenesisButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: switch (variant) {
        GenesisButtonVariant.primary => _buildPrimary(isDisabled),
        GenesisButtonVariant.secondary => _buildSecondary(isDisabled),
        GenesisButtonVariant.text => _buildText(isDisabled),
      },
    );
  }

  Widget _buildPrimary(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: isLoading ? AppColors.navy700 : AppColors.disabled,
        disabledForegroundColor: isLoading ? AppColors.textOnDark : AppColors.textDisabled,
      ),
      child: _buildChild(AppColors.textOnDark),
    );
  }

  Widget _buildSecondary(bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: isLoading ? AppColors.navy700 : AppColors.textDisabled,
        side: BorderSide(
          color: isLoading
              ? AppColors.navy700
              : (isDisabled ? AppColors.disabled : AppColors.navy200),
          width: 1.5,
        ),
      ),
      child: _buildChild(AppColors.navy700),
    );
  }

  Widget _buildText(bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        disabledForegroundColor: isLoading ? AppColors.navy600 : AppColors.textDisabled,
      ),
      child: _buildChild(AppColors.navy600),
    );
  }

  Widget _buildChild(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: Lottie.asset(
          'assets/animations/global/global_loading.json',
          fit: BoxFit.contain,
        ),
      );
    }

    if (prefixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(prefixIcon, size: AppConstants.iconMedium),
          const SizedBox(width: AppConstants.spacing8),
          Text(text, style: AppTextStyles.labelLarge.copyWith(color: contentColor)),
        ],
      );
    }

    return Text(text, style: AppTextStyles.labelLarge.copyWith(color: contentColor));
  }
}

/// Varian visual untuk [GenesisButton].
enum GenesisButtonVariant {
  /// Tombol filled Navy — aksi utama (CTA).
  primary,

  /// Tombol outlined — aksi sekunder.
  secondary,

  /// Tombol text-only — navigasi ringan.
  text,
}
