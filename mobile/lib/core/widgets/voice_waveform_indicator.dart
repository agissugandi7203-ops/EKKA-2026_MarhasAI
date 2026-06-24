import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VoiceWaveformIndicator extends StatefulWidget {
  const VoiceWaveformIndicator({super.key});

  @override
  State<VoiceWaveformIndicator> createState() => _VoiceWaveformIndicatorState();
}

class _VoiceWaveformIndicatorState extends State<VoiceWaveformIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _barCount = 8;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_barCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 250 + (index * 60)),
      )..repeat(reverse: true);
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 6.0, end: 28.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_barCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: _animations[index].value,
              decoration: BoxDecoration(
                color: AppColors.navy600,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
