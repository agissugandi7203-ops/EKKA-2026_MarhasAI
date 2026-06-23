import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/ios_button.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman reset password — input password baru setelah OTP terverifikasi — Redesain.
///
/// Menyediakan:
/// - Input Password Baru & Konfirmasi (rounded & spacious)
/// - Pinned bottom buttons: "Confirm" & "Back"
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ResetPasswordRequested(_passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          context.showSuccessSnackBar('Password berhasil diubah! Silakan masuk.');
          context.goNamed(Routes.loginName);
        } else if (state is AuthFailure) {
          context.showErrorSnackBar(state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.spacing32),

                        // Header
                        const Center(
                          child: AuthHeader(
                            title: 'Forget Password',
                            subtitle: 'Reset your account password and access your personal account again.',
                            icon: Icons.vpn_key_rounded,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing40),

                        // Password Baru (Rounded)
                        _buildRoundedField(
                          label: 'Password',
                          hint: 'Enter your new password',
                          controller: _passwordController,
                          validator: Validators.password,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: AppConstants.spacing16),

                        // Konfirmasi Password (Rounded)
                        _buildRoundedField(
                          label: 'Confirm Password',
                          hint: 'Confirm your new password',
                          controller: _confirmController,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          isPassword: true,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                          },
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: AppConstants.spacing32),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Buttons
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final bool isLoading = state is AuthLoading;
                  return IosBottomButtons(
                    nextText: 'Confirm',
                    onNextPressed: _onSubmit,
                    isNextLoading: isLoading,
                    backText: 'Back',
                    onBackPressed: () => context.pop(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.error, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
