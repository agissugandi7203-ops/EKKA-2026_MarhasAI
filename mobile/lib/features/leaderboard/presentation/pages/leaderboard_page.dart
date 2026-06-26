import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../data/models/user_leaderboard_model.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedFilter = 0; // 0 = Kabupaten, 1 = Provinsi, 2 = Nasional
  String _selectedKabupaten = 'Kota Bandung';
  String _selectedProvinsi = 'Jawa Barat';

  List<UserLeaderboardModel> _leaderboardList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _kabupatenList = [
    'Kota Bandung',
    'Kab. Bandung Barat',
    'Kota Cimahi',
    'Kab. Sumedang'
  ];

  final List<String> _provinsiList = [
    'Jawa Barat',
    'DKI Jakarta',
    'Jawa Tengah',
    'Jawa Timur'
  ];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Trigger daily quest challenge completion (viewing leaderboard)
    DioClient.completeChallenge('check_leaderboard');

    try {
      final repo = context.read<LeaderboardRepository>();
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
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active user ID
    final authState = context.watch<AuthBloc>().state;
    String? currentUserId;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    // Find current user standing
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

    // Split top 3 and the rest
    final firstUser = _leaderboardList.isNotEmpty ? _leaderboardList[0] : null;
    final secondUser = _leaderboardList.length > 1 ? _leaderboardList[1] : null;
    final thirdUser = _leaderboardList.length > 2 ? _leaderboardList[2] : null;

    final listEntries = _leaderboardList.length > 3 ? _leaderboardList.sublist(3) : <UserLeaderboardModel>[];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: _fetchLeaderboard,
        color: AppColors.navy900,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Stack(
            children: [
              // Curved Dark Navy Header Banner
              Container(
                height: 440,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navy900,
                      Color(0xFF0F2042),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
              ),

              // Glowing decorative rings
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navy600.withValues(alpha: 0.15),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 52),

                  // Custom AppBar
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48),
                          Text(
                            'Papan Peringkat',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
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
                  const SizedBox(height: 8),

                  // Location filters
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLocationFilter(),
                        const SizedBox(height: 8),
                        _buildLocationSelectorTag(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

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
                    // Podium UI
                    FadeSlideEntrance(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Rank 2 (Left)
                              Expanded(
                                child: _buildPodiumPosition(
                                  user: secondUser,
                                  fallbackName: 'Peringkat 2',
                                  rank: 2,
                                  badge: '🥈',
                                  color: const Color(0xFFC0C0C0),
                                  height: 72,
                                ),
                              ),
                              // Rank 1 (Center)
                              Expanded(
                                child: _buildPodiumPosition(
                                  user: firstUser,
                                  fallbackName: 'Peringkat 1',
                                  rank: 1,
                                  badge: '👑',
                                  color: AppColors.gold,
                                  height: 104,
                                  isGold: true,
                                ),
                              ),
                              // Rank 3 (Right)
                              Expanded(
                                child: _buildPodiumPosition(
                                  user: thirdUser,
                                  fallbackName: 'Peringkat 3',
                                  rank: 3,
                                  badge: '🥉',
                                  color: const Color(0xFFCD7F32),
                                  height: 56,
                                ),
                              ),
                            ],
                          ),
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
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold50, Color(0xFFFDFDFB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navy900.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: currentUserEntry.avatarUrl != null
                                        ? Image.network(currentUserEntry.avatarUrl!, fit: BoxFit.cover)
                                        : SvgPicture.string(
                                            AppSvgs.defaultAvatar,
                                            width: 44,
                                            height: 44,
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
                                            : 'Kumpulkan ${_leaderboardList[currentUserIndex - 1].xp - currentUserEntry.xp} XP lagi untuk geser ${_leaderboardList[currentUserIndex - 1].fullName}!',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
                                  ),
                                  child: Text(
                                    '${currentUserEntry.xp} XP',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.gold,
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

                    // Rank List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (listEntries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
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
                                delay: Duration(milliseconds: 250 + idx * 80),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationSelectorBottomSheet(BuildContext context) {
    final bool isKabupaten = _selectedFilter == 0;
    final List<String> list = isKabupaten ? _kabupatenList : _provinsiList;
    final String current = isKabupaten ? _selectedKabupaten : _selectedProvinsi;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isKabupaten ? 'Pilih Kabupaten/Kota' : 'Pilih Provinsi',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...list.map((loc) {
                final bool isSelected = loc == current;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.navy500 : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    tileColor: isSelected ? AppColors.navy50 : Colors.white,
                    title: Text(
                      loc,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.navy900 : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.navy500)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isKabupaten) {
                          _selectedKabupaten = loc;
                        } else {
                          _selectedProvinsi = loc;
                        }
                      });
                      Navigator.pop(context);
                      _fetchLeaderboard();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationSelectorTag() {
    if (_selectedFilter == 2) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_rounded, color: AppColors.gold, size: 14),
            const SizedBox(width: 6),
            Text(
              'Nasional: Indonesia',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final String label = _selectedFilter == 0 ? _selectedKabupaten : _selectedProvinsi;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLocationSelectorBottomSheet(context),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab(0, 'Kabupaten'),
          _buildFilterTab(1, 'Provinsi'),
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
          });
          _fetchLeaderboard();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? AppColors.navy900 : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPosition({
    required UserLeaderboardModel? user,
    required String fallbackName,
    required int rank,
    required String badge,
    required Color color,
    required double height,
    bool isGold = false,
  }) {
    final name = user?.fullName ?? fallbackName;
    final xp = user != null ? '${user.xp} XP' : '- XP';
    final initial = user != null ? user.fullName.substring(0, 1).toUpperCase() : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(badge, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Container(
          width: isGold ? 48 : 38,
          height: isGold ? 48 : 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isGold ? AppColors.gold : color,
              width: 2.5,
            ),
            color: isGold ? AppColors.gold.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
            boxShadow: isGold
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: user?.avatarUrl != null
                ? ClipOval(child: Image.network(user!.avatarUrl!, width: double.infinity, height: double.infinity, fit: BoxFit.cover))
                : Text(
                    initial,
                    style: TextStyle(
                      color: isGold ? AppColors.gold : color,
                      fontWeight: FontWeight.bold,
                      fontSize: isGold ? 16 : 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          xp,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 9,
            color: AppColors.navy200,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: isGold ? 72 : 62,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGold
                  ? [
                      const Color(0xFFD97706),
                      AppColors.gold,
                      const Color(0xFFFBBF24),
                    ]
                  : [
                      color.withValues(alpha: 0.7),
                      color.withValues(alpha: 0.5),
                      color.withValues(alpha: 0.8),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(
              color: isGold ? AppColors.gold : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
      decoration: BoxDecoration(
        color: isSelf ? AppColors.goldLight.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelf ? AppColors.gold.withValues(alpha: 0.4) : AppColors.divider.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelf
                ? AppColors.gold.withValues(alpha: 0.03)
                : AppColors.navy900.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          if (!isSelf)
            const BoxShadow(
              color: Colors.white,
              blurRadius: 6,
              offset: Offset(-2, -2),
            ),
        ],
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
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.navy50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelf ? AppColors.gold.withValues(alpha: 0.25) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              '${user.xp} XP',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelf ? AppColors.gold : AppColors.navy700,
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
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
