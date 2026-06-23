import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User, AuthChangeEvent;

/// Events untuk [AuthBloc].
///
/// Setiap event merepresentasikan satu aksi user yang mempengaruhi
/// state autentikasi. Immutable dan Equatable untuk testability.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status autentikasi saat aplikasi dimulai.
class AuthCheckRequested extends AuthEvent {}

/// User meminta sign-in dengan email & password.
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// User meminta registrasi akun baru.
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// User meminta sign-in dengan Google OAuth.
class GoogleSignInRequested extends AuthEvent {}

/// User meminta sign-out.
class SignOutRequested extends AuthEvent {}

/// User meminta reset password via email.
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// User memverifikasi kode OTP dari email.
class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String token;

  const VerifyOtpRequested({required this.email, required this.token});

  @override
  List<Object?> get props => [email, token];
}

/// User menyimpan password baru setelah reset.
class ResetPasswordRequested extends AuthEvent {
  final String newPassword;

  const ResetPasswordRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

/// User meminta sign-in dengan Facebook OAuth.
class FacebookSignInRequested extends AuthEvent {}

/// User meminta sign-in dengan GitHub OAuth.
class GithubSignInRequested extends AuthEvent {}

/// User meminta sign-in dengan Magic Link (Email OTP link).
class MagicLinkSignInRequested extends AuthEvent {
  final String email;

  const MagicLinkSignInRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event internal saat session auth Supabase berubah (misal redirect deep link sukses).
class AuthSessionChanged extends AuthEvent {
  final User? user;
  final AuthChangeEvent? event;

  const AuthSessionChanged(this.user, [this.event]);

  @override
  List<Object?> get props => [user, event];
}

