import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/genesis_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_sign_in_button.dart';

/// Halaman registrasi akun baru Genesis.id.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignUpRequested(
            _emailController.text.trim(),
            _passwordController.text,
          ),
        );
  }

  void _onGoogleSignUp() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.needsOnboarding) {
            context.goNamed(Routes.setupWelcomeName);
          } else {
            context.goNamed(Routes.homeName);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──
                    const AuthHeader(
                      title: 'Buat Akun Baru',
                      subtitle: 'Bergabunglah dan mulai berkontribusi',
                      icon: Icons.person_add_outlined,
                    ),
                    const SizedBox(height: AppConstants.spacing40),

                    // ── Email ──
                    GenesisTextField(
                      label: 'Email',
                      hint: 'contoh@email.com',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // ── Password ──
                    GenesisTextField(
                      label: 'Password',
                      hint: 'Minimal 8 karakter, 1 huruf besar, 1 angka',
                      controller: _passwordController,
                      validator: Validators.password,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // ── Konfirmasi Password ──
                    GenesisTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Ketik ulang password',
                      controller: _confirmPasswordController,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _onSignUp,
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // ── Tombol Daftar ──
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return GenesisButton(
                          text: 'Daftar',
                          onPressed: _onSignUp,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // ── Divider ──
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing16,
                          ),
                          child: Text('atau',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // ── Google Sign-Up ──
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SocialSignInButton(
                          onPressed: _onGoogleSignUp,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacing32),

                    // ── Footer ──
                    AuthFooterLink(
                      prefixText: 'Sudah punya akun? ',
                      linkText: 'Masuk',
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: AppConstants.spacing32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
