import 'package:flutter/material.dart';

/// Extension pada [BuildContext] untuk akses cepat ke tema & ukuran layar.
///
/// Mengurangi boilerplate `Theme.of(context).colorScheme` menjadi
/// `context.colorScheme` — lebih bersih dan readable.
extension BuildContextExtensions on BuildContext {
  /// Akses cepat ke [ColorScheme] aktif.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Akses cepat ke [TextTheme] aktif.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Lebar layar.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Tinggi layar.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Padding atas (status bar / notch).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Padding bawah (home indicator / navigation bar).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Apakah layar tergolong kecil (< 360dp).
  bool get isSmallScreen => screenWidth < 360;

  /// Tampilkan [SnackBar] dengan pesan singkat.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : null,
      ),
    );
  }
}

/// Extension pada [String] untuk utilitas umum.
extension StringExtensions on String {
  /// Capitalize huruf pertama.
  /// 'hello world' → 'Hello world'
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize setiap kata.
  /// 'hello world' → 'Hello World'
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}
