import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../errors/app_exception.dart';

/// Widget error fullscreen yang menggantikan Red Screen of Death.
///
/// Menampilkan pesan error dengan desain profesional, ikon kontekstual,
/// dan tombol retry. Digunakan oleh [ErrorWidgetBuilder] di [main.dart]
/// dan oleh halaman-halaman yang membutuhkan error state fullscreen.
///
/// Penggunaan:
/// ```dart
/// GenesisErrorWidget(
///   error: appException,
///   onRetry: () => bloc.add(RetryEvent()),
/// )
/// ```
class GenesisErrorWidget extends StatelessWidget {
  /// Pesan error yang ditampilkan.
  final String message;

  /// Ikon yang ditampilkan di atas pesan.
  final IconData icon;

  /// Warna ikon dan aksen.
  final Color iconColor;

  /// Callback saat tombol "Coba Lagi" ditekan.
  final VoidCallback? onRetry;

  /// Teks tombol retry (default: 'Coba Lagi').
  final String retryText;

  /// Widget tambahan di bawah tombol retry (opsional).
  final Widget? footer;

  const GenesisErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.iconColor = AppColors.error,
    this.onRetry,
    this.retryText = 'Coba Lagi',
    this.footer,
  });

  /// Factory constructor dari [AppException] — otomatis pilih ikon dan warna.
  factory GenesisErrorWidget.fromException({
    Key? key,
    required AppException exception,
    VoidCallback? onRetry,
    Widget? footer,
  }) {
    final config = _getConfigForException(exception);
    return GenesisErrorWidget(
      key: key,
      message: exception.message,
      icon: config.icon,
      iconColor: config.color,
      onRetry: onRetry,
      footer: footer,
    );
  }

  /// Factory constructor untuk tampilan offline/no internet.
  factory GenesisErrorWidget.offline({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return GenesisErrorWidget(
      key: key,
      message: 'Tidak ada koneksi internet.\nPeriksa WiFi atau data seluler Anda.',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.warning,
      onRetry: onRetry,
      retryText: 'Coba Lagi',
    );
  }

  /// Factory constructor untuk tampilan server down.
  factory GenesisErrorWidget.serverDown({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return GenesisErrorWidget(
      key: key,
      message: 'Server sedang dalam pemeliharaan.\nCoba lagi dalam beberapa menit.',
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.textSecondary,
      onRetry: onRetry,
      retryText: 'Coba Lagi',
    );
  }

  /// Factory constructor untuk tampilan empty state (bukan error, tapi data kosong).
  factory GenesisErrorWidget.empty({
    Key? key,
    String message = 'Belum ada data.',
    IconData icon = Icons.inbox_rounded,
  }) {
    return GenesisErrorWidget(
      key: key,
      message: message,
      icon: icon,
      iconColor: AppColors.textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ikon Error dengan lingkaran background ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 44,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),

            // ── Pesan Error ──
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // ── Tombol Retry ──
            if (onRetry != null)
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(retryText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // ── Footer opsional ──
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }

  /// Menentukan ikon dan warna berdasarkan tipe exception.
  static _ErrorConfig _getConfigForException(AppException exception) {
    return switch (exception) {
      NetworkException() => const _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
        ),
      ServerException(statusCode: 503) => const _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          color: AppColors.textSecondary,
        ),
      ServerException() => const _ErrorConfig(
          icon: Icons.dns_rounded,
          color: AppColors.error,
        ),
      AuthException() => const _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          color: AppColors.burgundy500,
        ),
      DeviceException() => const _ErrorConfig(
          icon: Icons.phonelink_erase_rounded,
          color: AppColors.warning,
        ),
      UnexpectedException() => const _ErrorConfig(
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        ),
    };
  }
}

/// Konfigurasi visual untuk ikon error.
class _ErrorConfig {
  final IconData icon;
  final Color color;

  const _ErrorConfig({required this.icon, required this.color});
}

// ══════════════════════════════════════════════════════════════════════
// SNACKBAR ERROR HELPER
// ══════════════════════════════════════════════════════════════════════

/// Extension pada [BuildContext] untuk menampilkan error SnackBar dengan
/// desain konsisten di seluruh aplikasi.
///
/// Penggunaan:
/// ```dart
/// context.showErrorSnackBar('Gagal memuat data');
/// context.showErrorSnackBar(appException.message, type: SnackBarType.warning);
/// context.showSuccessSnackBar('Laporan berhasil dikirim!');
/// ```
extension GenesisSnackBar on BuildContext {
  /// Menampilkan error SnackBar (merah).
  void showErrorSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Menampilkan warning SnackBar (amber).
  void showWarningSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Menampilkan success SnackBar (hijau).
  void showSuccessSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.emerald,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Menampilkan info SnackBar (biru navy).
  void showInfoSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.navy600,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    _activeGenesisToast?.remove();
    _activeGenesisToast = null;

    final overlay = Overlay.of(this);

    final entry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        duration: duration,
        onDismiss: () {
          _activeGenesisToast = null;
        },
      ),
    );

    _activeGenesisToast = entry;
    overlay.insert(entry);
  }
}

OverlayEntry? _activeGenesisToast;

class _TopToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
