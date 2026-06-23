import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/setup/presentation/bloc/setup_cubit.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/simple_sign_in_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/introduction/presentation/pages/introduction_page.dart';
import '../../features/introduction/presentation/pages/pre_onboarding_page.dart';
import '../../features/setup/presentation/pages/setup_location_page.dart';
import '../../features/setup/presentation/pages/setup_notification_page.dart';
import '../../features/setup/presentation/pages/setup_profile_page.dart';
import '../../features/setup/presentation/pages/setup_welcome_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/auth_listener_wrapper.dart';
import '../widgets/genesis_loading.dart';

/// Router terpusat Genesis.id menggunakan GoRouter.
///
/// Seluruh navigasi dan redirect logic dikelola di sini.
/// Widget tidak boleh melakukan navigasi sendiri — semua melalui [GoRouter].
///
/// Alur navigasi:
/// ```
/// Splash → Introduction → Login ⇄ SignUp → Setup (4 step) → Home
///                           ↓
///                     ForgotPassword → OTP → ResetPassword
/// ```
class AppRouter {
  final AuthBloc _authBloc;
  late final GoRouter _router;

  AppRouter({required AuthBloc authBloc}) : _authBloc = authBloc {
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _buildRoutes(),
      redirect: _handleRedirect,
      errorBuilder: (context, state) {
        final location = state.uri.toString();
        debugPrint('GoRouter Error Location: $location');
        if (location.startsWith('genesis://')) {
          return const Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: AuthListenerWrapper(
                child: Scaffold(
                  body: Center(
                    child: GenesisLoading(message: 'Menghubungkan akun...'),
                  ),
                ),
              ),
            ),
          );
        }
        return Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Center(child: Text('Error: ${state.error}')),
            ),
          ),
        );
      },
    );
  }

  GoRouter get router => _router;

  // ══════════════════════════════════════════════════════════════════════
  // ROUTE DEFINITIONS
  // ══════════════════════════════════════════════════════════════════════

  static List<RouteBase> _buildRoutes() {
    return [
      // ── Pre-Auth ──
      GoRoute(
        path: Routes.splash,
        name: Routes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.preOnboarding,
        name: Routes.preOnboardingName,
        builder: (context, state) => const PreOnboardingPage(),
      ),
      GoRoute(
        path: Routes.introduction,
        name: Routes.introductionName,
        builder: (context, state) => const IntroductionPage(),
      ),

      // ── Auth Flow ──
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.simpleSignIn,
        name: Routes.simpleSignInName,
        builder: (context, state) => const SimpleSignInPage(),
      ),
      GoRoute(
        path: Routes.signUp,
        name: Routes.signUpName,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: Routes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.otpVerification,
        name: Routes.otpVerificationName,
        builder: (context, state) {
          // Safe cast — hindari TypeError jika extra bukan String
          final email = (state.extra is String) ? state.extra as String : '';
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: Routes.resetPasswordName,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: Routes.loginCallback,
        name: Routes.loginCallbackName,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: GenesisLoading(message: 'Menghubungkan akun...'),
          ),
        ),
      ),

      // ── Post-Login Setup ──
      // ShellRoute menyediakan SetupCubit lokal hanya selama 4 halaman setup.
      // Cubit ini otomatis di-dispose saat user keluar dari setup flow.
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider<SetupCubit>(
            create: (_) => SetupCubit(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: Routes.setupWelcome,
            name: Routes.setupWelcomeName,
            builder: (context, state) => const SetupWelcomePage(),
          ),
          GoRoute(
            path: Routes.setupLocation,
            name: Routes.setupLocationName,
            builder: (context, state) => const SetupLocationPage(),
          ),
          GoRoute(
            path: Routes.setupNotification,
            name: Routes.setupNotificationName,
            builder: (context, state) => const SetupNotificationPage(),
          ),
          GoRoute(
            path: Routes.setupProfile,
            name: Routes.setupProfileName,
            builder: (context, state) => const SetupProfilePage(),
          ),
        ],
      ),

      // ── Main App ──
      GoRoute(
        path: Routes.home,
        name: Routes.homeName,
        builder: (context, state) => const HomePage(),
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════
  // REDIRECT GUARD
  // ══════════════════════════════════════════════════════════════════════

  /// Route yang boleh diakses tanpa autentikasi.
  static const Set<String> _publicRoutes = {
    Routes.splash,
    Routes.preOnboarding,
    Routes.introduction,
    Routes.login,
    Routes.simpleSignIn,
    Routes.signUp,
    Routes.forgotPassword,
    Routes.otpVerification,
    Routes.resetPassword,
    Routes.loginCallback,
  };

  /// Route yang hanya boleh diakses setelah autentikasi.
  static const Set<String> _protectedRoutes = {
    Routes.setupWelcome,
    Routes.setupLocation,
    Routes.setupNotification,
    Routes.setupProfile,
    Routes.home,
  };

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final currentPath = state.matchedLocation;
    final authState = _authBloc.state;

    // Biarkan splash screen berjalan tanpa guard — ia punya logika navigasi sendiri.
    if (currentPath == Routes.splash) return null;

    final bool isAuthenticated = authState is Authenticated || authState is PasswordResetSuccess;
    final bool isOnPublicRoute = _publicRoutes.contains(currentPath);
    final bool isOnProtectedRoute = _protectedRoutes.contains(currentPath);

    // Jika user belum login dan mencoba akses route terproteksi → redirect ke login.
    if (!isAuthenticated && isOnProtectedRoute) {
      return Routes.login;
    }

    // Jika user sudah login dan masih di halaman login/signup → redirect berdasarkan onboarding.
    if (isAuthenticated && isOnPublicRoute) {
      // Kecuali halaman yang memang perlu diakses saat flow reset password
      final bool isResetFlow = currentPath == Routes.forgotPassword ||
          currentPath == Routes.otpVerification ||
          currentPath == Routes.resetPassword;

      if (!isResetFlow) {
        final bool needsOnboarding = authState is Authenticated
            ? authState.needsOnboarding
            : (authState as PasswordResetSuccess).needsOnboarding;
        return needsOnboarding ? Routes.setupWelcome : Routes.home;
      }
    }

    return null;
  }
}

