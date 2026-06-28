import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../../core/widgets/ios_button.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Halaman pra-onboarding (Welcome Screen sebelum slide tour) — Final.
///
/// Menampilkan latar belakang gambar ekologis fullscreen,
/// judul branding Genesis.id, dan 2 tombol khas iOS dengan logo Google SVG asli.
class PreOnboardingPage extends StatelessWidget {
  const PreOnboardingPage({super.key});

  void _onGoogleLogin(BuildContext context) {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenerWrapper(
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background Image fullscreen ──
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=1080',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: AppColors.navy800,
                    highlightColor: AppColors.navy700,
                    child: Container(color: AppColors.navy800),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Fallback gradient jika offline
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                    ),
                  );
                },
              ),
            ),

            // ── Dark gradient overlay ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.5),
                      AppColors.navy900.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.5, 0.9],
                  ),
                ),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                  vertical: AppConstants.pagePaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Logo & App Name
                    FadeSlideEntrance(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    FadeSlideEntrance(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Genesis',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    FadeSlideEntrance(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        'Satu langkah nyata untuk bumi yang lebih bersih. Laporkan sampah, raih lencana, dan banggakan kotamu!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing48),

                    // ── Buttons ──
                    FadeSlideEntrance(
                      delay: const Duration(milliseconds: 800),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final bool isLoading = state is AuthLoading;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Button: Take a Quick Tour
                              IosButton(
                                text: 'Take a Quick Tour',
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                textColor: Colors.white,
                                onPressed: isLoading
                                    ? null
                                    : () => context.goNamed(Routes.introductionName),
                              ),
                              const SizedBox(height: AppConstants.spacing16),

                              // Button: Login with Google (Menggunakan SVG Asli)
                              IosButton(
                                text: 'Login with Google',
                                backgroundColor: Colors.white,
                                textColor: AppColors.navy900,
                                isLoading: isLoading,
                                icon: SvgPicture.string(
                                  AppSvgs.googleLogo,
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: isLoading ? null : () => _onGoogleLogin(context),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
