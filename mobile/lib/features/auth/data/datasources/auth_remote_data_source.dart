import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/app_exception.dart';

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

  Future<supabase.AuthResponse> signInWithFacebook();

  Future<supabase.AuthResponse> signInWithGithub();

  Future<void> signInWithMagicLink(String email);

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

  /// Mendengarkan perubahan status autentikasi secara real-time.
  Stream<supabase.User?> get onAuthStateChanged;

  /// Mendengarkan status autentikasi dengan event tipe detail dari Supabase.
  Stream<supabase.AuthState> get onSupabaseAuthStateChanged;
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
      emailRedirectTo: 'genesis://login-callback',
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
        serverClientId: '12178843429-lktd01tj39831ok404qssp246n3vblpf.apps.googleusercontent.com',
        scopes: ['email'],
      );
      try {
        await googleSignIn.signOut();
      } catch (_) {
        // Abaikan error sign out jika google_sign_in belum ter-sign-in sebelumnya
      }
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException.cancelled();
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
      if (e is AppException) rethrow;
      throw Exception('Proses Google Sign-In Gagal: ${e.toString()}');
    }
  }

  @override
  Future<supabase.AuthResponse> signInWithFacebook() async {
    final success = await _supabaseClient.auth.signInWithOAuth(
      supabase.OAuthProvider.facebook,
      redirectTo: 'genesis://login-callback',
    );
    if (!success) {
      throw Exception('Gagal menginisialisasi Facebook Sign-In.');
    }
    // OAuth web redirect flow tidak mengembalikan AuthResponse instan.
    // Session akan diperoleh setelah deep link callback ditangani.
    return supabase.AuthResponse();
  }

  @override
  Future<supabase.AuthResponse> signInWithGithub() async {
    final success = await _supabaseClient.auth.signInWithOAuth(
      supabase.OAuthProvider.github,
      redirectTo: 'genesis://login-callback',
    );
    if (!success) {
      throw Exception('Gagal menginisialisasi GitHub Sign-In.');
    }
    return supabase.AuthResponse();
  }

  @override
  Future<void> signInWithMagicLink(String email) async {
    await _supabaseClient.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'genesis://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '12178843429-lktd01tj39831ok404qssp246n3vblpf.apps.googleusercontent.com',
        scopes: ['email'],
      );
      await googleSignIn.signOut();
    } catch (e) {
      // Abaikan jika google_sign_in belum ter-sign-in
    }
    await _supabaseClient.auth.signOut();
  }

  @override
  supabase.User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'genesis://login-callback',
    );
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

  @override
  Stream<supabase.User?> get onAuthStateChanged =>
      _supabaseClient.auth.onAuthStateChange.map((data) => data.session?.user);

  @override
  Stream<supabase.AuthState> get onSupabaseAuthStateChanged =>
      _supabaseClient.auth.onAuthStateChange;
}
