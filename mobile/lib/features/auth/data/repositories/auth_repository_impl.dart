import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementasi konkret [AuthRepository].
///
/// Membungkus [AuthRemoteDataSource] dan meneruskan operasi.
/// Di masa depan, bisa ditambahkan caching atau error handling.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    return await _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  User? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _remoteDataSource.resetPasswordForEmail(email);
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _remoteDataSource.verifyOtp(email: email, token: token);
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _remoteDataSource.updatePassword(newPassword);
  }
}
