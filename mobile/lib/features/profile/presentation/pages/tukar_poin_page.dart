import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_entrance.dart';
import '../../../../core/widgets/genesis_error_widget.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';

class TukarPoinPage extends StatefulWidget {
  const TukarPoinPage({super.key});

  @override
  State<TukarPoinPage> createState() => _TukarPoinPageState();
}

class _TukarPoinPageState extends State<TukarPoinPage> {
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
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int xp = _profile?.xp ?? 0;
    final int currentPoints = xp * 3;

    final List<Map<String, dynamic>> items = [
      {
        'title': 'Minyak Goreng Sawit Premium 1L',
        'points': 150,
        'image': 'https://images.unsplash.com/photo-1622484211148-154109867941?auto=format&fit=crop&q=80&w=400',
        'description': 'Minyak goreng kelapa sawit bermutu tinggi, bersih dan jernih.',
      },
      {
        'title': 'Beras Sembako Premium 2kg',
        'points': 300,
        'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=400',
        'description': 'Beras poles kualitas super, pulen dan beraroma harum alami.',
      },
      {
        'title': 'Gula Pasir Kristal 1kg',
        'points': 100,
        'image': 'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&q=80&w=400',
        'description': 'Gula tebu murni pilihan, manis alami tanpa pengawet.',
      },
      {
        'title': 'Paket Sembako Lengkap',
        'points': 500,
        'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
        'description': 'Paket ekonomis berisi beras 2kg, minyak 1L, dan gula 1kg.',
      },
      {
        'title': 'Voucher Belanja Indomaret Rp 50.000',
        'points': 250,
        'image': 'https://images.unsplash.com/photo-1549463515-205abc068215?auto=format&fit=crop&q=80&w=400',
        'description': 'Voucher belanja digital yang dapat digunakan di seluruh gerai Indomaret.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy900, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tukar Poin Daur Ulang',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navy900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.navy600,
          backgroundColor: Colors.white,
          onRefresh: _fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Points Balance Card (Claymorphic) ──
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 50),
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
                      borderRadius: BorderRadius.circular(24),
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
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🪙',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo Koin Daur Ulang Anda',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isLoadingProfile
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.white10,
                                      highlightColor: Colors.white24,
                                      child: Container(
                                        width: 120,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '$currentPoints Poin',
                                      style: AppTextStyles.headlineMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Section Title
                FadeSlideEntrance(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Pilihan Hadiah Sembako & Voucher',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy900,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Hadiah List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final int price = item['points'] as int;
                    final bool canRedeem = currentPoints >= price;

                    return FadeSlideEntrance(
                      delay: Duration(milliseconds: 120 + index * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
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
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image Block
                              SizedBox(
                                width: 110,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(22),
                                    bottomLeft: Radius.circular(22),
                                  ),
                                  child: Image.network(
                                    item['image'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.navy100,
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        color: AppColors.textDisabled,
                                        size: 28,
                                      ),
                                    ),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Info Block
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.navy900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] as String,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.gold.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.gold.withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  '🪙',
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$price Poin',
                                                  style: AppTextStyles.labelSmall.copyWith(
                                                    color: AppColors.gold,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              context.showInfoSnackBar(
                                                'Fitur Tukar akan segera hadir: ${item['title']} segera dapat ditukarkan dengan poin Anda!',
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              height: 32,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                gradient: canRedeem
                                                    ? const LinearGradient(
                                                        colors: [AppColors.navy500, AppColors.navy700],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      )
                                                    : const LinearGradient(
                                                        colors: [AppColors.navy100, AppColors.navy50],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                border: Border.all(
                                                  color: canRedeem
                                                      ? Colors.white.withValues(alpha: 0.35)
                                                      : const Color(0xFFCBD5E1),
                                                  width: 1,
                                                ),
                                                boxShadow: canRedeem
                                                    ? [
                                                        BoxShadow(
                                                          color: AppColors.navy500.withValues(alpha: 0.25),
                                                          offset: const Offset(0, 4),
                                                          blurRadius: 8,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white.withValues(alpha: 0.2),
                                                          offset: const Offset(0, -2),
                                                          blurRadius: 4,
                                                          spreadRadius: -1,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                                child: Center(
                                                  child: Text(
                                                    'Tukar',
                                                    style: AppTextStyles.labelSmall.copyWith(
                                                      color: canRedeem ? Colors.white : AppColors.textDisabled,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
