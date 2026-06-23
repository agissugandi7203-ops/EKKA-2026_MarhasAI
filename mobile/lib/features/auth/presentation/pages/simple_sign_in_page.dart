import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../../core/widgets/ios_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

/// Halaman login email/password sederhana — Redesain.
///
/// Menyediakan:
/// - Input Email & Password dengan styling membulat penuh (rounded) & luas
/// - Link Forgot Password
/// - Pinned bottom buttons: "Log In" & "Back"
class SimpleSignInPage extends StatefulWidget {
  const SimpleSignInPage({super.key});

  @override
  State<SimpleSignInPage> createState() => _SimpleSignInPageState();
}

class _SimpleSignInPageState extends State<SimpleSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignInRequested(
            _emailController.text.trim(),
            _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenerWrapper(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                            title: 'Log In',
                            subtitle: 'Welcome back to Genesis.id! Come on in now to continue your eco adventure.',
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
                        const SizedBox(height: AppConstants.spacing20),

                        // Password Field (Rounded)
                        _buildRoundedField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          validator: Validators.password,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: AppConstants.spacing12),

                        // Lupa Password & Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.pushNamed(Routes.forgotPasswordName),
                              child: Text(
                                'Forget Password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.pushNamed(Routes.signUpName),
                              child: Text(
                                'Create Account',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF007AFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
                    nextText: 'Log In',
                    onNextPressed: _onLogin,
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
            errorMaxLines: 5,
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
