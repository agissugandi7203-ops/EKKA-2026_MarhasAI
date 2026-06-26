import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';

/// Halaman transisi Welcome dengan animasi Lottie 8 detik sebelum masuk ke Dashboard.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Navigasi otomatis ke dashboard setelah 8 detik
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        context.goNamed(Routes.homeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF6F0), // Soft mint green
              Color(0xFFFAFAF8), // Warm white
            ],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 320,
            height: 320,
            child: Lottie.asset(
              'assets/animations/onboarding/Welcome.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
