import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Scaffold wrapper Genesis.id.
///
/// Menyediakan [SafeArea] otomatis dan opsi gradient background.
/// Digunakan di halaman-halaman utama yang membutuhkan padding & safe area
/// konsisten.
///
/// Penggunaan:
/// ```dart
/// GenesisScaffold(
///   body: Column(children: [...]),
/// );
/// ```
class GenesisScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool useGradientBackground;
  final bool useSafeArea;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const GenesisScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useGradientBackground = false,
    this.useSafeArea = true,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Apply padding jika di-set
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Apply SafeArea jika diperlukan
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    // Gradient background
    if (useGradientBackground) {
      return Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surface,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }

  /// Shortcut untuk membuat [GenesisScaffold] dengan padding halaman standar.
  factory GenesisScaffold.padded({
    Key? key,
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    bool useGradientBackground = false,
  }) {
    return GenesisScaffold(
      key: key,
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      useGradientBackground: useGradientBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePaddingH,
        vertical: AppConstants.pagePaddingV,
      ),
    );
  }
}
