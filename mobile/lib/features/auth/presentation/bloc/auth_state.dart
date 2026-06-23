import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// States untuk [AuthBloc].
///
/// Setiap state merepresentasikan kondisi autentikasi saat ini.
/// Immutable dan Equatable untuk rebuild comparison yang efisien.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum pengecekan autentikasi.
class AuthInitial extends AuthState {}

/// Sedang memproses operasi autentikasi.
class AuthLoading extends AuthState {}

/// User terautentikasi.
class Authenticated extends AuthState {
  final User user;
  final bool needsOnboarding;

  const Authenticated({required this.user, required this.needsOnboarding});

  @override
  List<Object?> get props => [user, needsOnboarding];
}

/// User belum/tidak terautentikasi.
class Unauthenticated extends AuthState {}

/// Operasi autentikasi gagal.
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// Email reset password berhasil dikirim.
class PasswordResetEmailSent extends AuthState {
  final String email;

  const PasswordResetEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP berhasil diverifikasi — user boleh set password baru.
class OtpVerified extends AuthState {}

/// Password baru berhasil disimpan.
class PasswordResetSuccess extends AuthState {}

/// Magic Link (OTP Email) berhasil dikirim.
class MagicLinkSent extends AuthState {
  final String email;

  const MagicLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}

