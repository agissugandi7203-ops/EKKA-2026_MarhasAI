import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ios_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/intro_page_indicator.dart';

/// Halaman onboarding Genesis.id — 3 slide pengenalan fitur utama + Halaman Login.
///
/// Setiap slide memiliki gambar latar belakang fullscreen yang representatif
/// dengan shadow gradient bottom-to-top agar tombol di bawah tetap terlihat jelas.
/// Button navigasi di bawah berganti nama sesuai slide.
/// Slide keempat (indeks 3) merender LoginPage secara langsung, sehingga
/// pengguna dapat melakukan swipe (gulir) kiri-kanan untuk beralih antara onboarding dan login.
class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_IntroSlideData> _slides = [
    _IntroSlideData(
      title: 'Laporkan Masalah\nLingkungan',
      description:
          'Ambil foto, tandai lokasi, dan laporkan masalah kebersihan di sekitarmu. AI akan memverifikasi laporanmu secara otomatis.',
      imageUrl: 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?q=80&w=1080',
    ),
    _IntroSlideData(
      title: 'Kumpulkan XP\n& Lencana',
      description:
          'Setiap laporan memberikan XP. Naikkan levelmu, jaga streak harianmu, dan raih lencana eksklusif.',
      imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1080',
    ),
    _IntroSlideData(
      title: 'Jadikan Kotamu\nTerbersih',
      description:
          'Kontribusimu membantu kotamu naik peringkat. Bersaing dengan kota lain di papan peringkat nasional!',
      imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?q=80&w=1080',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasSeenIntro, true);
  }

  void _onNextPressed() {
    if (_currentPage == _slides.length - 1) {
      _pageController.animateToPage(
        _slides.length,
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipIntro() {
    _markIntroSeen();
    _pageController.animateToPage(
      _slides.length,
      duration: AppConstants.animNormal,
      curve: Curves.easeInOut,
    );
  }

  String _getButtonText() {
    if (_currentPage == 0) return 'Explore Features';
    if (_currentPage == 1) return 'Track Progress';
    return 'Go To Login Page';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAtLogin = _currentPage == _slides.length;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.needsOnboarding) {
            context.goNamed(Routes.setupWelcomeName);
          } else {
            context.goNamed(Routes.homeName);
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background Image PageView (Fullscreen) ──
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length + 1,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  if (index == _slides.length) {
                    _markIntroSeen();
                  }
                },
                itemBuilder: (context, index) {
                  if (index == _slides.length) {
                    // Slide ke-4 adalah halaman login utama secara penuh
                    return const LoginPage();
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          _slides[index].imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: AppColors.navy800,
                              highlightColor: AppColors.navy700,
                              child: Container(color: AppColors.navy800),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: AppColors.navy800);
                          },
                        ),
                      ),
                      // Gradient Shadow (Bottom-to-Top Overlay) khusus untuk slide onboarding
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.45),
                                AppColors.navy900.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.45, 0.85],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Main Content Layout (Hanya dirender jika tidak di Halaman Login) ──
            if (!isAtLogin)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                    vertical: AppConstants.pagePaddingV,
                  ),
                  child: Column(
                    children: [
                      // Header: Skip button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _skipIntro,
                          child: Text(
                            'Lewati',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Title & Description (Transisi halus dengan AnimatedSwitcher)
                      AnimatedSwitcher(
                        duration: AppConstants.animNormal,
                        child: _currentPage < _slides.length
                            ? Column(
                                key: ValueKey<int>(_currentPage),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _slides[_currentPage].title,
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppConstants.spacing16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      _slides[_currentPage].description,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppConstants.spacing40),

                      // Dot Indicator
                      IntroPageIndicator(
                        currentPage: _currentPage,
                        pageCount: _slides.length,
                      ),
                      const SizedBox(height: AppConstants.spacing32),

                      // Navigation Button (iOS-Style Capsule)
                      IosButton(
                        text: _getButtonText(),
                        backgroundColor: Colors.white,
                        textColor: AppColors.navy900,
                        onPressed: _onNextPressed,
                      ),
                      const SizedBox(height: AppConstants.spacing24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IntroSlideData {
  final String title;
  final String description;
  final String imageUrl;

  const _IntroSlideData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
