import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC autentikasi Genesis.id.
///
/// Mengelola seluruh state autentikasi:
/// - Sign In / Sign Up / Google Sign-In / Facebook & GitHub Sign-In
/// - Forgot Password → OTP → Reset Password / Magic Link
/// - Sign Out
/// - Pengecekan status onboarding via [ProfileRepository]
///
/// Setiap handler mengikuti pola:
/// 1. Emit [AuthLoading]
/// 2. Jalankan operasi
/// 3. Emit state sukses atau [AuthFailure]
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<FacebookSignInRequested>(_onFacebookSignInRequested);
    on<GithubSignInRequested>(_onGithubSignInRequested);
    on<MagicLinkSignInRequested>(_onMagicLinkSignInRequested);
    on<AuthSessionChanged>(_onAuthSessionChanged);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);

    // Langsung mendengarkan perubahan status autentikasi di tingkat data layer/SDK.
    // Membantu menangani redirect OAuth (Google, Facebook, GitHub) dan Magic Link.
    _authStateSubscription = _authRepository.onAuthStateChanged.listen((user) {
      add(AuthSessionChanged(user));
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // AUTH CHECK
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(await _checkOnboardingStatus(currentUser));
    } else {
      emit(Unauthenticated());
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(await _checkOnboardingStatus(response.user!));
      } else {
        emit(const AuthFailure('Gagal melakukan sign in.'));
      }
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(await _checkOnboardingStatus(response.user!));
      } else {
        emit(const AuthFailure('Gagal melakukan registrasi.'));
      }
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithGoogle();
      if (response.user != null) {
        emit(await _checkOnboardingStatus(response.user!));
      } else {
        emit(const AuthFailure('Gagal sign in dengan Google.'));
      }
    } catch (e) {
      if (e is AppException && e.code == 'AUTH_CANCELLED') {
        emit(Unauthenticated());
      } else {
        emit(AuthFailure(_parseError(e)));
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPasswordForEmail(event.email);
      emit(PasswordResetEmailSent(event.email));
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // VERIFY OTP
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOtp(
        email: event.email,
        token: event.token,
      );
      emit(OtpVerified());
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // RESET PASSWORD
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.updatePassword(event.newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // FACEBOOK SIGN-IN
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onFacebookSignInRequested(
    FacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithFacebook();
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // GITHUB SIGN-IN
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onGithubSignInRequested(
    GithubSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGithub();
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // MAGIC LINK SIGN-IN
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onMagicLinkSignInRequested(
    MagicLinkSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithMagicLink(event.email);
      emit(MagicLinkSent(event.email));
    } catch (e) {
      emit(AuthFailure(_parseError(e)));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // AUTH SESSION CHANGED (STREAM LISTENER EFFECT)
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _onAuthSessionChanged(
    AuthSessionChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user != null) {
      final currentState = state;
      if (currentState is! Authenticated || currentState.user.id != user.id) {
        emit(AuthLoading());
        emit(await _checkOnboardingStatus(user));
      }
    } else {
      if (state is! Unauthenticated) {
        emit(Unauthenticated());
      }
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Cek apakah user perlu menyelesaikan onboarding (profil lokasi).
  Future<AuthState> _checkOnboardingStatus(User user) async {
    try {
      final profile = await _profileRepository.getMyProfile();
      final bool needsOnboarding =
          profile.cityOrDistrict == null || profile.cityOrDistrict!.isEmpty;
      return Authenticated(user: user, needsOnboarding: needsOnboarding);
    } catch (e) {
      // Jika profil belum dibuat di public.profiles, butuh onboarding.
      return Authenticated(user: user, needsOnboarding: true);
    }
  }

  /// Mengekstrak pesan error yang user-friendly dari exception.
  String _parseError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return ErrorHandler.handle(error).message;
  }
}
