import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/genesis_loading.dart';
import '../../../../core/network/dio_client.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class HomeDashboardView extends StatefulWidget {
  final VoidCallback onNavigateToLeaderboard;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToCamera;
  final VoidCallback onNavigateToChat;

  const HomeDashboardView({
    super.key,
    required this.onNavigateToLeaderboard,
    required this.onNavigateToProfile,
    required this.onNavigateToCamera,
    required this.onNavigateToChat,
  });

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  ProfileModel? _profile;
  bool _isLoadingProfile = true;
  final ScrollController _scrollController = ScrollController();

  // Dynamic challenges state from backend
  List<Map<String, dynamic>> _challenges = [];
  bool _isLoadingChallenges = true;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchRealProfileData();
    _fetchDailyChallenges();
    // 15-second polling loop
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollProfileDataSilently();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyChallenges() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/gamification/challenges');
      final list = response.data as List? ?? [];
      if (mounted) {
        setState(() {
          _challenges = list.map((c) => {
            'id': c['id'],
            'code': c['code'],
            'title': c['title'],
            'xp': '+${c['xp']} XP',
            'pts': '+${c['points']} Poin',
            'isCompleted': c['isCompleted'] as bool? ?? false,
          }).toList();
          _isLoadingChallenges = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching daily challenges: $e');
      if (mounted) {
        setState(() {
          _isLoadingChallenges = false;
        });
      }
    }
  }

  Future<void> _pollProfileDataSilently() async {
    try {
      final profileRepo = context.read<ProfileRepository>();
      final profile = await profileRepo.getMyProfile();
      if (!mounted) return;
      if (_profile != null) {
        // Level Up popup check
        if (profile.level > _profile!.level) {
          _showLevelUpDialog(profile.level);
        }
        // New Badge popup check
        if (profile.badges.length > _profile!.badges.length) {
          final oldBadgeIds = _profile!.badges.map((b) => b.id).toSet();
          final newBadges = profile.badges.where((b) => !oldBadgeIds.contains(b.id)).toList();
          for (final b in newBadges) {
            _showBadgeUnlockedDialog(b.name, b.description ?? '');
          }
        }
      }
      setState(() {
        _profile = profile;
      });
      _fetchDailyChallenges();
    } catch (e) {
      debugPrint('Error polling profile: $e');
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 LEVEL UP! 🎉',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/animations/achievements/level_up.json',
                  repeat: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat! Level Anda meningkat menjadi',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Level $newLevel',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navy900,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Luar Biasa!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeUnlockedDialog(String badgeName, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏆 LENCANA BARU! 🏆',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.emerald, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded, color: AppColors.emerald, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda telah membuka Lencana Baru:',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                badgeName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Klaim Lencana',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchRealProfileData() async {
    try {
      final profileRepo = context.read<ProfileRepository>();
      final profile = await profileRepo.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return _buildShimmerLoading();
    }

    final String displayName = _profile?.fullName ?? _profile?.username ?? 'Eco Warrior';
    final int level = _profile?.level ?? 3;
    final int xp = _profile?.xp ?? 340;
    final int maxXp = level * 150 + 50; 
    final int completedReports = _profile?.reportCount ?? 15;
    final int activeStreak = _profile?.currentStreak ?? 7;
    final String location = _profile?.cityOrDistrict != null 
        ? '${_profile!.cityOrDistrict}, ${_profile!.province ?? ""}'
        : 'Bandung, Jawa Barat';

    final double progressPercent = (xp / maxXp).clamp(0.0, 1.0);

    return Stack(
      children: [
        // ── 1. Curved Gradient Header Background ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E293B), // Slate 800
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
        ),

        // Decorative background shapes
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navy600.withValues(alpha: 0.15),
            ),
          ),
        ),

        // ── 2. Scrollable Body via CustomScrollView ──
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: _fetchRealProfileData,
            color: AppColors.navy900,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Sticky profile header profile
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderProfileDelegate(
                    profile: _profile,
                    displayName: displayName,
                    location: location,
                    level: level,
                    onNavigateToProfile: widget.onNavigateToProfile,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      // Quick Action Menu (Not sticky anymore, scrolls normally)
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      // Level Progress Card
                      _buildLevelCard(progressPercent, level, activeStreak, completedReports),
                      const SizedBox(height: 20),
                      // Compact Activity Statistics Ring
                      _buildDataStatisticsCard(completedReports, activeStreak),
                      const SizedBox(height: 20),
                      // Bento Grid Card Timbul & Variatif
                      _buildBentoMetrics(activeStreak, completedReports),
                      const SizedBox(height: 28),
                      // Tantangan Harian Quests
                      _buildDailyQuestsHeader(),
                      const SizedBox(height: 16),
                      _buildDailyQuestsList(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE2E8F0),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              icon: Icons.camera_alt_rounded,
              label: 'Lapor',
              color: AppColors.navy700,
              onTap: widget.onNavigateToCamera,
            ),
            _buildQuickActionItem(
              icon: Icons.task_alt_rounded,
              label: 'Tantangan',
              color: AppColors.navy600,
              onTap: () {
                _scrollController.animateTo(
                  450,
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeInOutCubic,
                );
              },
            ),
            _buildQuickActionItem(
              icon: Icons.emoji_events_rounded,
              label: 'Peringkat',
              color: AppColors.navy500,
              onTap: widget.onNavigateToLeaderboard,
            ),
            _buildQuickActionItem(
              icon: Icons.smart_toy_rounded,
              label: 'Tanya AI',
              color: AppColors.navy700,
              onTap: widget.onNavigateToChat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.navy900,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(double progressPercent, int level, int activeStreak, int completedReports) {
    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E293B), // Slate 800
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glowing circular level progress ring
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CustomPaint(
                    painter: LevelProgressPainter(progress: progressPercent),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LV',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$level',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Stats & progress metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
                            ),
                            child: Text(
                              'Eco Guardian',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          Text(
                            'Pahlawan Hijau',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.navy200,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildLevelStatBadge(
                            lottiePath: 'assets/animations/achievements/strike_fire.json',
                            text: '$activeStreak Hari',
                          ),
                          const SizedBox(width: 8),
                          _buildLevelStatBadge(
                            svgContent: AppSvgs.miniCamera,
                            text: '$completedReports Lapor',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cek Leaderboard Button
                GestureDetector(
                  onTap: widget.onNavigateToLeaderboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_outlined, color: AppColors.gold, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Leaderboard',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tukar Poin Button
                GestureDetector(
                  onTap: () {
                    context.pushNamed(Routes.tukarPoinName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.card_giftcard_rounded, color: AppColors.emeraldLight, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Tukar Poin',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelStatBadge({
    String? svgContent,
    String? lottiePath,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lottiePath != null)
            SizedBox(
              width: 14,
              height: 14,
              child: Lottie.asset(lottiePath, repeat: true),
            )
          else if (svgContent != null)
            SvgPicture.string(svgContent, width: 11, height: 11),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataStatisticsCard(int completedReports, int activeStreak) {
    final double reportsRatio = (completedReports / 20.0).clamp(0.1, 1.0);
    final double streakRatio = (activeStreak / 7.0).clamp(0.15, 1.0);
    final int badgeCount = _profile?.badges.length ?? 0;
    final double badgesRatio = (badgeCount / 5.0).clamp(0.1, 1.0);

    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy900.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Statistik',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navy900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pushNamed(Routes.statisticsName),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Selengkapnya',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.navy600,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.navy600, size: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Concentric circular progress graph (shrunk to 86px)
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CustomPaint(
                    painter: ConcentricProgressPainter(
                      track1: reportsRatio,
                      track2: streakRatio,
                      track3: badgesRatio,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                // Horizontal / compact side-by-side layout for legend items
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: const Color(0xFF1E3A8A),
                        title: 'Lapor Selesai',
                        value: '${(reportsRatio * 100).toInt()}% ($completedReports/20)',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: const Color(0xFF6366F1),
                        title: 'Streak Harian',
                        value: '${(streakRatio * 100).toInt()}% ($activeStreak/7 Hari)',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: const Color(0xFF93C5FD),
                        title: 'Lencana Didapat',
                        value: '${(badgesRatio * 100).toInt()}% ($badgeCount/5 Terbuka)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.navy900,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoMetrics(int activeStreak, int completedReports) {
    final String rankLabel = _profile?.rank != null ? '#${_profile!.rank}' : '#1';

    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: _buildBentoCard(
              icon: Icons.local_fire_department_rounded,
              title: 'Streak Aktif',
              value: '$activeStreak Hari',
              iconColor: const Color(0xFFF97316),
              textColor: const Color(0xFFC2410C),
              gradientColors: [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
              lottieAsset: 'assets/animations/achievements/strike_fire.json',
              lottieRepeat: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBentoCard(
              icon: Icons.photo_library_rounded,
              title: 'Laporan',
              value: '$completedReports Selesai',
              iconColor: const Color(0xFF3B82F6),
              textColor: const Color(0xFF1D4ED8),
              gradientColors: [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
              lottieAsset: 'assets/animations/achievements/Image.json',
              lottieRepeat: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: widget.onNavigateToLeaderboard,
              child: _buildBentoCard(
                icon: Icons.emoji_events_rounded,
                title: 'Peringkat',
                value: '$rankLabel Wilayah',
                iconColor: const Color(0xFF10B981),
                textColor: const Color(0xFF047857),
                gradientColors: [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                lottieAsset: 'assets/animations/achievements/trophy.json',
                lottieRepeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color textColor,
    required List<Color> gradientColors,
    String? lottieAsset,
    bool lottieRepeat = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: gradientColors[0],
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          // Elegant color-matched 3D claymorphic bottom-right depth shadow
          BoxShadow(
            color: iconColor.withValues(alpha: 0.14),
            offset: const Offset(0, 8),
            blurRadius: 12,
          ),
          // Clean top-left light source reflection
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.65),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null)
            SizedBox(
              width: 44,
              height: 44,
              child: Lottie.asset(lottieAsset, repeat: lottieRepeat),
            )
          else
            Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestsHeader() {
    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 250),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tantangan Harian',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navy900,
            ),
          ),
          Text(
            'Reset dalam 4 jam',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestsList() {
    if (_isLoadingChallenges) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: GenesisLoading(size: 50),
        ),
      );
    }

    if (_challenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Center(
          child: Text(
            'Tidak ada tantangan aktif hari ini.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Find the first uncompleted quest to highlight
    final firstUncompleted = _challenges.firstWhere(
      (q) => q['isCompleted'] == false,
      orElse: () => _challenges.first,
    );
    final String firstUncompletedId = firstUncompleted['id'] as String;

    return FadeSlideEntrance(
      delay: const Duration(milliseconds: 300),
      child: Column(
        children: List.generate(_challenges.length, (index) {
          final quest = _challenges[index];
          final bool isDone = quest['isCompleted'] as bool;
          final bool isHighlighted = quest['id'] == firstUncompletedId;

          final Widget leadingIcon;
          final String code = quest['code'] as String? ?? '';
          final Color iconBgColor;
          final Color iconColor;

          if (code == 'report_1_waste') {
            leadingIcon = const Icon(Icons.camera_alt_rounded, size: 18);
            iconBgColor = const Color(0xFFE0F2FE); // light blue
            iconColor = AppColors.navy700;
          } else if (code == 'chat_ai') {
            leadingIcon = const Icon(Icons.forum_rounded, size: 18);
            iconBgColor = const Color(0xFFFCE7F3); // light pink
            iconColor = AppColors.burgundy700;
          } else {
            leadingIcon = const Icon(Icons.emoji_events_rounded, size: 18);
            iconBgColor = const Color(0xFFFEF3C7); // light gold
            iconColor = const Color(0xFFB45309);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDone
                    ? const Color(0xFFCBD5E1)
                    : (isHighlighted ? const Color(0xFFFBBF24) : AppColors.divider.withValues(alpha: 0.7)),
                width: isHighlighted && !isDone ? 2.2 : 1.5,
              ),
              boxShadow: isDone
                  ? [
                      BoxShadow(
                        color: AppColors.navy900.withValues(alpha: 0.01),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [
                      // Primary soft-depth bottom shadow
                      BoxShadow(
                        color: (isHighlighted ? const Color(0xFFFBBF24) : AppColors.navy500).withValues(alpha: 0.12),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                      // Inner-emulated top-left highlight shadow
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(0, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Badge (Claymorphic Bubble)
                Container(
                  width: 42,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      (leadingIcon as Icon).icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title and points info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quest['title'] as String? ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDone ? AppColors.textDisabled : AppColors.navy900,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                fontWeight: isDone ? FontWeight.normal : FontWeight.bold,
                                height: 1.45,
                              ),
                            ),
                          ),
                          if (isHighlighted && !isDone) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFBBF24), width: 1),
                              ),
                              child: Text(
                                'Rekomendasi',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFFD97706),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navy50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.navy100, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: AppColors.navy700, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  quest['xp'] as String? ?? '',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.navy700,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navy100.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.navy200.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.navy600, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  quest['pts'] as String? ?? '',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.navy600,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Read-only dynamic checkbox based on isCompleted
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.navy700 : Colors.transparent,
                    border: Border.all(
                      color: isDone ? AppColors.navy700 : AppColors.textDisabled,
                      width: 2.0,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          );
        }),
      ),
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
            const SizedBox(height: 52),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 160, height: 24, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 16, color: Colors.white),
                  ],
                ),
                Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 140,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => Container(width: 58, height: 58, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)))),
            ),
          ],
        ),
      ),
    );
  }
}

// Sticky Header Delegate for Greetings/Profile info
class _StickyHeaderProfileDelegate extends SliverPersistentHeaderDelegate {
  final ProfileModel? profile;
  final String displayName;
  final String location;
  final int level;
  final VoidCallback onNavigateToProfile;

  _StickyHeaderProfileDelegate({
    required this.profile,
    required this.displayName,
    required this.location,
    required this.level,
    required this.onNavigateToProfile,
  });

  @override
  double get minExtent => 70.0 + 35.0; // Padded for safeArea

  @override
  double get maxExtent => 80.0 + 35.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final bool isPinned = shrinkOffset > 5.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isPinned ? const Color(0xFF0F172A) : Colors.transparent,
      padding: EdgeInsets.only(
        top: safeAreaTop + 4,
        bottom: 4,
        left: 20,
        right: 20,
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          // Profile Avatar with Level Badge overlay
          GestureDetector(
            onTap: onNavigateToProfile,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                    gradient: const LinearGradient(
                      colors: [AppColors.navy500, AppColors.navy200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: profile?.avatarUrl != null
                        ? Image.network(
                            profile!.avatarUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => SvgPicture.string(
                              AppSvgs.defaultAvatar,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : SvgPicture.string(
                            AppSvgs.defaultAvatar,
                            width: 40,
                            height: 40,
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navy600,
                    ),
                    child: Text(
                      '$level',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Greetings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hai, $displayName! 👋',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.navy200, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notification Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.navy500,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                context.pushNamed(Routes.notificationsName);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderProfileDelegate oldDelegate) {
    return oldDelegate.profile != profile ||
        oldDelegate.displayName != displayName ||
        oldDelegate.location != location ||
        oldDelegate.level != level;
  }
}

// Concentric Circular Progress Painter for Statistics Summary (shrunk)
class ConcentricProgressPainter extends CustomPainter {
  final double track1; 
  final double track2; 
  final double track3; 

  ConcentricProgressPainter({
    required this.track1,
    required this.track2,
    required this.track3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width < size.height ? size.width : size.height) / 2;
    const double strokeWidth = 7.0;
    const double spacing = 11.0;
    const Color bgTrackColor = Color(0xFFEEF2F6);

    final Paint paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = bgTrackColor
      ..strokeCap = StrokeCap.round;

    final Paint paintFill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track 1: Lapor Selesai (Royal Navy)
    final radius1 = maxRadius - strokeWidth;
    canvas.drawCircle(center, radius1, paintBg);
    final rect1 = Rect.fromCircle(center: center, radius: radius1);
    paintFill.shader = const LinearGradient(
      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    ).createShader(rect1);
    canvas.drawArc(rect1, -1.5708, track1 * 6.28319, false, paintFill);

    // Track 2: Streak Harian (Indigo)
    final radius2 = radius1 - spacing;
    canvas.drawCircle(center, radius2, paintBg);
    final rect2 = Rect.fromCircle(center: center, radius: radius2);
    paintFill.shader = const LinearGradient(
      colors: [Color(0xFF312E81), Color(0xFF6366F1)],
    ).createShader(rect2);
    canvas.drawArc(rect2, -1.5708, track2 * 6.28319, false, paintFill);

    // Track 3: Lencana (Ice Blue)
    final radius3 = radius2 - spacing;
    canvas.drawCircle(center, radius3, paintBg);
    final rect3 = Rect.fromCircle(center: center, radius: radius3);
    paintFill.shader = const LinearGradient(
      colors: [Color(0xFF1E1B4B), Color(0xFF93C5FD)],
    ).createShader(rect3);
    canvas.drawArc(rect3, -1.5708, track3 * 6.28319, false, paintFill);
  }

  @override
  bool shouldRepaint(covariant ConcentricProgressPainter oldDelegate) {
    return oldDelegate.track1 != track1 || oldDelegate.track2 != track2 || oldDelegate.track3 != track3;
  }
}

// Circular progress ring painter for level
class LevelProgressPainter extends CustomPainter {
  final double progress;

  LevelProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4.0;
    const double strokeWidth = 5.0;

    final Paint paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = strokeWidth;

    final Paint paintFill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintBg);

    final rect = Rect.fromCircle(center: center, radius: radius);
    paintFill.shader = const LinearGradient(
      colors: [AppColors.gold, Color(0xFFFBBF24)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -1.5708,
      progress * 6.28319,
      false,
      paintFill,
    );
  }

  @override
  bool shouldRepaint(covariant LevelProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
