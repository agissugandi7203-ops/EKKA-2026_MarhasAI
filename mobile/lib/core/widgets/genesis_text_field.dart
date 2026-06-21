import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Input field reusable Genesis.id.
///
/// Wrapper di atas [TextFormField] dengan styling konsisten dari design system.
/// Mendukung password toggle, prefix/suffix icon, dan validasi inline.
///
/// Penggunaan:
/// ```dart
/// GenesisTextField(
///   label: 'Email',
///   hint: 'contoh@email.com',
///   controller: _emailController,
///   validator: Validators.email,
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: Icons.email_outlined,
/// );
/// ```
class GenesisTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool isPassword;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;

  const GenesisTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffix,
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete,
  });

  @override
  State<GenesisTextField> createState() => _GenesisTextFieldState();
}

class _GenesisTextFieldState extends State<GenesisTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label di atas field (jika ada)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input field
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscureText,
          enabled: widget.enabled,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: _buildSuffix(),
          ),
        ),
      ],
    );
  }

  /// Membuat suffix icon: password toggle atau custom suffix.
  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }
    return widget.suffix;
  }
}
