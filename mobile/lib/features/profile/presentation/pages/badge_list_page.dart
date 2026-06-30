import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class BadgeData {
  final String code;
  final String title;
  final String description;
  final String requirement;
  final String svgString;

  const BadgeData({
    required this.code,
    required this.title,
    required this.description,
    required this.requirement,
    required this.svgString,
  });
}

class BadgeListPage extends StatefulWidget {
  const BadgeListPage({super.key});

  @override
  State<BadgeListPage> createState() => _BadgeListPageState();
}

class _BadgeListPageState extends State<BadgeListPage> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _equippedBadgeCode;

  final List<BadgeData> _badges = const [
    BadgeData(
      code: 'first_report',
      title: 'Perintis',
      description: 'Diberikan sebagai lambang aksi perdana pelopor kebersihan kota.',
      requirement: 'Selesaikan laporan kebersihan pertama Anda di Genesis.',
      svgString: AppSvgs.badgePioneer,
    ),
    BadgeData(
      code: 'streak_3',
      title: 'Pecinta',
      description: 'Diberikan kepada pahlawan lingkungan yang konsisten menjaga kota.',
      requirement: 'Melakukan laporan kebersihan selama 3 hari berturut-turut.',
      svgString: AppSvgs.badgeEnthusiast,
    ),
    BadgeData(
      code: 'streak_7',
      title: 'Eco Warrior',
      description: 'Lencana kehormatan pejuang alam yang tak kenal lelah.',
      requirement: 'Melakukan laporan kebersihan selama 7 hari berturut-turut.',
      svgString: AppSvgs.badgeRiverHero,
    ),
    BadgeData(
      code: 'toxic_buster',
      title: 'Anti Limbah',
      description: 'Penghargaan khusus pembasmi tumpukan limbah berbahaya.',
      requirement: 'Melaporkan tumpukan sampah besar atau limbah B3 yang berhasil ditangani.',
      svgString: AppSvgs.badgeCleanup,
    ),
    BadgeData(
      code: 'green_hero',
      title: 'Hero Genesis',
      description: 'Lencana paling bergengsi bagi pelindung bumi sejati.',
      requirement: 'Menjadi anggota paling aktif dalam kampanye hijau minggu ini.',
      svgString: AppSvgs.badgeActivist,
    ),
    BadgeData(
      code: 'spotter',
      title: 'Detektor',
      description: 'Diberikan kepada pengamat lingkungan dengan mata elang.',
      requirement: 'Mengidentifikasi dan melaporkan 5 lokasi tumpukan sampah liar baru.',
      svgString: AppSvgs.badgeSpotter,
    ),
    BadgeData(
      code: 'forester',
      title: 'Rimbawan',
      description: 'Lencana khusus pelindung paru-paru kota.',
      requirement: 'Berpartisipasi dalam penanaman pohon atau penanganan sampah taman kota.',
      svgString: AppSvgs.badgeForester,
    ),
    BadgeData(
      code: 'fauna_guard',
      title: 'Saksi Satwa',
      description: 'Pelindung keanekaragaman hayati dari pencemaran lingkungan.',
      requirement: 'Menyelamatkan satwa liar dari lokasi pencemaran air atau sampah.',
      svgString: AppSvgs.badgeFaunaGuard,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileRepo = context.read<ProfileRepository>();
    try {
      final prefs = await SharedPreferences.getInstance();
      _equippedBadgeCode = prefs.getString('equipped_badge_code');
      
      _profile = await profileRepo.getMyProfile();
    } catch (_) {
      // Offline fallback
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isUnlocked(String code) {
    if (_profile == null) {
      // Offline default: first two are unlocked
      return code == 'first_report' || code == 'streak_3';
    }
    return _profile!.badges.any((b) => b.code.toLowerCase() == code.toLowerCase());
  }

  Future<void> _equipBadge(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_badge_code', code);
    if (mounted) {
      setState(() {
        _equippedBadgeCode = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Lencana berhasil dipasang!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _unequipBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipped_badge_code');
    if (mounted) {
      setState(() {
        _equippedBadgeCode = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Lencana dilepas.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.navy700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  void _showBadgeDetailDialog(BadgeData badge) {
    final bool unlocked = _isUnlocked(badge.code);
    final bool isEquipped = _equippedBadgeCode == badge.code;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: unlocked ? AppColors.gold.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE2E8F0),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Badge Preview (Claymorphic Style)
                    Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: unlocked
                            ? AppColors.gold.withValues(alpha: 0.08)
                            : AppColors.disabled.withValues(alpha: 0.3),
                        border: Border.all(
                          color: unlocked ? AppColors.gold : const Color(0xFFCBD5E1),
                          width: unlocked ? 3.0 : 1.5,
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
                          badge.svgString,
                          width: 72,
                          height: 72,
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
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      badge.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? AppColors.emeraldLight.withValues(alpha: 0.4)
                            : AppColors.warningLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: unlocked ? AppColors.emerald : AppColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                            size: 14,
                            color: unlocked ? AppColors.emerald : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            unlocked ? 'TERBUKA' : 'TERKUNCI',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: unlocked ? AppColors.emerald : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      badge.description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.navy900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Requirement
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.navy50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Cara Mendapatkan:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge.requirement,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.navy700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Actions
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
                              'Kembali',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (unlocked) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEquipped ? AppColors.navy800 : AppColors.gold,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                if (isEquipped) {
                                  await _unequipBadge();
                                } else {
                                  await _equipBadge(badge.code);
                                }
                              },
                              child: Text(
                                isEquipped ? 'Lepas' : 'Pasang',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Lencana',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navy900,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy900))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
                vertical: AppConstants.pagePaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 50),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.08),
                            AppColors.gold.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.gold, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pilih dan pasang lencana terbaikmu untuk ditampilkan di halaman profil dan beranda!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.navy900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _badges.length,
                    itemBuilder: (context, index) {
                      final badge = _badges[index];
                      final bool unlocked = _isUnlocked(badge.code);
                      final bool isEquipped = _equippedBadgeCode == badge.code;

                      return FadeSlideEntrance(
                        delay: Duration(milliseconds: 50 + (index * 25)),
                        child: InkWell(
                          onTap: () => _showBadgeDetailDialog(badge),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isEquipped
                                    ? AppColors.gold
                                    : (unlocked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
                                width: isEquipped ? 2.0 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isEquipped ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
                                  offset: const Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Badge SVG icon (Claymorphic)
                                      Center(
                                        child: Container(
                                          width: 72,
                                          height: 72,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: unlocked
                                                ? AppColors.gold.withValues(alpha: 0.06)
                                                : AppColors.disabled.withValues(alpha: 0.2),
                                            border: Border.all(
                                              color: unlocked ? AppColors.gold.withValues(alpha: 0.3) : Colors.transparent,
                                              width: 1,
                                            ),
                                          ),
                                          child: SvgPicture.string(
                                            badge.svgString,
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
                                      const SizedBox(height: 12),
                                      // Title
                                      Text(
                                        badge.title,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: unlocked ? AppColors.navy900 : AppColors.textDisabled,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Subtitle requirement
                                      Text(
                                        unlocked ? 'Ketuk untuk Detail' : 'Terkunci',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: unlocked ? AppColors.textSecondary : AppColors.textDisabled,
                                          fontSize: 11,
                                          fontWeight: unlocked ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Active Equip Indicator
                                if (isEquipped)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Aktif',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
