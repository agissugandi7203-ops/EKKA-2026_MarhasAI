import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  final Dio _dio;
  
  // Base URL NestJS backend.
  // URL Produksi: https://genesisHub.my.id
  // URL Lokal (Emulator Android): http://10.0.2.2:3000
  static const String _defaultBaseUrl = 'https://genesisHub.my.id';

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
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil session Supabase aktif
          final supabase = Supabase.instance.client;
          var session = supabase.auth.currentSession;
          
          // Jika token telah kadaluarsa, lakukan refresh token secara sinkron untuk antrean request
          if (session != null && session.isExpired) {
            try {
              final refreshResponse = await supabase.auth.refreshSession();
              session = refreshResponse.session;
            } catch (e) {
              // Jika gagal refresh, biarkan request lewat dan ditangani oleh auth guard backend
            }
          }

          if (session != null) {
            final token = session.accessToken;
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Jika terjadi error 401 (Unauthorized), coba refresh token sekali lagi dan jalankan ulang request asli
          if (error.response?.statusCode == 401) {
            try {
              final supabase = Supabase.instance.client;
              final refreshResponse = await supabase.auth.refreshSession();
              final token = refreshResponse.session?.accessToken;
              
              if (token != null) {
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $token';
                
                // Kirim ulang request asli
                final clonedResponse = await _dio.fetch(options);
                return handler.resolve(clonedResponse);
              }
            } catch (_) {
              // Jika gagal refresh, teruskan error asli
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
