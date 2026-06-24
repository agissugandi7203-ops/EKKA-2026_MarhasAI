import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/splash_logo.dart';

/// Splash screen Genesis.id.
///
/// Menampilkan logo animasi + tagline selama [AppConstants.splashDuration],
/// kemudian auto-navigate berdasarkan:
/// - Pertama kali buka → Introduction
/// - Sudah pernah buka → Login
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _startLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();

    // Trigger smooth loading indicator animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _startLoading = true);
      }
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15), // Lebih halus & soft (bukan 0.3)
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuint), // Transisi eksponensial premium
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool(AppConstants.keyHasSeenIntro) ?? false;

    if (!mounted) return;

    if (hasSeenIntro) {
      context.goNamed(Routes.loginName);
    } else {
      context.goNamed(Routes.preOnboardingName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              Color(0xFFE8F6F0), // Sangat lembut hijau mint
              Color(0xFFFAFAF8), // Warm white surface
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo animasi
              const SplashLogo(),
              const SizedBox(height: AppConstants.spacing32),

              // Nama aplikasi
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Genesis.id',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing12),

              // Tagline
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Laporkan. Kumpulkan. Ubah Dunia.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Spacer(),

              // Indikator loading linear yang elegan di bagian bawah
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.easeInOut,
                      width: _startLoading ? 140 : 0,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing40),
            ],
          ),
        ),
      ),
    );
  }
}
