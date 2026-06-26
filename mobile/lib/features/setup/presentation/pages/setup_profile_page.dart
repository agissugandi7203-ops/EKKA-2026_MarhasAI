import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/genesis_text_field.dart';
import '../../../../core/widgets/genesis_loading.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/setup_cubit.dart';
import '../bloc/setup_state.dart';
import '../widgets/setup_illustration.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 4 — Lengkapi profil (username, nama lengkap, konfirmasi lokasi).
class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _showCongratulationsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
        
        return Dialog.fullscreen(
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
          child: PopScope(
            canPop: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Lottie.asset(
                      'assets/animations/global/Congratulations.json',
                      repeat: false,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pendaftaran Selesai! 🎉',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selamat datang di Genesis.id',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Tampilkan full-screen loading dialog dulu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(
          child: GenesisLoading(message: 'Menyimpan profil Anda...'),
        ),
      ),
    );

    try {
      final setupState = context.read<SetupCubit>().state;
      final profileRepo = context.read<ProfileRepository>();

      await profileRepo.onboardProfile(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        province: setupState.province ?? 'Belum diatur',
        cityOrDistrict: setupState.cityOrDistrict ?? 'Belum diatur',
      );

      if (!mounted) return;

      // Dismiss loading dialog
      Navigator.of(context).pop();

      setState(() => _isSubmitting = false);

      // Tampilkan popup Congratulations selama 3 detik sebelum masuk ke Home
      await _showCongratulationsDialog();

      if (!mounted) return;
      
      // Memicu pengecekan ulang status autentikasi/onboarding di AuthBloc agar tersinkronisasi.
      context.read<AuthBloc>().add(AuthCheckRequested());
    } catch (e) {
      if (!mounted) return;
      // Dismiss loading dialog jika terbuka
      Navigator.of(context).pop();
      setState(() => _isSubmitting = false);
      final appError = ErrorHandler.handle(e);
      context.showErrorSnackBar('Gagal menyimpan profil: ${appError.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, setupState) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: AppConstants.pagePaddingV,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SetupProgressBar(currentStep: 3, totalSteps: 4),
                        const SizedBox(height: AppConstants.spacing24),

                        // Ilustrasi dengan Lottie animation
                        const FadeSlideEntrance(
                          delay: Duration(milliseconds: 100),
                          child: SetupIllustration(
                            lottieAsset: 'assets/animations/onboarding/lengkapi_profil.json',
                            color: AppColors.emerald,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing24),

                        // ── Header ──
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 150),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lengkapi Profilmu',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacing8),
                              Text(
                                'Informasi ini akan ditampilkan di profil dan papan peringkat.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing24),

                        // ── Username ──
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 300),
                          child: GenesisTextField(
                            label: 'Username',
                            hint: 'contoh: eco_warrior',
                            controller: _usernameController,
                            validator: Validators.username,
                            prefixIcon: Icons.alternate_email_rounded,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing16),

                        // ── Nama Lengkap ──
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 450),
                          child: GenesisTextField(
                            label: 'Nama Lengkap',
                            hint: 'Nama yang ditampilkan di profil',
                            controller: _fullNameController,
                            validator: Validators.fullName,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing24),

                        // ── Lokasi (pre-filled dari Step 2) ──
                        if (setupState.province != null) ...[
                          FadeSlideEntrance(
                            delay: const Duration(milliseconds: 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lokasi Terdaftar',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppConstants.spacing16),
                                  decoration: BoxDecoration(
                                    color: AppColors.emeraldLight.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                    border: Border.all(
                                      color: AppColors.emerald.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded,
                                          color: AppColors.emerald, size: 20),
                                      const SizedBox(width: AppConstants.spacing12),
                                      Expanded(
                                        child: Text(
                                          '${setupState.cityOrDistrict}, ${setupState.province}',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing32),
                        ],

                        // ── Submit ──
                        FadeSlideEntrance(
                          delay: const Duration(milliseconds: 750),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GenesisButton(
                                text: 'Selesai & Mulai! 🚀',
                                onPressed: _isSubmitting ? null : _onSubmit,
                                isLoading: _isSubmitting,
                              ),
                              if (kDebugMode) ...[
                                const SizedBox(height: AppConstants.spacing16),
                                TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(OnboardingBypassed());
                                    context.goNamed(Routes.homeName);
                                  },
                                  child: Text(
                                    'Bypass Onboarding (Mode Debug) 🚀',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.navy600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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
      },
    );
  }
}
