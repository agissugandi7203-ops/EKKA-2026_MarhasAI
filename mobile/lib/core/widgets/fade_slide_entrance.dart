import 'package:flutter/material.dart';

/// Widget animasi transisi masuk (entrance) dengan kombinasi fade-in dan slide-up.
///
/// Digunakan untuk memberikan efek transisi yang sangat smooth, elegan, dan premium
/// pada elemen-elemen UI (seperti teks, ilustrasi, tombol) secara berurutan (staggered).
///
/// Penggunaan:
/// ```dart
/// FadeSlideEntrance(
///   delay: Duration(milliseconds: 100),
///   child: Text('Halo'),
/// )
/// ```
class FadeSlideEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const FadeSlideEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.offset = const Offset(0, 20), // offset 20px dirasa paling soft & natural
  });

  @override
  State<FadeSlideEntrance> createState() => _FadeSlideEntranceState();
}

class _FadeSlideEntranceState extends State<FadeSlideEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint, // Kurva eksponensial lambat di akhir (elegan)
      ),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint,
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
