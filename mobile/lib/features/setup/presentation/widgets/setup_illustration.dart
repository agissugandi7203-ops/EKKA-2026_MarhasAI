import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';

/// Ilustrasi premium untuk halaman setup dengan animasi melayang lembut.
///
/// Menampilkan ikon atau Lottie animation di dalam container lingkaran dengan double-border dan soft shadow.
class SetupIllustration extends StatefulWidget {
  final IconData? icon;
  final String? lottieAsset;
  final Color color;

  const SetupIllustration({
    super.key,
    this.icon,
    this.lottieAsset,
    this.color = AppColors.navy700,
  });

  @override
  State<SetupIllustration> createState() => _SetupIllustrationState();
}

class _SetupIllustrationState extends State<SetupIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine, // Kurva sinus lambat & natural untuk efek melayang
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Center(
        child: widget.lottieAsset != null
            ? SizedBox(
                width: 280,
                height: 280,
                child: Lottie.asset(
                  widget.lottieAsset!,
                  fit: BoxFit.contain,
                ),
              )
            : widget.icon != null
                ? Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.15),
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        size: 76,
                        color: widget.color,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
