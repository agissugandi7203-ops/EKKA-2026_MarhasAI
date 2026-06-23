import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/ios_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_header.dart';

/// Halaman login masuk utama (Social Login Hub) — Redesain Final.
///
/// Menyediakan:
/// - Google Sign-In (fungsional dengan logo SVG Google asli)
/// - Facebook, GitHub, Magic Link (dengan logo SVG asli)
/// - Tombol "OR Log in to my account" untuk form email/password
/// - Tanpa tombol navigasi ganda di bawah (clear sampai Log in to my account)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onGoogleLogin() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  void _showFeatureMock(String provider) {
    context.showInfoSnackBar('Login dengan $provider segera hadir!');
  }

  void _showMagicLinkDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15), // Barrier transparan tipis
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Backdrop Blur Fullscreen (Efek Glassmorphism) ──
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),

            // ── Dialog Box Glassmorphism Diperbesar ──
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75), // Frosted glass
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Magic Link Sign In',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan email Anda untuk menerima link masuk tanpa password.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kolom Input Diperbesar (Spacious, Rounded & Glassy)
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'contoh@email.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 22, color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
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
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Dialog
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(20),
                          child: const Text(
                            'Kirim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            final email = emailController.text.trim();
                            Navigator.pop(context);
                            if (email.isNotEmpty) {
                              this.context.showSuccessSnackBar('Link masuk telah dikirim ke $email!');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose controller saat dialog ditutup untuk mencegah memory leak
      emailController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenerWrapper(
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
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.spacing32),

                      // ── Header branding (Selamat Datang) ──
                      const AuthHeader(
                        title: 'Welcome to Genesis.id',
                        subtitle: 'Pilih metode masuk untuk melanjutkan aksi lingkunganmu',
                      ),
                      const SizedBox(height: AppConstants.spacing40),

                      // ── Google Sign-In (Edge-to-Edge dengan SVG Asli) ──
                      IosButton(
                        text: 'Login with Google',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        icon: SvgPicture.string(
                          AppSvgs.googleLogo,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: _onGoogleLogin,
                      ),
                      const SizedBox(height: AppConstants.spacing12),

                      // ── Facebook Sign-In (Edge-to-Edge dengan SVG Asli) ──
                      IosButton(
                        text: 'Login with Facebook',
                        backgroundColor: const Color(0xFF1877F2),
                        textColor: Colors.white,
                        icon: SvgPicture.string(
                          AppSvgs.facebookLogo,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () => _showFeatureMock('Facebook'),
                      ),
                      const SizedBox(height: AppConstants.spacing12),

                      // ── GitHub Sign-In (Edge-to-Edge dengan SVG Asli) ──
                      IosButton(
                        text: 'Login with GitHub',
                        backgroundColor: const Color(0xFF24292F),
                        textColor: Colors.white,
                        icon: SvgPicture.string(
                          AppSvgs.githubLogo,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () => _showFeatureMock('GitHub'),
                      ),
                      const SizedBox(height: AppConstants.spacing12),

                      // ── Magic Link Sign-In (Edge-to-Edge dengan SVG Asli) ──
                      IosButton(
                        text: 'Login with Magic Link',
                        backgroundColor: AppColors.navy700,
                        textColor: Colors.white,
                        icon: SvgPicture.string(
                          AppSvgs.magicLinkLogo,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: _showMagicLinkDialog,
                      ),
                      const SizedBox(height: AppConstants.spacing32),

                      // ── OR Log in to my account divider/button ──
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'atau',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing24),

                      IosButton(
                        text: 'Log in to my account',
                        isFilled: false,
                        backgroundColor: AppColors.navy600,
                        textColor: AppColors.navy700,
                        onPressed: () => context.pushNamed(Routes.simpleSignInName),
                      ),
                      const SizedBox(height: AppConstants.spacing32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
