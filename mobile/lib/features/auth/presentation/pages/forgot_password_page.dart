import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/ios_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman lupa password — Redesain.
///
/// Menyediakan:
/// - Input Email (rounded & spacious)
/// - Pinned bottom buttons: "Next" & "Back"
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ForgotPasswordRequested(_emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          context.pushNamed(
            Routes.otpVerificationName,
            extra: state.email,
          );
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
                            icon: Icons.lock_reset_rounded,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing40),

                        // Email Field (Rounded)
                        _buildRoundedField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
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
                    nextText: 'Next',
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
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
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
