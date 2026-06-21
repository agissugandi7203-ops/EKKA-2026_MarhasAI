import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../bloc/setup_cubit.dart';
import '../widgets/setup_illustration.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 3 — Request izin notifikasi.
///
/// Menjelaskan manfaat notifikasi dan menyediakan opsi skip.
class SetupNotificationPage extends StatefulWidget {
  const SetupNotificationPage({super.key});

  @override
  State<SetupNotificationPage> createState() => _SetupNotificationPageState();
}

class _SetupNotificationPageState extends State<SetupNotificationPage> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    final status = await Permission.notification.request();

    if (mounted) {
      context.read<SetupCubit>().setNotificationPermission(
            granted: status.isGranted,
          );

      setState(() => _isRequesting = false);
      _goNext();
    }
  }

  void _skip() {
    context.read<SetupCubit>().setNotificationPermission(granted: false);
    _goNext();
  }

  void _goNext() {
    context.goNamed(Routes.setupProfileName);
  }

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
              const SetupProgressBar(currentStep: 2, totalSteps: 4),
              const Spacer(),

              const SetupIllustration(
                icon: Icons.notifications_active_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(height: AppConstants.spacing32),

              Text(
                'Aktifkan Notifikasi',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Dapatkan notifikasi saat laporanmu diverifikasi, kamu naik level, atau ada pencapaian baru!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // ── Benefit List ──
              ..._benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing4,
                    horizontal: AppConstants.spacing16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.emerald,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Text(benefit, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              GenesisButton(
                text: 'Aktifkan Notifikasi',
                onPressed: _isRequesting ? null : _requestPermission,
                isLoading: _isRequesting,
                prefixIcon: Icons.notifications_rounded,
              ),
              const SizedBox(height: AppConstants.spacing8),

              GenesisButton(
                text: 'Nanti Saja',
                variant: GenesisButtonVariant.text,
                onPressed: _skip,
              ),
              const SizedBox(height: AppConstants.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _benefits = [
    'Laporan diverifikasi AI',
    'Naik level & raih lencana',
    'Streak harian terjaga',
    'Update peringkat kota',
  ];
}
