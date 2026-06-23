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
class AuthListenerWrapper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Jika ada callback custom dan mengembalikan true, skip navigasi default
          if (onAuthenticated != null) {
            final handled = onAuthenticated!(state.user, state.needsOnboarding);
            if (handled) return;
          }

          // Navigasi default: ke setup wizard jika perlu onboarding, atau ke home
          if (state.needsOnboarding) {
            context.goNamed(Routes.setupWelcomeName);
          } else {
            context.goNamed(Routes.homeName);
          }
        } else if (state is AuthFailure) {
          // Tampilkan error SnackBar dengan visual premium
          context.showErrorSnackBar(state.errorMessage);

          // Callback tambahan jika ada
          onAuthFailure?.call(state.errorMessage);
        } else if (state is MagicLinkSent) {
          context.showSuccessSnackBar('Link masuk telah dikirim ke ${state.email}!');
        } else if (state is Unauthenticated) {
          // Jika user logout, arahkan ke login
          // Hanya redirect jika bukan di halaman publik
          final currentPath = GoRouterState.of(context).matchedLocation;
          final bool isProtectedRoute = currentPath.startsWith('/setup') ||
              currentPath.startsWith('/home');
          if (isProtectedRoute) {
            context.goNamed(Routes.loginName);
          }
        }
      },
      child: child,
    );
  }
}
