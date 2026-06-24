import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../widgets/setup_illustration.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 1 — Halaman selamat datang di Setup Wizard.
///
/// Menjelaskan apa yang akan disetup sebelum user bisa menggunakan aplikasi.
class SetupWelcomePage extends StatelessWidget {
  const SetupWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF6F0), // Soft mint green
              Color(0xFFFAFAF8), // Warm white
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePaddingH,
              vertical: AppConstants.pagePaddingV,
            ),
            child: Column(
              children: [
                // Progress
                const SetupProgressBar(currentStep: 0, totalSteps: 4),
                const Spacer(),

                // Ilustrasi dengan entrance animation
                const FadeSlideEntrance(
                  delay: Duration(milliseconds: 150),
                  child: SetupIllustration(
                    icon: Icons.waving_hand_rounded,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing32),

                // Judul
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Halo, Pahlawan\nLingkungan! 🌿',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Deskripsi
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sebelum mulai, kami butuh beberapa hal agar pengalamanmu di Genesis.id lebih personal dan optimal.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),

                // Tombol
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 600),
                  child: GenesisButton(
                    text: 'Ayo Mulai!',
                    onPressed: () => context.goNamed(Routes.setupLocationName),
                    prefixIcon: Icons.arrow_forward_rounded,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
