import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
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
          body: IndexedStack(
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
              // Tab 2: Camera/Report Viewfinder (mockup)
              ReportsPage(
                onClose: () => setState(() => _currentIndex = 0),
              ),
              // Tab 3: Leaderboard Podium
              const LeaderboardPage(),
              // Tab 4: Profile & Badges
              const ProfilePage(),
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
}
