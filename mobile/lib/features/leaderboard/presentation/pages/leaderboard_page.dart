import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../data/models/user_leaderboard_model.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with AutomaticKeepAliveClientMixin {
  int _selectedFilter = 0; // 0 = Lokasi Saya (City), 1 = Provinsi Saya, 2 = Nasional
  String _selectedKabupaten = 'Kota Bandung';
  String _selectedProvinsi = 'Jawa Barat';

  String? _userCity;
  String? _userProvince;

  List<UserLeaderboardModel> _leaderboardList = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _victoryPopupShown = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _leaderboardList.isEmpty;
      _errorMessage = null;
    });

    // Trigger tantangan harian (memeriksa leaderboard)
    DioClient.completeChallenge('check_leaderboard');

    // Ambil references ke repository sebelum ada async gap (BuildContext safety)
    final profileRepo = context.read<ProfileRepository>();
    final repo = context.read<LeaderboardRepository>();

    try {
      // Ambil lokasi real-time pengguna dari profil jika belum di-cache
      if (_userCity == null || _userProvince == null) {
        final profile = await profileRepo.getMyProfile();
        _userCity = profile.cityOrDistrict ?? 'Kota Bandung';
        _userProvince = profile.province ?? 'Jawa Barat';

        _selectedKabupaten = _userCity!;
        _selectedProvinsi = _userProvince!;
      }

      List<UserLeaderboardModel> list;
      if (_selectedFilter == 0) {
        list = await repo.getGlobalLeaderboard(city: _selectedKabupaten);
      } else if (_selectedFilter == 1) {
        list = await repo.getGlobalLeaderboard(province: _selectedProvinsi);
      } else {
        list = await repo.getGlobalLeaderboard();
      }

      if (mounted) {
        setState(() {
          _leaderboardList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback anggun ke default jika offline atau terjadi error
          _userCity ??= 'Kota Bandung';
          _userProvince ??= 'Jawa Barat';
          _selectedKabupaten = _userCity!;
          _selectedProvinsi = _userProvince!;

          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // --- ELEGANT & CLEAN MATTE DECORATIONS ---

  Decoration _clayDecoration({
    required Color color,
    double radius = 24,
    Color? shadowColor,
  }) {
    final hsl = HSLColor.fromColor(color);
    final darkColor = shadowColor ?? hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.black.withValues(alpha: 0.12),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: darkColor,
          offset: const Offset(0, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  Decoration _clayCardDecoration({
    required Color color,
    double radius = 24,
    bool isSelf = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isSelf ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelf 
              ? const Color(0xFFD97706).withValues(alpha: 0.08)
              : const Color(0xFF0F172A).withValues(alpha: 0.04),
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
        BoxShadow(
          color: isSelf
              ? const Color(0xFFD97706).withValues(alpha: 0.04)
              : const Color(0xFF0F172A).withValues(alpha: 0.02),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Cari ID pengguna aktif dari AuthBloc
    final authState = context.watch<AuthBloc>().state;
    String? currentUserId;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    // Cari peringkat pengguna saat ini
    UserLeaderboardModel? currentUserEntry;
    int currentUserIndex = -1;
    if (currentUserId != null) {
      for (int i = 0; i < _leaderboardList.length; i++) {
        if (_leaderboardList[i].id == currentUserId) {
          currentUserEntry = _leaderboardList[i];
          currentUserIndex = i;
          break;
        }
      }
    }

    if (currentUserIndex != -1 && currentUserIndex < 3 && !_victoryPopupShown) {
      _victoryPopupShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryPopup(currentUserIndex + 1);
      });
    }

    // Pemisahan 3 besar dan baris sisanya
    final firstUser = _leaderboardList.isNotEmpty ? _leaderboardList[0] : null;
    final secondUser = _leaderboardList.length > 1 ? _leaderboardList[1] : null;
    final thirdUser = _leaderboardList.length > 2 ? _leaderboardList[2] : null;

    final listEntries = _leaderboardList.length > 3 ? _leaderboardList.sublist(3) : <UserLeaderboardModel>[];

    // Label tab dinamis berbasis lokasi riil
    final String cityLabel = _userCity ?? 'Lokasi';
    final String provinceLabel = _userProvince ?? 'Provinsi';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Subtle blueprint grid pattern background to add premium character/texture
          Positioned.fill(
            child: CustomPaint(
              painter: const GridBackgroundPainter(),
            ),
          ),

          RefreshIndicator(
            onRefresh: _fetchLeaderboard,
            color: AppColors.navy900,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 52),

                  // Custom AppBar
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48),
                          Text(
                            'Papan Peringkat',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🏆 XP didapatkan dari penyelesaian pelaporan dan tantangan harian di wilayahmu.',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.navy800,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location Filter Tabs
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: _buildLocationFilter(cityLabel, provinceLabel),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPodiumShimmer(),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Center(
                        child: Text(
                          'Gagal memuat leaderboard: $_errorMessage',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    // Podium UI (Elegant Solid Deep Navy Panel)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 24, 10, 16),
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
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Rank 2 (Left)
                            Expanded(
                              child: AnimatedPodiumPosition(
                                user: secondUser,
                                fallbackName: 'Peringkat 2',
                                rank: 2,
                                badge: '🥈',
                                color: const Color(0xFF94A3B8), // Elegant Matte Muted Silver
                                targetHeight: 85,
                                startDelay: const Duration(milliseconds: 200),
                                clayDecorationBuilder: _clayDecoration,
                              ),
                            ),
                            // Rank 1 (Center)
                            Expanded(
                              child: AnimatedPodiumPosition(
                                user: firstUser,
                                fallbackName: 'Peringkat 1',
                                rank: 1,
                                badge: '👑',
                                color: const Color(0xFFD9A02B), // Elegant Solid Gold
                                targetHeight: 120,
                                isGold: true,
                                startDelay: const Duration(milliseconds: 400),
                                clayDecorationBuilder: _clayDecoration,
                              ),
                            ),
                            // Rank 3 (Right)
                            Expanded(
                              child: AnimatedPodiumPosition(
                                user: thirdUser,
                                fallbackName: 'Peringkat 3',
                                rank: 3,
                                badge: '🥉',
                                color: const Color(0xFFD98A6C), // Elegant Matte Muted Bronze
                                targetHeight: 65,
                                startDelay: const Duration(milliseconds: 600),
                                clayDecorationBuilder: _clayDecoration,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current User standing card
                    if (currentUserEntry != null)
                      FadeSlideEntrance(
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: _clayCardDecoration(
                              color: AppColors.gold50,
                              radius: 24,
                              isSelf: true,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold, width: 2.0),
                                  ),
                                  child: ClipOval(
                                    child: currentUserEntry.avatarUrl != null
                                        ? Image.network(currentUserEntry.avatarUrl!, fit: BoxFit.cover)
                                        : SvgPicture.string(
                                            AppSvgs.defaultAvatar,
                                            width: 46,
                                            height: 46,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Peringkat Kamu: #${currentUserEntry.rank}',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        currentUserIndex == 0
                                            ? 'Luar biasa! Kamu memimpin papan peringkat saat ini! 👑'
                                            : 'Kumpulkan ${_leaderboardList[currentUserIndex - 1].xp - currentUserEntry.xp} XP lagi untuk menggeser ${_leaderboardList[currentUserIndex - 1].fullName}!',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFFFFBEB),
                                     borderRadius: BorderRadius.circular(16),
                                     border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
                                     boxShadow: [
                                       BoxShadow(
                                         color: const Color(0xFFD97706).withValues(alpha: 0.05),
                                         offset: const Offset(0, 2),
                                         blurRadius: 4,
                                       ),
                                     ],
                                   ),
                                   child: Text(
                                     '${currentUserEntry.xp} XP',
                                     style: AppTextStyles.labelSmall.copyWith(
                                       color: const Color(0xFFB45309),
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Rank List of players
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (listEntries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'Tidak ada data peringkat lain.',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          else
                            ...listEntries.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              return FadeSlideEntrance(
                                delay: Duration(milliseconds: 150 + idx * 70),
                                curve: Curves.easeOutBack,
                                child: _buildRankRow(
                                  user: item,
                                  isSelf: item.id == currentUserId,
                                ),
                              );
                            }),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter(String cityLabel, String provinceLabel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE2E8F0),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab(0, cityLabel),
          _buildFilterTab(1, provinceLabel),
          _buildFilterTab(2, 'Nasional'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final bool isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
            _leaderboardList.clear(); // Clear so it shows shimmer for the new filter
          });
          _fetchLeaderboard();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navy500 : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.navy700, width: 1.5)
                  : null,
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0xFF152D5C),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankRow({
    required UserLeaderboardModel user,
    bool isSelf = false,
  }) {
    final initial = user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _clayCardDecoration(
        color: isSelf ? AppColors.goldLight.withValues(alpha: 0.15) : Colors.white,
        radius: 20,
        isSelf: isSelf,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isSelf ? AppColors.gold : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          user.avatarUrl != null
              ? Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                  ),
                )
              : CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.navy50,
                  child: Text(initial, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy700)),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isSelf ? '${user.fullName} (Kamu)' : user.fullName,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.w600,
                color: AppColors.navy900,
                fontSize: 14,
              ),
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
             decoration: BoxDecoration(
               color: isSelf
                   ? const Color(0xFFFFFBEB)
                   : const Color(0xFFF1F5F9),
               borderRadius: BorderRadius.circular(12),
               border: Border.all(
                 color: isSelf ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                 width: 1.0,
               ),
               boxShadow: [
                 BoxShadow(
                   color: isSelf
                       ? const Color(0xFFD97706).withValues(alpha: 0.05)
                       : const Color(0xFF0F172A).withValues(alpha: 0.02),
                   offset: const Offset(0, 2),
                   blurRadius: 4,
                 ),
               ],
             ),
             child: Text(
               '${user.xp} XP',
               style: AppTextStyles.labelSmall.copyWith(
                 color: isSelf ? const Color(0xFFB45309) : const Color(0xFF475569),
                 fontWeight: FontWeight.bold,
                 fontSize: 10,
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildPodiumShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  void _showVictoryPopup(int rank) {
    final String rankTitle = rank == 1 ? 'Peringkat 1' : rank == 2 ? 'Peringkat 2' : 'Peringkat 3';
    final String message = rank == 1
        ? 'Luar biasa! Anda adalah sang Eco Guardian terbaik di wilayah ini. Terus pertahankan kontribusi hijau Anda!'
        : rank == 2
            ? 'Hebat sekali! Anda berhasil menduduki peringkat kedua. Sedikit lagi menuju puncak pelestari lingkungan!'
            : 'Selamat! Anda masuk ke dalam 3 besar pelestari lingkungan. Kontribusi Anda sangat berarti bagi bumi!';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Dark Slate color matching the premium style
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFD4AF37), // Golden bezel
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.24), // Golden glow
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration Lottie Animation
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Lottie.asset(
                      'assets/animations/leaderboard/first_place.json',
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rank Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7), // Amber 100
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    child: Text(
                      rankTitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF92400E), // Amber 800
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Congratulations Title
                  Text(
                    'Selamat Warga Hebat!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Warm Personalized Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Emerald green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ).copyWith(
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        'Terima Kasih!',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- ANIMATED PODIUM POSITION WIDGET ---

class AnimatedPodiumPosition extends StatefulWidget {
  final UserLeaderboardModel? user;
  final String fallbackName;
  final int rank;
  final String badge;
  final Color color;
  final double targetHeight;
  final bool isGold;
  final Duration startDelay;
  final Decoration Function({required Color color, double radius, Color? shadowColor}) clayDecorationBuilder;

  const AnimatedPodiumPosition({
    super.key,
    required this.user,
    required this.fallbackName,
    required this.rank,
    required this.badge,
    required this.color,
    required this.targetHeight,
    required this.startDelay,
    required this.clayDecorationBuilder,
    this.isGold = false,
  });

  @override
  State<AnimatedPodiumPosition> createState() => _AnimatedPodiumPositionState();
}

class _AnimatedPodiumPositionState extends State<AnimatedPodiumPosition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: widget.targetHeight).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(widget.startDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user?.fullName ?? widget.fallbackName;
    final xp = widget.user != null ? '${widget.user!.xp} XP' : '- XP';
    final initial = widget.user != null ? widget.user!.fullName.substring(0, 1).toUpperCase() : '?';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge / Crown emoji
            Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Text(widget.badge, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 5),

            // Profile Avatar
            Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.isGold ? 50 : 40,
                  height: widget.isGold ? 50 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isGold ? AppColors.gold : widget.color,
                      width: 2.0,
                    ),
                    color: widget.isGold 
                        ? AppColors.gold.withValues(alpha: 0.1) 
                        : widget.color.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.user?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.user!.avatarUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            initial,
                            style: TextStyle(
                              color: widget.isGold ? AppColors.gold : widget.color,
                              fontWeight: FontWeight.bold,
                              fontSize: widget.isGold ? 16 : 14,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Name
            Opacity(
              opacity: _opacityAnimation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  name,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // XP
            Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                xp,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 8.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Claymorphic Rising Stand Bar
            Container(
              width: widget.isGold ? 74 : 64,
              height: _heightAnimation.value,
              decoration: widget.clayDecorationBuilder(
                color: widget.isGold ? const Color(0xFFD9A02B) : widget.color,
                radius: 16,
              ),
              child: _heightAnimation.value > 25
                  ? Center(
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text(
                          '#${widget.rank}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: widget.isGold ? const Color(0xFF78350F) : Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        );
      },
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
