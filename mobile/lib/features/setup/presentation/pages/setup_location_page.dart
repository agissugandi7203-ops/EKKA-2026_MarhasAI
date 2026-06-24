import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../bloc/setup_cubit.dart';
import '../widgets/setup_illustration.dart';
import '../widgets/setup_progress_bar.dart';

/// Step 2 — Izin lokasi & deteksi wilayah otomatis.
///
/// Alur:
/// 1. Request izin GPS
/// 2. Auto-detect lokasi via reverse geocoding
/// 3. Tampilkan hasil (provinsi & kota)
/// 4. User bisa lanjut atau input manual
class SetupLocationPage extends StatefulWidget {
  const SetupLocationPage({super.key});

  @override
  State<SetupLocationPage> createState() => _SetupLocationPageState();
}

class _SetupLocationPageState extends State<SetupLocationPage> {
  bool _isDetecting = false;
  String? _detectedProvince;
  String? _detectedCity;
  String? _errorMessage;

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    try {
      // Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak. Silakan aktifkan di pengaturan.';
          _isDetecting = false;
        });
        return;
      }

      // Dapatkan posisi GPS
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _detectedProvince = place.administrativeArea ?? 'Tidak terdeteksi';
          _detectedCity = place.subAdministrativeArea ??
              place.locality ??
              'Tidak terdeteksi';
          _isDetecting = false;
        });

        // Simpan ke SetupCubit
        if (mounted) {
          context.read<SetupCubit>().setLocation(
                province: _detectedProvince!,
                cityOrDistrict: _detectedCity!,
              );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendeteksi lokasi: ${e.toString()}';
        _isDetecting = false;
      });
    }
  }

  bool get _hasLocation =>
      _detectedProvince != null && _detectedCity != null;

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
                const SetupProgressBar(currentStep: 1, totalSteps: 4),
                const Spacer(),

                // Ilustrasi dengan entrance animation
                const FadeSlideEntrance(
                  delay: Duration(milliseconds: 150),
                  child: SetupIllustration(
                    icon: Icons.location_on_rounded,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing32),

                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Lokasi Wilayahmu',
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
                      'Lokasimu digunakan untuk memasukkanmu ke papan peringkat kota. Data ini tidak akan dibagikan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Hasil Deteksi ──
                if (_hasLocation)
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.emerald, size: 32),
                          const SizedBox(height: AppConstants.spacing8),
                          Text(
                            '$_detectedCity',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.emerald,
                            ),
                          ),
                          Text(
                            '$_detectedProvince',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.emerald.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Error ──
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.spacing16),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(),

                // Buttons container
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Tombol Deteksi ──
                      if (!_hasLocation)
                        GenesisButton(
                          text: _isDetecting ? 'Mendeteksi...' : 'Deteksi Lokasi Otomatis',
                          onPressed: _isDetecting ? null : _detectLocation,
                          isLoading: _isDetecting,
                          prefixIcon: Icons.my_location_rounded,
                        ),

                      // ── Tombol Lanjut ──
                      if (_hasLocation) ...[
                        GenesisButton(
                          text: 'Lanjutkan',
                          onPressed: () =>
                              context.goNamed(Routes.setupNotificationName),
                          prefixIcon: Icons.arrow_forward_rounded,
                        ),
                      ],

                      const SizedBox(height: AppConstants.spacing8),

                      // ── Skip ──
                      GenesisButton(
                        text: _hasLocation ? 'Ubah Lokasi Nanti' : 'Lewati untuk Sekarang',
                        variant: GenesisButtonVariant.text,
                        onPressed: () =>
                            context.goNamed(Routes.setupNotificationName),
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
    );
  }
}
