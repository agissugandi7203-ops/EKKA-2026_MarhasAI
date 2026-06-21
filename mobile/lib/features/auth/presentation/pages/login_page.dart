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

/// Halaman login Genesis.id.
///
/// Menyediakan:
/// - Login email/password
/// - Google Sign-In
/// - Link ke Sign Up & Forgot Password
///
/// Navigasi otomatis via [BlocListener]:
/// - [Authenticated] + needsOnboarding → Setup Welcome
/// - [Authenticated] + !needsOnboarding → Home
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  void _onGoogleLogin() {
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
                    const SizedBox(height: AppConstants.spacing32),

                    // ── Header ──
                    const AuthHeader(
                      title: 'Selamat Datang!',
                      subtitle: 'Masuk untuk melanjutkan misi lingkunganmu',
                    ),
                    const SizedBox(height: AppConstants.spacing40),

                    // ── Email Field ──
                    GenesisTextField(
                      label: 'Email',
                      hint: 'contoh@email.com',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // ── Password Field ──
                    GenesisTextField(
                      label: 'Password',
                      hint: 'Minimal 8 karakter',
                      controller: _passwordController,
                      validator: Validators.password,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _onLogin,
                    ),
                    const SizedBox(height: AppConstants.spacing8),

                    // ── Lupa Password ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed(Routes.forgotPasswordName),
                        child: const Text('Lupa Password?'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // ── Tombol Masuk ──
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return GenesisButton(
                          text: 'Masuk',
                          onPressed: _onLogin,
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
                          child: Text(
                            'atau',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // ── Google Sign-In ──
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SocialSignInButton(
                          onPressed: _onGoogleLogin,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacing32),

                    // ── Footer: Link ke Sign Up ──
                    AuthFooterLink(
                      prefixText: 'Belum punya akun? ',
                      linkText: 'Daftar',
                      onPressed: () => context.pushNamed(Routes.signUpName),
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
