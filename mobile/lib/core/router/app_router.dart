import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
  final GoRouter _router;

  AppRouter({required AuthBloc authBloc})
      : _router = GoRouter(
          initialLocation: Routes.splash,
          debugLogDiagnostics: true,
          routes: _buildRoutes(),
          redirect: (context, state) => _handleRedirect(context, state),
        );

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
          final email = state.extra as String? ?? '';
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: Routes.resetPasswordName,
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // ── Post-Login Setup ──
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

  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Biarkan splash, introduction, dan halaman auth berjalan tanpa guard.
    // Redirect logic utama ditangani oleh BlocListener di masing-masing page.
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
