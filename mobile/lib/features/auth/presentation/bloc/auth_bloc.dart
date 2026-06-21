import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

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
  }

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
      emit(AuthFailure(e.toString()));
    }
  }

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
      emit(AuthFailure(e.toString()));
    }
  }

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
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<AuthState> _checkOnboardingStatus(dynamic user) async {
    try {
      final profile = await _profileRepository.getMyProfile();
      final bool needsOnboarding = profile.cityOrDistrict == null || profile.cityOrDistrict!.isEmpty;
      return Authenticated(user: user, needsOnboarding: needsOnboarding);
    } catch (e) {
      // Jika profile belum sinkron/terbuat di public.profiles, asumsikan butuh onboarding
      return Authenticated(user: user, needsOnboarding: true);
    }
  }
}
