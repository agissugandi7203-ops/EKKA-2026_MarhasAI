import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedFilter = 0; // 0 = Kabupaten, 1 = Provinsi, 2 = Nasional
  String _selectedKabupaten = 'Kota Bandung';
  String _selectedProvinsi = 'Jawa Barat';

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

  Map<String, dynamic> get _currentPodium {
    if (_selectedFilter == 0) {
      if (_selectedKabupaten == 'Kota Bandung') {
        return {
          'first': {'name': 'Siti K.', 'xp': '1,850 XP', 'initial': 'S'},
          'second': {'name': 'Rian E.', 'xp': '1,420 XP', 'initial': 'R'},
          'third': {'name': 'Budi W.', 'xp': '1,200 XP', 'initial': 'B'},
        };
      } else if (_selectedKabupaten == 'Kab. Bandung Barat') {
        return {
          'first': {'name': 'Yusuf A.', 'xp': '2,100 XP', 'initial': 'Y'},
          'second': {'name': 'Amanda T.', 'xp': '1,950 XP', 'initial': 'A'},
          'third': {'name': 'Budi W.', 'xp': '1,400 XP', 'initial': 'B'},
        };
      } else if (_selectedKabupaten == 'Kota Cimahi') {
        return {
          'first': {'name': 'Doni Pratama', 'xp': '1,650 XP', 'initial': 'D'},
          'second': {'name': 'Anisa Putri', 'xp': '1,500 XP', 'initial': 'A'},
          'third': {'name': 'Reza Fauzi', 'xp': '1,120 XP', 'initial': 'R'},
        };
      } else {
        return {
          'first': {'name': 'Eka Lestari', 'xp': '1,320 XP', 'initial': 'E'},
          'second': {'name': 'Siti K.', 'xp': '1,250 XP', 'initial': 'S'},
          'third': {'name': 'Rian E.', 'xp': '1,100 XP', 'initial': 'R'},
        };
      }
    } else if (_selectedFilter == 1) {
      if (_selectedProvinsi == 'Jawa Barat') {
        return {
          'first': {'name': 'Amanda T.', 'xp': '2,450 XP', 'initial': 'A'},
          'second': {'name': 'Siti K.', 'xp': '1,850 XP', 'initial': 'S'},
          'third': {'name': 'Yusuf A.', 'xp': '1,700 XP', 'initial': 'Y'},
        };
      } else if (_selectedProvinsi == 'DKI Jakarta') {
        return {
          'first': {'name': 'Farhan H.', 'xp': '3,100 XP', 'initial': 'F'},
          'second': {'name': 'Doni Pratama', 'xp': '2,800 XP', 'initial': 'D'},
          'third': {'name': 'Amanda T.', 'xp': '2,450 XP', 'initial': 'A'},
        };
      } else if (_selectedProvinsi == 'Jawa Tengah') {
        return {
          'first': {'name': 'Rian E.', 'xp': '2,200 XP', 'initial': 'R'},
          'second': {'name': 'Hendra W.', 'xp': '2,010 XP', 'initial': 'H'},
          'third': {'name': 'Siti K.', 'xp': '1,850 XP', 'initial': 'S'},
        };
      } else {
        return {
          'first': {'name': 'Budi W.', 'xp': '2,050 XP', 'initial': 'B'},
          'second': {'name': 'Yusuf A.', 'xp': '1,950 XP', 'initial': 'Y'},
          'third': {'name': 'Anisa Putri', 'xp': '1,800 XP', 'initial': 'A'},
        };
      }
    } else {
      return {
        'first': {'name': 'Farhan H.', 'xp': '4,850 XP', 'initial': 'F'},
        'second': {'name': 'Amanda T.', 'xp': '2,450 XP', 'initial': 'A'},
        'third': {'name': 'Siti K.', 'xp': '1,850 XP', 'initial': 'S'},
      };
    }
  }

  Map<String, dynamic> get _currentUserStanding {
    if (_selectedFilter == 0) {
      if (_selectedKabupaten == 'Kota Bandung') {
        return {
          'rank': '#5',
          'motivational': 'Kumpulkan 240 XP lagi untuk geser Budi W.!',
          'xp': '960 XP',
        };
      } else if (_selectedKabupaten == 'Kab. Bandung Barat') {
        return {
          'rank': '#8',
          'motivational': 'Hebat! Masuk 10 besar Kabupaten. Naikkan 120 XP lagi!',
          'xp': '960 XP',
        };
      } else if (_selectedKabupaten == 'Kota Cimahi') {
        return {
          'rank': '#4',
          'motivational': 'Tinggal sedikit lagi! 160 XP untuk masuk podium #3!',
          'xp': '960 XP',
        };
      } else {
        return {
          'rank': '#14',
          'motivational': 'Ayo! Kumpulkan 80 XP lagi untuk tembus 10 besar!',
          'xp': '960 XP',
        };
      }
    } else if (_selectedFilter == 1) {
      if (_selectedProvinsi == 'Jawa Barat') {
        return {
          'rank': '#12',
          'motivational': 'Kumpulkan 80 XP lagi untuk masuk Top 10 Provinsi! 🚀',
          'xp': '960 XP',
        };
      } else if (_selectedProvinsi == 'DKI Jakarta') {
        return {
          'rank': '#19',
          'motivational': 'Luar biasa! 150 XP lagi untuk tembus Top 15 DKI Jakarta! ⚡',
          'xp': '960 XP',
        };
      } else if (_selectedProvinsi == 'Jawa Tengah') {
        return {
          'rank': '#25',
          'motivational': 'Kerja bagus! 100 XP lagi untuk geser peringkat #24 Jawa Tengah!',
          'xp': '960 XP',
        };
      } else {
        return {
          'rank': '#41',
          'motivational': 'Mantap! 200 XP lagi untuk naik ke peringkat 35 Jawa Timur!',
          'xp': '960 XP',
        };
      }
    } else {
      return {
        'rank': '#142',
        'motivational': 'Kumpulkan 40 XP lagi untuk naik peringkat Nasional! ⚡',
        'xp': '960 XP',
      };
    }
  }

  List<Map<String, dynamic>> get _currentRankList {
    if (_selectedFilter == 0) {
      if (_selectedKabupaten == 'Kota Bandung') {
        return [
          {'rank': 4, 'name': 'Doni Pratama', 'xp': '1,150 XP', 'avatar': '🧑'},
          {'rank': 5, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 6, 'name': 'Anisa Putri', 'xp': '820 XP', 'avatar': '👩'},
          {'rank': 7, 'name': 'Reza Fauzi', 'xp': '750 XP', 'avatar': '👨'},
          {'rank': 8, 'name': 'Eka Lestari', 'xp': '680 XP', 'avatar': '👧'},
        ];
      } else if (_selectedKabupaten == 'Kab. Bandung Barat') {
        return [
          {'rank': 6, 'name': 'Doni Pratama', 'xp': '1,150 XP', 'avatar': '🧑'},
          {'rank': 7, 'name': 'Anisa Putri', 'xp': '1,080 XP', 'avatar': '👩'},
          {'rank': 8, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 9, 'name': 'Reza Fauzi', 'xp': '890 XP', 'avatar': '👨'},
          {'rank': 10, 'name': 'Eka Lestari', 'xp': '790 XP', 'avatar': '👧'},
        ];
      } else if (_selectedKabupaten == 'Kota Cimahi') {
        return [
          {'rank': 3, 'name': 'Reza Fauzi', 'xp': '1,120 XP', 'avatar': '👨'},
          {'rank': 4, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 5, 'name': 'Eka Lestari', 'xp': '920 XP', 'avatar': '👧'},
          {'rank': 6, 'name': 'Doni Pratama', 'xp': '890 XP', 'avatar': '🧑'},
          {'rank': 7, 'name': 'Anisa Putri', 'xp': '820 XP', 'avatar': '👩'},
        ];
      } else {
        return [
          {'rank': 12, 'name': 'Doni Pratama', 'xp': '1,150 XP', 'avatar': '🧑'},
          {'rank': 13, 'name': 'Anisa Putri', 'xp': '1,020 XP', 'avatar': '👩'},
          {'rank': 14, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 15, 'name': 'Reza Fauzi', 'xp': '910 XP', 'avatar': '👨'},
          {'rank': 16, 'name': 'Eka Lestari', 'xp': '880 XP', 'avatar': '👧'},
        ];
      }
    } else if (_selectedFilter == 1) {
      if (_selectedProvinsi == 'Jawa Barat') {
        return [
          {'rank': 10, 'name': 'Rian E.', 'xp': '1,420 XP', 'avatar': '🧑'},
          {'rank': 11, 'name': 'Budi W.', 'xp': '1,200 XP', 'avatar': '🧑'},
          {'rank': 12, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 13, 'name': 'Doni Pratama', 'xp': '850 XP', 'avatar': '🧑'},
          {'rank': 14, 'name': 'Anisa Putri', 'xp': '820 XP', 'avatar': '👩'},
        ];
      } else if (_selectedProvinsi == 'DKI Jakarta') {
        return [
          {'rank': 17, 'name': 'Rian E.', 'xp': '1,120 XP', 'avatar': '🧑'},
          {'rank': 18, 'name': 'Budi W.', 'xp': '1,020 XP', 'avatar': '🧑'},
          {'rank': 19, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 20, 'name': 'Reza Fauzi', 'xp': '910 XP', 'avatar': '👨'},
          {'rank': 21, 'name': 'Eka Lestari', 'xp': '890 XP', 'avatar': '👧'},
        ];
      } else if (_selectedProvinsi == 'Jawa Tengah') {
        return [
          {'rank': 23, 'name': 'Doni Pratama', 'xp': '1,150 XP', 'avatar': '🧑'},
          {'rank': 24, 'name': 'Anisa Putri', 'xp': '1,020 XP', 'avatar': '👩'},
          {'rank': 25, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 26, 'name': 'Reza Fauzi', 'xp': '910 XP', 'avatar': '👨'},
          {'rank': 27, 'name': 'Eka Lestari', 'xp': '880 XP', 'avatar': '👧'},
        ];
      } else {
        return [
          {'rank': 39, 'name': 'Rian E.', 'xp': '1,050 XP', 'avatar': '🧑'},
          {'rank': 40, 'name': 'Budi W.', 'xp': '1,010 XP', 'avatar': '🧑'},
          {'rank': 41, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
          {'rank': 42, 'name': 'Doni Pratama', 'xp': '890 XP', 'avatar': '🧑'},
          {'rank': 43, 'name': 'Anisa Putri', 'xp': '820 XP', 'avatar': '👩'},
        ];
      }
    } else {
      return [
        {'rank': 140, 'name': 'Yusuf A.', 'xp': '1,050 XP', 'avatar': '🧑'},
        {'rank': 141, 'name': 'Rian E.', 'xp': '1,010 XP', 'avatar': '🧑'},
        {'rank': 142, 'name': 'Kamu (EcoWarrior)', 'xp': '960 XP', 'avatar': '🌱', 'isSelf': true},
        {'rank': 143, 'name': 'Budi W.', 'xp': '920 XP', 'avatar': '🧑'},
        {'rank': 144, 'name': 'Doni Pratama', 'xp': '850 XP', 'avatar': '🧑'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPodium = _currentPodium;
    final currentUser = _currentUserStanding;
    final currentList = _currentRankList;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            setState(() {});
          }
        },
        color: AppColors.navy900,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Stack(
            children: [
            // Curved Dark Navy Header Banner
            Container(
              height: 430,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navy900,
                    Color(0xFF0F2042), // Pure Dark Navy
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),

            // Decorative background glowing ring
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navy600.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navy500.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 52), // Space for status bar

                // Custom AppBar inside Stack (Delay 50ms)
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // Spacer to balance info button
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

                // Segmented Location Filter & Location Selector (Delay 100ms)
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

                // Top 3 Podium Columns (Delay 150ms) - Unified Podium Deck Card
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 150),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.65), // Cohesive glass deck
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
                          FadeSlideEntrance(
                            delay: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: _buildPodiumPosition(
                              name: currentPodium['second']!['name']!,
                              xp: currentPodium['second']!['xp']!,
                              rank: 2,
                              badge: '🥈',
                              color: const Color(0xFFC0C0C0),
                              avatarInitial: currentPodium['second']!['initial']!,
                              height: 72,
                            ),
                          ),
                          // Rank 1 (Center)
                          FadeSlideEntrance(
                            delay: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            child: _buildPodiumPosition(
                              name: currentPodium['first']!['name']!,
                              xp: currentPodium['first']!['xp']!,
                              rank: 1,
                              badge: '👑',
                              color: AppColors.gold,
                              avatarInitial: currentPodium['first']!['initial']!,
                              height: 104,
                              isGold: true,
                            ),
                          ),
                          // Rank 3 (Right)
                          FadeSlideEntrance(
                            delay: const Duration(milliseconds: 550),
                            curve: Curves.easeOutBack,
                            child: _buildPodiumPosition(
                              name: currentPodium['third']!['name']!,
                              xp: currentPodium['third']!['xp']!,
                              rank: 3,
                              badge: '🥉',
                              color: const Color(0xFFCD7F32),
                              avatarInitial: currentPodium['third']!['initial']!,
                              height: 56,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Floating User Status Card (Delay 200ms)
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
                          // Current user's avatar representation SVG
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2),
                            ),
                            child: ClipOval(
                              child: SvgPicture.string(
                                AppSvgs.defaultAvatar,
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Rank Standing Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peringkat Kamu: ${currentUser['rank']}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  currentUser['motivational']!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Current Points Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Text(
                              currentUser['xp']!,
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

                // Rank List Rows (Delay 250ms)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...currentList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return FadeSlideEntrance(
                          delay: Duration(milliseconds: 250 + index * 80),
                          curve: Curves.easeOutBack,
                          child: _buildRankRow(
                            rank: item['rank'] as int,
                            name: item['name'] as String,
                            xp: item['xp'] as String,
                            avatarChar: item['avatar'] as String,
                            isSelf: item['isSelf'] == true,
                          ),
                        );
                      }),
                      const SizedBox(height: 120), // Bottom spacer to avoid bottom navbar overlapping
                    ],
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
      // Nasional
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
    required String name,
    required String xp,
    required int rank,
    required String badge,
    required Color color,
    required String avatarInitial,
    required double height,
    bool isGold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal/Crown Badge
        Text(badge, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        // Avatar circle
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
            child: Text(
              avatarInitial,
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
        // Podium Column - Redesigned as a 3D Cylinder
        Container(
          width: isGold ? 72 : 62,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGold
                  ? [
                      const Color(0xFFD97706), // Rich dark gold
                      AppColors.gold,
                      const Color(0xFFFBBF24), // Shiny bright gold
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
    required int rank,
    required String name,
    required String xp,
    required String avatarChar,
    bool isSelf = false,
  }) {
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
          // Subtle top-left highlight for claymorphic puffy feel
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
          // Rank Number
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isSelf ? AppColors.gold : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // User Avatar representation (SVG or CircleAvatar)
          isSelf
              ? Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: SvgPicture.string(
                      AppSvgs.defaultAvatar,
                      width: 36,
                      height: 36,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.navy50,
                  child: Text(avatarChar, style: const TextStyle(fontSize: 16)),
                ),
          const SizedBox(width: 16),
          // User Name
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.w600,
                color: AppColors.navy900,
                fontSize: 14,
              ),
            ),
          ),
          // Points/XP Badge
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
              xp,
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
}
