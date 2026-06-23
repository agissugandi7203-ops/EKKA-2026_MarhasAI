import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../../core/widgets/genesis_text_field.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../bloc/setup_cubit.dart';
import '../bloc/setup_state.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 4 — Lengkapi profil (username, nama lengkap, konfirmasi lokasi).
///
/// Setelah submit, data dikirim ke [ProfileRepository.onboardProfile]
/// dan user diarahkan ke Home Page.
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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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
      context.goNamed(Routes.homeName);
    } catch (e) {
      if (!mounted) return;
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
          backgroundColor: AppColors.surface,
          body: SafeArea(
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
                    const SizedBox(height: AppConstants.spacing32),

                    // ── Header ──
                    Text(
                      'Lengkapi Profilmu',
                      style: AppTextStyles.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Informasi ini akan ditampilkan di profil dan papan peringkat.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacing32),

                    // ── Username ──
                    GenesisTextField(
                      label: 'Username',
                      hint: 'contoh: eco_warrior',
                      controller: _usernameController,
                      validator: Validators.username,
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // ── Nama Lengkap ──
                    GenesisTextField(
                      label: 'Nama Lengkap',
                      hint: 'Nama yang ditampilkan di profil',
                      controller: _fullNameController,
                      validator: Validators.fullName,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // ── Lokasi (pre-filled dari Step 2) ──
                    if (setupState.province != null) ...[
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
                          color: AppColors.navy50,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                          border: Border.all(color: AppColors.navy200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.navy600, size: 20),
                            const SizedBox(width: AppConstants.spacing12),
                            Expanded(
                              child: Text(
                                '${setupState.cityOrDistrict}, ${setupState.province}',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing32),
                    ],

                    // ── Submit ──
                    GenesisButton(
                      text: 'Selesai & Mulai! 🚀',
                      onPressed: _isSubmitting ? null : _onSubmit,
                      isLoading: _isSubmitting,
                    ),
                    const SizedBox(height: AppConstants.spacing32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
