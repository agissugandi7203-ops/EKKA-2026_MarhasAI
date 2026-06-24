import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileRepo = context.read<ProfileRepository>();
      final profile = await profileRepo.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      // Gracefully fall back to mock data when offline or backend profile is not ready yet
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  bool _hasBadge(String code) {
    if (_profile == null) {
      // Mock defaults: 1st 4 are unlocked, last 4 are locked
      return code == 'pioneer' || code == 'spotter' || code == 'enthusiast' || code == 'river_hero';
    }
    return _profile!.badges.any((b) => b.code.toLowerCase() == code.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return _buildShimmerLoading();
    }

    final String username = _profile?.username ?? 'eco_warrior';
    final String fullName = _profile?.fullName ?? 'Eco Warrior';
    final int level = _profile?.level ?? 3;
    final int xp = _profile?.xp ?? 340;
    final int maxXp = level * 150 + 50;
    final int completedReports = _profile?.reportCount ?? 15;
    final int activeStreak = _profile?.currentStreak ?? 7;
    final String location = _profile?.cityOrDistrict != null
        ? '${_profile!.cityOrDistrict}, ${_profile!.province ?? ""}'
        : 'Bandung, Jawa Barat';

    // Count unlocked badges
    int unlockedCount = 0;
    final badgeCodes = ['pioneer', 'spotter', 'enthusiast', 'river_hero', 'forester', 'cleanup', 'fauna_guard', 'activist'];
    for (var code in badgeCodes) {
      if (_hasBadge(code)) unlockedCount++;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Eco Warrior',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navy900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Keluar',
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppConstants.pagePaddingH,
          right: AppConstants.pagePaddingH,
          top: AppConstants.pagePaddingV,
          bottom: 110, // Avoid overlapping with floating bottom navbar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Profile Card (Claymorphic, Fun & Soft) ──
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 50),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy900.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 4,
                      offset: Offset(-2, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with Level Badge Overlay
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.gold, AppColors.burgundy500],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.navy900,
                                backgroundImage: _profile?.avatarUrl != null
                                    ? NetworkImage(_profile!.avatarUrl!)
                                    : null,
                                child: _profile?.avatarUrl == null
                                    ? ClipOval(
                                        child: SvgPicture.string(
                                          AppSvgs.defaultAvatar,
                                          width: 72,
                                          height: 72,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold,
                                ),
                                child: Text(
                                  '$level',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppConstants.spacing20),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.navy900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacing4),
                              Text(
                                '@$username',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      color: AppColors.burgundy500, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing20),
                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    // Progress XP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level $level (Guardian)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.navy700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$xp / $maxXp XP',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.navy100.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final progressWidth = (xp / maxXp).clamp(0.0, 1.0) * constraints.maxWidth;
                              return Container(
                                width: progressWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.gold, Color(0xFFE2B04E)],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            // ── Stats Section ──
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Statistik Pencapaian',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy900,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Laporan Selesai',
                          value: '$completedReports',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Point',
                          value: '${xp * 3}',
                          icon: Icons.monetization_on_rounded,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Streak Aktif',
                          value: '$activeStreak Hari',
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            // ── Badges/Lencana Section ──
            FadeSlideEntrance(
              delay: const Duration(milliseconds: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lencana Tersimpan ($unlockedCount/8)',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Lihat Semua',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.navy600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppConstants.spacing16,
                    crossAxisSpacing: AppConstants.spacing16,
                    children: [
                      _buildBadgeItem(AppSvgs.badgePioneer, 'Pioneer', _hasBadge('pioneer')),
                      _buildBadgeItem(AppSvgs.badgeSpotter, 'Spotter', _hasBadge('spotter')),
                      _buildBadgeItem(AppSvgs.badgeEnthusiast, 'Enthusiast', _hasBadge('enthusiast')),
                      _buildBadgeItem(AppSvgs.badgeRiverHero, 'River Hero', _hasBadge('river_hero')),
                      _buildBadgeItem(AppSvgs.badgeForester, 'Forester', _hasBadge('forester')),
                      _buildBadgeItem(AppSvgs.badgeCleanup, 'Clean-Up', _hasBadge('cleanup')),
                      _buildBadgeItem(AppSvgs.badgeFaunaGuard, 'Fauna Guard', _hasBadge('fauna_guard')),
                      _buildBadgeItem(AppSvgs.badgeActivist, 'Activist', _hasBadge('activist')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.navy900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String svgContent, String title, bool unlocked) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.disabled.withValues(alpha: 0.5),
              border: Border.all(
                color: unlocked ? AppColors.gold : AppColors.divider,
                width: unlocked ? 2.0 : 1.2,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: SvgPicture.string(
                svgContent,
                colorFilter: unlocked
                    ? null
                    : ColorFilter.mode(
                        Colors.grey.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),
        Text(
          title,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            color: unlocked ? AppColors.navy900 : AppColors.textDisabled,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.pagePaddingH),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card Shimmer
            Container(
              height: 180,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            ),
            const SizedBox(height: 32),
            // Stats Title Shimmer
            Container(width: 140, height: 22, color: Colors.white),
            const SizedBox(height: 12),
            // Stats Row Shimmer
            Row(
              children: [
                Expanded(child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
            const SizedBox(height: 32),
            // Badges Header Shimmer
            Container(width: 160, height: 22, color: Colors.white),
            const SizedBox(height: 16),
            // Grid Shimmer
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: List.generate(8, (_) => Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