/// Konstanta path route — satu-satunya sumber referensi untuk navigasi.
///
/// Penggunaan:
/// ```dart
/// context.goNamed(Routes.loginName);
/// context.pushNamed(Routes.signUpName);
/// ```
abstract final class Routes {
  // ── Pre-Auth ──
  static const String splash = '/splash';
  static const String splashName = 'splash';

  static const String preOnboarding = '/pre-onboarding';
  static const String preOnboardingName = 'preOnboarding';

  static const String introduction = '/introduction';
  static const String introductionName = 'introduction';

  // ── Auth ──
  static const String login = '/login';
  static const String loginName = 'login';

  static const String simpleSignIn = '/simple-sign-in';
  static const String simpleSignInName = 'simpleSignIn';

  static const String signUp = '/sign-up';
  static const String signUpName = 'signUp';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordName = 'forgotPassword';

  static const String otpVerification = '/otp-verification';
  static const String otpVerificationName = 'otpVerification';

  static const String resetPassword = '/reset-password';
  static const String resetPasswordName = 'resetPassword';

  static const String loginCallback = '/login-callback';
  static const String loginCallbackName = 'loginCallback';

  // ── Post-Login Setup ──
  static const String setupWelcome = '/setup/welcome';
  static const String setupWelcomeName = 'setupWelcome';

  static const String setupLocation = '/setup/location';
  static const String setupLocationName = 'setupLocation';

  static const String setupNotification = '/setup/notification';
  static const String setupNotificationName = 'setupNotification';

  static const String setupProfile = '/setup/profile';
  static const String setupProfileName = 'setupProfile';

  // ── Main App ──
  static const String home = '/home';
  static const String homeName = 'home';
}
