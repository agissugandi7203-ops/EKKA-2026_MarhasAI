import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
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

              // Ilustrasi
              const SetupIllustration(
                icon: Icons.waving_hand_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Judul
              Text(
                'Halo, Pahlawan\nLingkungan! 🌿',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Deskripsi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sebelum mulai, kami butuh beberapa hal agar pengalamanmu di Genesis.id lebih personal dan optimal.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),

              // Tombol
              GenesisButton(
                text: 'Ayo Mulai!',
                onPressed: () => context.goNamed(Routes.setupLocationName),
                prefixIcon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: AppConstants.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
