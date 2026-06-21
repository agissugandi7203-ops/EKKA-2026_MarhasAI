import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Animated dot indicator untuk PageView.
///
/// Dot aktif lebih panjang (pill shape) dan berwarna navy.
/// Dot tidak aktif bulat kecil dan abu-abu.
class IntroPageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const IntroPageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: AppConstants.animNormal,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? AppColors.navy700 : AppColors.navy200,
          ),
        );
      }),
    );
  }
}
