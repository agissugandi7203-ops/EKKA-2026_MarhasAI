import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/splash_logo.dart';

/// Splash screen Genesis.id.
///
/// Tagline selama [AppConstants.splashDuration],
/// kemudian auto-navigate berdasarkan status autentikasi & onboarding.
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
  StreamSubscription? _authSubscription;

  // State variabel untuk fitur Update Checker
  bool _needsUpdate = false;
  String _latestVersion = '';
  String _updateUrl = '';

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
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuint),
      ),
    );

    _controller.forward();
  }

  // Helper fungsi untuk membandingkan dua versi semantik (e.g. 1.0.0 vs 1.1.0)
  bool _isVersionOlder(String current, String target) {
    try {
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final targetParts = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        final targetVal = i < targetParts.length ? targetParts[i] : 0;
        if (currentVal < targetVal) return true;
        if (currentVal > targetVal) return false;
      }
    } catch (e) {
      debugPrint('Error comparing versions: $e');
    }
    return false;
  }

  Future<void> _launchUpdateUrl() async {
    if (_updateUrl.isNotEmpty) {
      final uri = Uri.parse(_updateUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $_updateUrl');
      }
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    // ── Update Checker Logic ──
    Map<String, dynamic>? appConfig;
    try {
      final response = await Supabase.instance.client
          .from('app_config')
          .select()
          .maybeSingle();
      appConfig = response;
    } catch (e) {
      debugPrint('Failed to fetch app config: $e');
    }

    if (appConfig != null && mounted) {
      final minVersion = appConfig['min_version'] as String? ?? '1.0.0';
      final latestVersion = appConfig['latest_version'] as String? ?? '1.0.0';
      final updateUrl = appConfig['update_url'] as String? ?? 'https://genesisHub.web.id';
      final forceUpdateFlag = appConfig['force_update'] as bool? ?? false;

      final currentVersion = AppConstants.appVersion;

      // 1. Cek apakah harus FORCE UPDATE
      final isBelowMinimum = _isVersionOlder(currentVersion, minVersion);
      final isBelowLatestWithForce = forceUpdateFlag && _isVersionOlder(currentVersion, latestVersion);

      if (isBelowMinimum || isBelowLatestWithForce) {
        setState(() {
          _needsUpdate = true;
          _latestVersion = latestVersion;
          _updateUrl = updateUrl;
        });
        return; // Hentikan alur login/routing, paksa update screen
      }

      // 2. Cek apakah ada SOFT UPDATE (Opsional)
      final hasNewerVersion = _isVersionOlder(currentVersion, latestVersion);
      if (hasNewerVersion && context.mounted) {
        final Completer<void> updateDialogCompleter = Completer<void>();
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Update Tersedia'),
            content: Text(
              'Versi baru ($latestVersion) telah tersedia. Update sekarang untuk menikmati fitur terbaik?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  updateDialogCompleter.complete();
                },
                child: const Text('Nanti'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  final uri = Uri.parse(updateUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  navigator.pop();
                  updateDialogCompleter.complete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy900,
                ),
                child: const Text('Update Sekarang'),
              ),
            ],
          ),
        );

        await updateDialogCompleter.future;
      }
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool(AppConstants.keyHasSeenIntro) ?? false;

    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    final state = authBloc.state;

    void redirect(AuthState s) {
      if (s is Authenticated) {
        if (s.needsOnboarding) {
          context.goNamed(Routes.setupWelcomeName);
        } else {
          context.goNamed(Routes.homeName);
        }
      } else {
        if (hasSeenIntro) {
          context.goNamed(Routes.loginName);
        } else {
          context.goNamed(Routes.preOnboardingName);
        }
      }
    }

    if (state is Authenticated || state is Unauthenticated || state is AuthFailure) {
      redirect(state);
    } else {
      // Jika session status masih loading/initial, dengarkan stream sampai selesai memuat
      _authSubscription = authBloc.stream.listen((newState) {
        if (newState is Authenticated || newState is Unauthenticated || newState is AuthFailure) {
          _authSubscription?.cancel();
          _authSubscription = null;
          if (mounted) {
            redirect(newState);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsUpdate) {
      return Scaffold(
        backgroundColor: AppColors.navy900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.system_update_rounded,
                  size: 80,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 32),
                Text(
                  'Pembaruan Wajib Tersedia',
                  style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Versi aplikasi Anda saat ini (${AppConstants.appVersion}) sudah tidak didukung.\n\nHarap perbarui ke versi terbaru ($_latestVersion) untuk melanjutkan menggunakan layanan Genesis.id.',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _launchUpdateUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.navy900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Update Sekarang',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  'Genesis',
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
                    color: const Color(0xFFEFF6FF),
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
                        color: AppColors.burgundy700,
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
