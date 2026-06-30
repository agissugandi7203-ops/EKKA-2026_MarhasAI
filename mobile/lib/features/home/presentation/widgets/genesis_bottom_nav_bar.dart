import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_svgs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GenesisBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const GenesisBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 72.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).padding.bottom > 0 ? 16.0 : 20.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Solid 3D Base Bar ──
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
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
              children: [
                // Tab 0: Home
                Expanded(
                  child: _NavBarItem(
                    svgString: AppSvgs.navHome,
                    label: 'Beranda',
                    isSelected: selectedIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                ),
                // Tab 1: Chat
                Expanded(
                  child: _NavBarItem(
                    svgString: AppSvgs.navChat,
                    label: 'AI Chat',
                    isSelected: selectedIndex == 1,
                    onTap: () => onTabSelected(1),
                    badgeCount: 0,
                  ),
                ),
                // Spacer for Center Camera button (so tabs don't overlap it)
                const SizedBox(width: 60.0),
                // Tab 3: Leaderboard
                Expanded(
                  child: _NavBarItem(
                    svgString: AppSvgs.navLeaderboard,
                    label: 'Peringkat',
                    isSelected: selectedIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                ),
                // Tab 4: Profile
                Expanded(
                  child: _NavBarItem(
                    svgString: AppSvgs.navProfile,
                    label: 'Profil',
                    isSelected: selectedIndex == 4,
                    onTap: () => onTabSelected(4),
                  ),
                ),
              ],
            ),
          ),

          // ── Center Camera Button (Floating Island) ──
          Positioned(
            top: -15, // Floating elevated placement
            child: GestureDetector(
              onTap: () => onTabSelected(2),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedScale(
                  scale: selectedIndex == 2 ? 1.08 : 1.0,
                  duration: AppConstants.animFast,
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 62.0,
                    height: 62.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.navy500,
                          AppColors.navy700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1B3A76), // Navy600
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String svgString;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavBarItem({
    required this.svgString,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isSelected ? AppColors.navy700 : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: AppConstants.animFast,
              curve: Curves.easeOutBack,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.string(
                    svgString,
                    colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                    width: 22,
                    height: 22,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: itemColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: AppConstants.animFast,
              height: 4,
              width: isSelected ? 16 : 0,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
