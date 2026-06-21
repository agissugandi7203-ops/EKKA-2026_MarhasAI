import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Abstraksi data source autentikasi Supabase.
///
/// Memisahkan pemanggilan SDK langsung dari logika bisnis (DIP).
/// Semua method mengembalikan tipe eksplisit — tidak ada `dynamic`.
abstract class AuthRemoteDataSource {
  Future<supabase.AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<supabase.AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<supabase.AuthResponse> signInWithGoogle();

  Future<void> signOut();

  supabase.User? getCurrentUser();

  /// Mengirim email reset password.
  Future<void> resetPasswordForEmail(String email);

  /// Memverifikasi kode OTP dari email.
  Future<supabase.AuthResponse> verifyOtp({
    required String email,
    required String token,
  });

  /// Memperbarui password user yang sedang aktif.
  Future<supabase.UserResponse> updatePassword(String newPassword);
}

/// Implementasi [AuthRemoteDataSource] menggunakan Supabase SDK.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<supabase.AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<supabase.AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<supabase.AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In dibatalkan oleh pengguna.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google.');
      }

      return await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Proses Google Sign-In Gagal: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  supabase.User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<supabase.AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _supabaseClient.auth.verifyOTP(
      type: supabase.OtpType.recovery,
      email: email,
      token: token,
    );
  }

  @override
  Future<supabase.UserResponse> updatePassword(String newPassword) async {
    return await _supabaseClient.auth.updateUser(
      supabase.UserAttributes(password: newPassword),
    );
  }
}
