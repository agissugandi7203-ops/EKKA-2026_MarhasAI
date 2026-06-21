import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC autentikasi Genesis.id.
///
/// Mengelola seluruh state autentikasi:
/// - Sign In / Sign Up / Google Sign-In
/// - Forgot Password → OTP → Reset Password
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
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
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
      emit(AuthFailure(_parseError(e)));
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
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Cek apakah user perlu menyelesaikan onboarding (profil lokasi).
  Future<AuthState> _checkOnboardingStatus(dynamic user) async {
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
    final message = error.toString();
    // Hapus prefix "Exception: " yang tidak informatif
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}
