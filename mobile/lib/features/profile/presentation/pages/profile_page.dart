import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  ProfileModel? _profile;
  bool _isLoadingProfile = true;
  String? _equippedBadgeCode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _loadEquippedBadge();
  }

  Future<void> _loadEquippedBadge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _equippedBadgeCode = prefs.getString('equipped_badge_code');
        });
      }
    } catch (_) {}
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
      // Mock defaults: 1st 2 are unlocked
      return code == 'first_report' || code == 'streak_3';
    }
    return _profile!.badges.any((b) => b.code.toLowerCase() == code.toLowerCase());
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                offset: Offset(0, 4),
                blurRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Keluar',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Apakah Anda yakin ingin keluar dari akun Anda?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(SignOutRequested());
                      },
                      child: Text(
                        'Keluar',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getBadgeSvg(String code) {
    switch (code) {
      case 'first_report':
        return AppSvgs.badgePioneer;
      case 'streak_3':
        return AppSvgs.badgeEnthusiast;
      case 'streak_7':
        return AppSvgs.badgeRiverHero;
      case 'toxic_buster':
        return AppSvgs.badgeCleanup;
      case 'green_hero':
        return AppSvgs.badgeActivist;
      case 'spotter':
        return AppSvgs.badgeSpotter;
      case 'forester':
        return AppSvgs.badgeForester;
      case 'fauna_guard':
        return AppSvgs.badgeFaunaGuard;
      default:
        return null;
    }
  }

  String _getBadgeTitle(String code) {
    switch (code) {
      case 'first_report':
        return 'Perintis';
      case 'streak_3':
        return 'Pecinta';
      case 'streak_7':
        return 'Eco Warrior';
      case 'toxic_buster':
        return 'Anti Limbah';
      case 'green_hero':
        return 'Hero Genesis';
      case 'spotter':
        return 'Detektor';
      case 'forester':
        return 'Rimbawan';
      case 'fauna_guard':
        return 'Saksi Satwa';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Profil Eco Warrior',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: 'Keluar',
              onPressed: _showLogoutConfirmDialog,
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            Positioned.fill(
              child: _buildShimmerLoading(),
            ),
          ],
        ),
      );
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

    // Count unlocked badges out of 8
    int unlockedCount = 0;
    final badgeCodes = [
      'first_report',
      'streak_3',
      'streak_7',
      'toxic_buster',
      'green_hero',
      'spotter',
      'forester',
      'fauna_guard'
    ];
    for (var code in badgeCodes) {
      if (_hasBadge(code)) unlockedCount++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Eco Warrior',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            tooltip: 'Keluar',
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Color(0xFFE2E8F0), height: 1.0, thickness: 1.5),
        ),
      ),
      body: Stack(
        children: [
          // Subtle blueprint grid pattern background to add premium character/texture
          Positioned.fill(
            child: CustomPaint(
              painter: const GridBackgroundPainter(),
            ),
          ),

          RefreshIndicator(
            onRefresh: _fetchProfile,
            color: AppColors.navy900,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.pagePaddingH,
                  right: AppConstants.pagePaddingH,
                  top: 20,
                  bottom: 110, // Avoid overlapping with floating bottom navbar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Hero Profile Card (Claymorphic, Premium & 3D Soft) ──
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 50),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacing20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF0F172A),
                            offset: Offset(4, 4),
                            blurRadius: 0,
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
                              // User Info with Equipped Badge next to the name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            fullName,
                                            style: AppTextStyles.headlineSmall.copyWith(
                                              color: AppColors.navy900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (_equippedBadgeCode != null && _getBadgeSvg(_equippedBadgeCode!) != null) ...[
                                          const SizedBox(width: 8),
                                          Tooltip(
                                            message: _getBadgeTitle(_equippedBadgeCode!),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.gold.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.gold.withValues(alpha: 0.4),
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: SvgPicture.string(
                                                _getBadgeSvg(_equippedBadgeCode!)!,
                                                width: 18,
                                                height: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
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
                  
                  // Mascot encouragement bubble (free-floating style)
                  _buildProfileMascotBubble(fullName, level),
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
                                iconColor: const Color(0xFF059669),
                                bgColor: const Color(0xFFECFDF5),
                                textColor: const Color(0xFF065F46),
                                lottieAsset: 'assets/animations/achievements/Image.json',
                                lottieRepeat: false,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Point',
                                value: '${xp * 3}',
                                icon: Icons.monetization_on_rounded,
                                iconColor: const Color(0xFFD97706),
                                bgColor: const Color(0xFFFFFBEB),
                                textColor: const Color(0xFF78350F),
                                lottieAsset: 'assets/animations/achievements/badge.json',
                                lottieRepeat: false,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Streak Aktif',
                                value: '$activeStreak Hari',
                                icon: Icons.local_fire_department_rounded,
                                iconColor: const Color(0xFFE11D48),
                                bgColor: const Color(0xFFFFF1F2),
                                textColor: const Color(0xFF9F1239),
                                lottieAsset: 'assets/animations/achievements/strike_fire.json',
                                lottieRepeat: true,
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
                    delay: const Duration(milliseconds: 120),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF0F172A), width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF0F172A),
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
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
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push(Routes.badges).then((_) => _loadEquippedBadge());
                                },
                                child: Text(
                                  'Lihat Semua',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.navy600,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                              _buildBadgeItem(AppSvgs.badgePioneer, 'Perintis', _hasBadge('first_report')),
                              _buildBadgeItem(AppSvgs.badgeEnthusiast, 'Pecinta', _hasBadge('streak_3')),
                              _buildBadgeItem(AppSvgs.badgeRiverHero, 'Eco Warrior', _hasBadge('streak_7')),
                              _buildBadgeItem(AppSvgs.badgeCleanup, 'Anti Limbah', _hasBadge('toxic_buster')),
                              _buildBadgeItem(AppSvgs.badgeActivist, 'Hero Genesis', _hasBadge('green_hero')),
                              _buildBadgeItem(AppSvgs.badgeSpotter, 'Detektor', _hasBadge('spotter')),
                              _buildBadgeItem(AppSvgs.badgeForester, 'Rimbawan', _hasBadge('forester')),
                              _buildBadgeItem(AppSvgs.badgeFaunaGuard, 'Saksi Satwa', _hasBadge('fauna_guard')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildProfileMascotBubble(String displayName, int level) {
    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0F172A), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF0F172A),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesan Geni',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(text: 'Hebat, '),
                        TextSpan(
                          text: displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '! Kamu telah mencapai Level $level. Kumpulkan lebih banyak XP untuk menjadi Eco Warrior Legendaris! 🚀',
                        ),
                      ],
                    ),
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
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
    String? lottieAsset,
    bool lottieRepeat = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0F172A),
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0F172A),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (lottieAsset != null)
            SizedBox(
              width: 48,
              height: 48,
              child: Lottie.asset(lottieAsset, repeat: lottieRepeat),
            )
          else
            Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
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
                  ? const [
                      BoxShadow(
                        color: Color(0xFFFEF3C7),
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: SvgPicture.string(
                svgContent,
                colorFilter: unlocked
                    ? null
                    : const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      0.6, 0,
                      ]),
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppConstants.pagePaddingH,
        right: AppConstants.pagePaddingH,
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        bottom: 110,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Profile Card Shimmer ──
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar Shimmer
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing20),
                      // User Info Shimmer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing8),
                            Container(
                              width: 90,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Container(
                                  width: 100,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
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
                  // Divider Shimmer
                  Container(
                    height: 1.5,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  // Progress XP Shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Stats Title Shimmer ──
            Row(
              children: [
                Container(
                  width: 150,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Stats Row Shimmer ──
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(width: 32, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 4),
                        Container(width: 48, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(width: 32, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 4),
                        Container(width: 48, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(width: 32, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 4),
                        Container(width: 48, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Badges Header Shimmer ──
            Row(
              children: [
                Container(
                  width: 180,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Grid Shimmer ──
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: List.generate(
                8,
                (_) => Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
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

class GridBackgroundPainter extends CustomPainter {
  const GridBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0) // Very light slate line for grid pattern
      ..strokeWidth = 1.0;

    const double step = 28.0; // Distance between grid lines

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) => false;
}
