import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import 'genesis_error_widget.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

/// Widget pembungkus yang mendengarkan perubahan [AuthState] secara terpusat.
///
/// Menghilangkan duplikasi pola `BlocListener<AuthBloc, AuthState>` yang
/// diulang identik di 5+ halaman (login, simple_sign_in, pre_onboarding,
/// introduction, home). Semua logika navigasi auth dipusatkan di sini.
///
/// Penggunaan:
/// ```dart
/// AuthListenerWrapper(
///   child: Scaffold(...),
/// )
/// ```
///
/// Atau jika halaman butuh custom reaction tambahan:
/// ```dart
/// AuthListenerWrapper(
///   onAuthenticated: (user, needsOnboarding) {
///     // Custom logic sebelum navigasi default
///   },
///   child: Scaffold(...),
/// )
/// ```

class AuthListenerWrapper extends StatefulWidget {
  /// Widget child yang dibungkus.
  final Widget child;

  /// Callback opsional saat user berhasil autentikasi.
  /// Jika mengembalikan `true`, navigasi default akan di-skip.
  final bool Function(dynamic user, bool needsOnboarding)? onAuthenticated;

  /// Callback opsional saat auth gagal (selain menampilkan SnackBar default).
  final void Function(String errorMessage)? onAuthFailure;

  const AuthListenerWrapper({
    super.key,
    required this.child,
    this.onAuthenticated,
    this.onAuthFailure,
  });

  @override
  State<AuthListenerWrapper> createState() => _AuthListenerWrapperState();
}

class _AuthListenerWrapperState extends State<AuthListenerWrapper> {
  @override
  void initState() {
    super.initState();
    // Jalankan pengecekan setelah frame pertama selesai dirender.
    // Ini menangani kasus di mana status autentikasi sudah aktif (Authenticated)
    // sebelum widget ini masuk ke widget tree (misalnya saat deep link diproses).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkCurrentState();
      }
    });
  }

  void _checkCurrentState() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      _handleAuthenticated(state);
    } else if (state is Unauthenticated) {
      _handleUnauthenticated(state);
    }
  }

  void _handleAuthenticated(Authenticated state) {
    if (widget.onAuthenticated != null) {
      final handled = widget.onAuthenticated!(state.user, state.needsOnboarding);
      if (handled) return;
    }

    String? currentPath;
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      try {
        currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      } catch (_) {}
    }

    if (currentPath == null) return;

    final bool isResetFlow = currentPath == Routes.otpVerification ||
        currentPath == Routes.resetPassword ||
        currentPath == Routes.forgotPassword;

    if (isResetFlow) {
      // Lewati pengalihan otomatis jika berada di alur reset password
      return;
    }

    final bool isInSetupFlow = currentPath.startsWith('/setup');

    if (state.needsOnboarding) {
      if (!isInSetupFlow && currentPath != Routes.setupWelcome) {
        context.goNamed(Routes.setupWelcomeName);
      }
    } else {
      final bool isInMainApp = currentPath == Routes.home ||
          currentPath == Routes.statistics ||
          currentPath == Routes.tukarPoin ||
          currentPath == Routes.notifications;

      if (!isInMainApp && currentPath != Routes.welcome) {
        context.goNamed(Routes.welcomeName);
      }
    }
  }

  void _handleUnauthenticated(Unauthenticated state) {
    // Reset ChatBloc state (clear memory and storage history) when user logs out
    try {
      context.read<ChatBloc>().add(ClearChatRequested());
    } catch (e) {
      debugPrint('Failed to clear ChatBloc on logout: $e');
    }

    String? currentPath;
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      try {
        currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      } catch (_) {}
    }

    if (currentPath == null) return;

    final bool isProtectedRoute = currentPath.startsWith('/setup') ||
        currentPath.startsWith('/home') ||
        currentPath == Routes.welcome;
    if (isProtectedRoute) {
      if (currentPath != Routes.login) {
        context.goNamed(Routes.loginName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _handleAuthenticated(state);
        } else if (state is SignUpSuccess) {
          context.showSuccessSnackBar(
            'Registrasi berhasil! Silakan cek KOTAK MASUK atau FOLDER SPAM email Anda (${state.email}) untuk memverifikasi akun sebelum masuk.',
            duration: const Duration(seconds: 15),
          );
          context.goNamed(Routes.loginName);
        } else if (state is OtpVerified) {
          context.goNamed(Routes.resetPasswordName);
        } else if (state is AuthFailure) {
          // Tampilkan error SnackBar dengan visual premium
          context.showErrorSnackBar(state.errorMessage);

          // Callback tambahan jika ada
          widget.onAuthFailure?.call(state.errorMessage);
        } else if (state is MagicLinkSent) {
          context.showSuccessSnackBar(
            'Link masuk telah dikirim ke ${state.email}! Silakan periksa KOTAK MASUK atau FOLDER SPAM email Anda.',
            duration: const Duration(seconds: 15),
          );
        } else if (state is Unauthenticated) {
          _handleUnauthenticated(state);
        }
      },
      child: widget.child,
    );
  }
}
