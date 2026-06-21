import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  final Dio _dio;
  
  // Base URL NestJS backend. 10.0.2.2 adalah IP localhost khusus untuk Emulator Android.
  // Jika menggunakan device fisik atau iOS Simulator, silakan sesuaikan IP.
  static const String _defaultBaseUrl = 'http://10.0.2.2:3000';

  DioClient({String? baseUrl}) : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Otomatis mengambil access token JWT dari Supabase Auth yang sedang aktif
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            final token = session.accessToken;
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Logika penanganan error global dapat ditambahkan di sini
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
