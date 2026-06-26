import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../widgets/genesis_bottom_nav_bar.dart';
import '../widgets/home_dashboard_view.dart';

/// Halaman Utama (Home Shell) Genesis.id.
///
/// Menggunakan [IndexedStack] untuk mengelola kelima tab utama secara efisien,
/// mempertahankan state input/scroll pada masing-masing tab, dan mengintegrasikan
/// [GenesisBottomNavBar] gamifikasi kustom.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  
  // Spotlight Tour state: null = inactive, 1 = AI Chat, 2 = Camera, 3 = Peringkat
  int? _spotlightStep;

  @override
  void initState() {
    super.initState();
    _checkTourStatus();
  }

  void _checkTourStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('has_completed_tour') ?? false;
    if (!completed) {
      // Delay slightly for smooth post-onboarding entrance
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _spotlightStep = 1;
          });
        }
      });
    }
  }

  void _nextTourStep() async {
    if (_spotlightStep == null) return;
    if (_spotlightStep! < 3) {
      setState(() {
        _spotlightStep = _spotlightStep! + 1;
      });
    } else {
      _finishTour();
    }
  }

  void _skipTour() {
    _finishTour();
  }

  void _finishTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_tour', true);
    if (mounted) {
      setState(() {
        _spotlightStep = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        // Jika tidak di tab Beranda (0), alihkan kembali ke tab Beranda
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        // Jika di tab Beranda, cek interval waktu back press
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tekan sekali lagi untuk keluar dari aplikasi'),
              backgroundColor: AppColors.navy800,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Keluar dari aplikasi secara aman
        await SystemNavigator.pop();
      },
      child: AuthListenerWrapper(
        child: Scaffold(
          extendBody: true,
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  // Tab 0: Home/Dashboard
                  HomeDashboardView(
                    onNavigateToLeaderboard: () => setState(() => _currentIndex = 3),
                    onNavigateToProfile: () => setState(() => _currentIndex = 4),
                    onNavigateToCamera: () => setState(() => _currentIndex = 2),
                    onNavigateToChat: () => setState(() => _currentIndex = 1),
                  ),
                  // Tab 1: Chatbot AI
                  ChatPage(
                    onClose: () => setState(() => _currentIndex = 0),
                  ),
                  // Tab 2: Camera/Report Viewfinder
                  ReportsPage(
                    onClose: () => setState(() => _currentIndex = 0),
                    isActive: _currentIndex == 2,
                  ),
                  // Tab 3: Leaderboard Podium
                  const LeaderboardPage(),
                  // Tab 4: Profile & Badges
                  const ProfilePage(),
                ],
              ),
              
              // Spotlight Tour overlay widget
              if (_spotlightStep != null) _buildSpotlightOverlay(),
            ],
          ),
          // Sembunyikan bottom bar ketika kamera atau chat aktif untuk tampilan yang imersif
          bottomNavigationBar: (_currentIndex == 1 || _currentIndex == 2)
              ? null
              : GenesisBottomNavBar(
                  selectedIndex: _currentIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSpotlightOverlay() {
    if (_spotlightStep == null) return const SizedBox.shrink();

    String title = '';
    String description = '';
    
    // Icon alignment estimates for bottom bar
    double arrowLeftPosition = 0.0;
    final width = MediaQuery.of(context).size.width;

    if (_spotlightStep == 1) {
      title = '💬 Geni AI Chat';
      description = 'Tanyakan tentang regulasi lingkungan, denda pembuangan sampah, atau panduan hukum ke AI Pintar.';
      arrowLeftPosition = width * 0.28;
    } else if (_spotlightStep == 2) {
      title = '📸 Kamera Scan & Lapor';
      description = 'Ambil foto tumpukan sampah untuk dianalisis oleh AI dan dilaporkan secara aman.';
      arrowLeftPosition = width * 0.5 - 10;
    } else if (_spotlightStep == 3) {
      title = '🏆 Papan Peringkat';
      description = 'Pantau peringkat Anda secara global dan kontribusi kebersihan kota Anda secara real-time.';
      arrowLeftPosition = width * 0.72;
    }

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextTourStep,
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: Stack(
            children: [
              // Popover Card in the Center
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Steps counter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.navy500.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.navy500.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Tutorial $_spotlightStep / 3',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.navy200,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            height: 1.45,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _skipTour,
                              child: Text(
                                'Lewati',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _nextTourStep,
                              child: Text(
                                _spotlightStep == 3 ? 'Mulai' : 'Lanjut',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Arrow and Highlight circle at the bottom
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom > 0 ? 98.0 : 102.0, // Just above the bottom bar
                left: arrowLeftPosition - 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A bouncing glow indicator
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy500, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy500.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_downward_rounded, color: AppColors.navy500, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
