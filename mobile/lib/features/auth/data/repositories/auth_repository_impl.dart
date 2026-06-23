import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementasi konkret [AuthRepository].
///
/// Membungkus [AuthRemoteDataSource] dan meneruskan operasi dengan error handling terpusat.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      return await _remoteDataSource.signInWithGoogle();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  User? getCurrentUser() {
    // Operasi sinkronus murni tidak memerlukan error handler pemetaan
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _remoteDataSource.resetPasswordForEmail(email);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      return await _remoteDataSource.verifyOtp(email: email, token: token);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _remoteDataSource.updatePassword(newPassword);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
