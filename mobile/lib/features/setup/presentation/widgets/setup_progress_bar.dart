import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Progress bar horizontal untuk Setup Wizard.
///
/// Menampilkan step saat ini dari total step dengan animasi smooth.
class SetupProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SetupProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label step
        Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
          child: Text(
            'Langkah ${currentStep + 1} dari $totalSteps',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: AppConstants.animNormal,
            curve: Curves.easeInOut,
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              minHeight: 6,
              backgroundColor: AppColors.navy100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.navy700),
            ),
          ),
        ),
      ],
    );
  }
}
