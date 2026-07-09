import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

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
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileRepo = context.read<ProfileRepository>();
      final profile = await profileRepo.getMyProfile();
      if (mounted) {
        setState(() {
          if (profile.username != null && profile.username!.isNotEmpty) {
            final rawUsername = profile.username!;
            // Jika username tidak valid menurut standard regex, bersihkan otomatis
            if (Validators.username(rawUsername) != null) {
              _usernameController.text = Validators.sanitizeUsername(rawUsername);
            } else {
              _usernameController.text = rawUsername;
            }
          } else if (profile.fullName != null && profile.fullName!.isNotEmpty) {
            // Jika username kosong tapi fullName ada (misal dari Google Sign-In pertama kali),
            // buat username instan yang valid dari fullName.
            _usernameController.text = Validators.sanitizeUsername(profile.fullName!);
          }
          
          if (profile.fullName != null && profile.fullName!.isNotEmpty) {
            _fullNameController.text = profile.fullName!;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading initial profile for setup: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final setupState = context.read<SetupCubit>().state;
      final profileRepo = context.read<ProfileRepository>();

      await profileRepo.onboardProfile(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        province: setupState.province ?? 'Belum diatur',
        cityOrDistrict: setupState.cityOrDistrict ?? 'Belum diatur',
      ).timeout(const Duration(seconds: 12), onTimeout: () {
        throw TimeoutException('Koneksi internet lambat. Silakan coba beberapa saat lagi.');
      });

      if (!mounted) return;
      
      // JANGAN set _isSubmitting = false di sini agar loading overlay tetap tampil 
      // sampai AuthBloc mengalihkan halaman ke Welcome/Home secara otomatis.

      // Memicu bypass onboarding status ke false secara instan untuk langsung beralih ke Welcome page.
      context.read<AuthBloc>().add(OnboardingBypassed());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      final appError = ErrorHandler.handle(e);
      context.showErrorSnackBar('Gagal menyimpan profil: ${appError.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenerWrapper(
      child: _isSubmitting
          ? const Scaffold(
              body: Center(
                child: GenesisLoading(message: 'Menyimpan profil Anda...'),
              ),
            )
          : BlocBuilder<SetupCubit, SetupState>(
              builder: (context, setupState) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
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
                );
              },
            ),
    );
  }
}
