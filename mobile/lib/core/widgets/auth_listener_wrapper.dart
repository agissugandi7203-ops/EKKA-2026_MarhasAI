import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import 'genesis_error_widget.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

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

    final currentPath = GoRouterState.of(context).matchedLocation;
    if (state.needsOnboarding) {
      if (currentPath != Routes.setupWelcome) {
        context.goNamed(Routes.setupWelcomeName);
      }
    } else {
      if (currentPath != Routes.home) {
        context.goNamed(Routes.homeName);
      }
    }
  }

  void _handleUnauthenticated(Unauthenticated state) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final bool isProtectedRoute = currentPath.startsWith('/setup') ||
        currentPath.startsWith('/home');
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
        } else if (state is AuthFailure) {
          // Tampilkan error SnackBar dengan visual premium
          context.showErrorSnackBar(state.errorMessage);

          // Callback tambahan jika ada
          widget.onAuthFailure?.call(state.errorMessage);
        } else if (state is MagicLinkSent) {
          context.showSuccessSnackBar('Link masuk telah dikirim ke ${state.email}!');
        } else if (state is Unauthenticated) {
          _handleUnauthenticated(state);
        }
      },
      child: widget.child,
    );
  }
}
