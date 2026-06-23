import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstraksi repositori autentikasi.
///
/// Interface ini memisahkan domain layer dari data layer (DIP).
/// BLoC bergantung pada abstraksi ini, bukan implementasi konkret.
abstract class AuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponse> signInWithGoogle();

  Future<AuthResponse> signInWithFacebook();

  Future<AuthResponse> signInWithGithub();

  Future<void> signInWithMagicLink(String email);

  Future<void> signOut();

  User? getCurrentUser();

  /// Mengirim email reset password.
  Future<void> resetPasswordForEmail(String email);

  /// Memverifikasi kode OTP dari email.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  });

  /// Memperbarui password user yang sedang aktif.
  Future<UserResponse> updatePassword(String newPassword);

  /// Mendengarkan perubahan status autentikasi secara real-time.
  Stream<User?> get onAuthStateChanged;
}
