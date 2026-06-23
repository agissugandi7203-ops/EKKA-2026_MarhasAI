import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_exception.dart';

/// Utilitas terpusat untuk mengkonversi exception mentah ke [AppException].
///
/// Digunakan di data layer (repository, data source) untuk memastikan semua
/// error yang sampai ke presentation layer sudah dalam format [AppException]
/// dengan pesan yang ramah pengguna.
///
/// Penggunaan di Repository:
/// ```dart
/// try {
///   return await _dataSource.getReports();
/// } catch (e, stack) {
///   throw ErrorHandler.handle(e, stack);
/// }
/// ```
///
/// Penggunaan di BLoC:
/// ```dart
/// } on AppException catch (e) {
///   emit(FailureState(e.message));  // Pesan sudah ramah user
/// } catch (e, stack) {
///   final appError = ErrorHandler.handle(e, stack);
///   emit(FailureState(appError.message));
/// }
/// ```
abstract final class ErrorHandler {
  /// Mengkonversi exception mentah ke [AppException] yang ramah pengguna.
  ///
  /// Mendukung konversi dari:
  /// - [DioException] → [NetworkException] atau [ServerException]
  /// - [SocketException] → [NetworkException.noInternet]
  /// - [AppException] → diteruskan apa adanya (sudah terformat)
  /// - [Exception] umum → [UnexpectedException]
  static AppException handle(Object error, [StackTrace? stack]) {
    // Log error untuk debugging (hanya di debug mode)
    _logError(error, stack);

    // Jika sudah AppException, kembalikan langsung
    if (error is AppException) return error;

    // Dio network/server errors
    if (error is DioException) return _handleDioException(error);

    // Socket errors (no internet)
    if (error is SocketException) return NetworkException.noInternet();

    // HandshakeException (SSL)
    if (error is HandshakeException) return NetworkException.sslError();

    // FormatException (JSON parsing gagal)
    if (error is FormatException) {
      return ServerException.internalError(
        detail: 'Response format tidak valid: ${error.message}',
      );
    }

    // TypeError (casting gagal — biasanya dari JSON deserialization)
    if (error is TypeError) {
      return UnexpectedException(
        technicalMessage: 'TypeError: $error',
      );
    }

    // Fallback: error tidak dikenal
    return UnexpectedException(
      technicalMessage: error.toString(),
    );
  }

  /// Mengkonversi [DioException] ke [AppException] berdasarkan tipe dan status code.
  static AppException _handleDioException(DioException error) {
    switch (error.type) {
      // ── Timeout errors ──
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      // ── Connection errors (no internet, DNS, etc.) ──
      case DioExceptionType.connectionError:
        final innerError = error.error;
        if (innerError is SocketException) {
          return NetworkException.noInternet();
        }
        return NetworkException(
          message: 'Gagal terhubung ke server. Periksa koneksi Anda.',
          code: 'NETWORK_CONNECTION_ERROR',
          technicalMessage: error.message,
        );

      // ── HTTP response errors (4xx, 5xx) ──
      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      // ── Request cancelled ──
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Permintaan dibatalkan.',
          code: 'NETWORK_CANCELLED',
        );

      // ── Certificate errors ──
      case DioExceptionType.badCertificate:
        return NetworkException.sslError();

      // ── Unknown Dio error ──
      case DioExceptionType.unknown:
        final innerError = error.error;
        if (innerError is SocketException) {
          return NetworkException.noInternet();
        }
        return NetworkException(
          message: 'Terjadi kesalahan jaringan. Coba lagi.',
          code: 'NETWORK_UNKNOWN',
          technicalMessage: error.message,
        );
    }
  }

  /// Mengkonversi HTTP error response ke [ServerException] atau [AuthException].
  static AppException _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Coba ambil pesan error dari body response NestJS
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String?;
      // NestJS kadang mengirim array messages (validation errors)
      if (serverMessage == null && responseData['message'] is List) {
        final messages = responseData['message'] as List;
        serverMessage = messages.join('. ');
      }
    }

    switch (statusCode) {
      case 400:
        return ServerException.badRequest(detail: serverMessage);

      case 401:
        // Cek apakah ini masalah credential atau session
        final isLoginAttempt = error.requestOptions.path.contains('/auth');
        if (isLoginAttempt) {
          return AuthException.invalidCredentials();
        }
        return AuthException.sessionExpired();

      case 403:
        return ServerException.forbidden();

      case 404:
        return ServerException.notFound();

      case 409:
        // Konflik — biasanya email sudah terdaftar
        if (serverMessage != null &&
            serverMessage.toLowerCase().contains('email')) {
          return AuthException.emailAlreadyExists();
        }
        return ServerException.conflict(detail: serverMessage);

      case 413:
        return ServerException.payloadTooLarge();

      case 422:
        return ServerException.badRequest(
          detail: serverMessage ?? 'Data tidak dapat diproses.',
        );

      case 429:
        return ServerException.tooManyRequests();

      case 500:
        return ServerException.internalError(detail: serverMessage);

      case 502:
      case 503:
        return ServerException.maintenance();

      case 504:
        return NetworkException.timeout();

      default:
        return ServerException(
          message: serverMessage ?? 'Terjadi kesalahan (Kode: $statusCode).',
          code: 'SERVER_HTTP_$statusCode',
          statusCode: statusCode,
        );
    }
  }

  /// Log error ke console (hanya di debug mode).
  static void _logError(Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════');
      debugPrint('║ [ErrorHandler] ${error.runtimeType}');
      debugPrint('║ $error');
      if (stack != null) {
        // Hanya ambil 5 baris pertama dari stack trace
        final lines = stack.toString().split('\n').take(5).join('\n');
        debugPrint('║ Stack:\n$lines');
      }
      debugPrint('╚══════════════════════════════════════════');
    }
  }
}
