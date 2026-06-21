import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/genesis_button.dart';
import '../widgets/intro_page_indicator.dart';
import '../widgets/intro_slide.dart';

/// Halaman introduction Genesis.id — 3 slide pengenalan fitur utama.
///
/// Slide:
/// 1. Laporan Lingkungan (Emerald)
/// 2. Gamifikasi XP & Lencana (Gold)
/// 3. Kompetisi Kota Terbersih (Burgundy)
///
/// Setelah selesai, menyimpan flag [AppConstants.keyHasSeenIntro]
/// dan mengarahkan ke halaman Login.
class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Data slides — dipisahkan dari widget agar mudah dikustomisasi.
  static const List<_IntroSlideData> _slides = [
    _IntroSlideData(
      icon: Icons.camera_alt_rounded,
      title: 'Laporkan Masalah\nLingkungan',
      description:
          'Ambil foto, tandai lokasi, dan laporkan masalah kebersihan di sekitarmu. AI akan memverifikasi laporanmu secara otomatis.',
      accentColor: AppColors.emerald,
    ),
    _IntroSlideData(
      icon: Icons.emoji_events_rounded,
      title: 'Kumpulkan XP\n& Lencana',
      description:
          'Setiap laporan memberikan XP. Naikkan levelmu, jaga streak harianmu, dan raih lencana eksklusif.',
      accentColor: AppColors.gold,
    ),
    _IntroSlideData(
      icon: Icons.location_city_rounded,
      title: 'Jadikan Kotamu\nTerbersih',
      description:
          'Kontribusimu membantu kotamu naik peringkat. Bersaing dengan kota lain di papan peringkat nasional!',
      accentColor: AppColors.burgundy700,
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasSeenIntro, true);

    if (!mounted) return;
    context.goNamed(Routes.loginName);
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeIntro();
    } else {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: tombol Lewati ──
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppConstants.spacing8,
                  right: AppConstants.spacing16,
                ),
                child: TextButton(
                  onPressed: _completeIntro,
                  child: Text(
                    'Lewati',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView Slides ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return IntroSlide(
                    icon: slide.icon,
                    title: slide.title,
                    description: slide.description,
                    accentColor: slide.accentColor,
                  );
                },
              ),
            ),

            // ── Bottom: Indicator + Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePaddingH,
                AppConstants.spacing16,
                AppConstants.pagePaddingH,
                AppConstants.spacing32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntroPageIndicator(
                    currentPage: _currentPage,
                    pageCount: _slides.length,
                  ),
                  const SizedBox(height: AppConstants.spacing32),
                  GenesisButton(
                    text: _isLastPage ? 'Mulai Sekarang' : 'Selanjutnya',
                    onPressed: _nextPage,
                    prefixIcon:
                        _isLastPage ? Icons.rocket_launch_rounded : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model internal untuk slide introduction.
class _IntroSlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _IntroSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
