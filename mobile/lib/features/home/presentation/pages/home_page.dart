import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/widgets/auth_listener_wrapper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Halaman beranda (placeholder).
///
/// Membuktikan bahwa seluruh flow navigasi berjalan dengan benar.
/// Akan diperluas dengan fitur-fitur utama (reports, leaderboard, dll).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthListenerWrapper(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Genesis.id'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Keluar',
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacing32),

                // ── Welcome Card ──
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  decoration: AppDecorations.cardElevated,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 40,
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Selamat Datang! 🎉',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'Kamu berhasil masuk ke Genesis.id.\nAyo mulai berkontribusi untuk lingkungan!',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── Quick Action Placeholder ──
                Text(
                  'Aksi Cepat',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppConstants.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.camera_alt_rounded,
                        label: 'Lapor',
                        color: AppColors.emerald,
                        onTap: () {
                          // TODO: Navigate to report feature
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.leaderboard_rounded,
                        label: 'Peringkat',
                        color: AppColors.gold,
                        onTap: () {
                          // TODO: Navigate to leaderboard feature
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.person_rounded,
                        label: 'Profil',
                        color: AppColors.navy600,
                        onTap: () {
                          // TODO: Navigate to profile feature
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card aksi cepat di beranda.
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        decoration: AppDecorations.card,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: AppTextStyles.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
