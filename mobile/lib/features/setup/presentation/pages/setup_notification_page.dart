import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../bloc/setup_cubit.dart';
import '../widgets/setup_illustration.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 3 — Request izin notifikasi.
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
      body: AuthListenerWrapper(
        child: Container(
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
                  const SetupProgressBar(currentStep: 2, totalSteps: 4),
                  const Spacer(),

                  // Ilustrasi dengan entrance animation
                  const FadeSlideEntrance(
                    delay: Duration(milliseconds: 150),
                    child: SetupIllustration(
                      lottieAsset: 'assets/animations/onboarding/notification_permission.json',
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing32),

                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Aktifkan Notifikasi',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),

                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 450),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Dapatkan notifikasi saat laporanmu diverifikasi, kamu naik level, atau ada pencapaian baru!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // ── Benefit List ──
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacing8,
                            horizontal: AppConstants.spacing16,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.emerald,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.spacing12),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 680),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '🛡️ Genesis.id berkomitmen penuh menjaga keamanan data Anda. Izin notifikasi hanya digunakan untuk aktivitas pelaporan dan informasi aplikasi secara internal.',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Buttons container
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 750),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                ],
              ),
            ),
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
