/// Hierarki exception terpusat untuk seluruh aplikasi Genesis.id.
///
/// Semua error yang muncul dari network, auth, storage, atau logika bisnis
/// WAJIB dibungkus ke dalam salah satu subclass [AppException] agar:
/// 1. Pesan error konsisten dan ramah pengguna
/// 2. Error mudah di-classify (network vs auth vs server vs generic)
/// 3. Tidak ada teks error mentah yang bocor ke UI
///
/// Penggunaan:
/// ```dart
/// throw NetworkException.noInternet();
/// throw AuthException.sessionExpired();
/// throw ServerException(message: 'Data tidak ditemukan', statusCode: 404);
/// ```
sealed class AppException implements Exception {
  /// Pesan yang aman ditampilkan ke pengguna.
  final String message;

  /// Pesan teknis untuk logging/debug (tidak ditampilkan ke user).
  final String? technicalMessage;

  /// Kode error untuk identifikasi programatik.
  final String code;

  const AppException({
    required this.message,
    required this.code,
    this.technicalMessage,
  });

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

// ══════════════════════════════════════════════════════════════════════
// NETWORK EXCEPTIONS — Masalah koneksi / jaringan
// ══════════════════════════════════════════════════════════════════════

/// Error terkait koneksi jaringan (WiFi mati, timeout, DNS gagal).
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    required super.code,
    super.technicalMessage,
  });

  /// Tidak ada koneksi internet.
  factory NetworkException.noInternet() => const NetworkException(
        message: 'Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.',
        code: 'NETWORK_NO_INTERNET',
      );

  /// Request timeout (server terlalu lama merespons).
  factory NetworkException.timeout() => const NetworkException(
        message: 'Server terlalu lama merespons. Coba lagi nanti.',
        code: 'NETWORK_TIMEOUT',
      );

  /// Koneksi terputus di tengah transfer data.
  factory NetworkException.connectionClosed() => const NetworkException(
        message: 'Koneksi terputus. Pastikan jaringan Anda stabil.',
        code: 'NETWORK_CONNECTION_CLOSED',
      );

  /// DNS lookup gagal (domain tidak ditemukan).
  factory NetworkException.dnsFailure() => const NetworkException(
        message: 'Tidak dapat menghubungi server. Coba lagi nanti.',
        code: 'NETWORK_DNS_FAILURE',
      );

  /// Sertifikat SSL tidak valid.
  factory NetworkException.sslError() => const NetworkException(
        message: 'Koneksi tidak aman. Coba perbarui aplikasi Anda.',
        code: 'NETWORK_SSL_ERROR',
      );
}

// ══════════════════════════════════════════════════════════════════════
// SERVER EXCEPTIONS — Error dari backend NestJS
// ══════════════════════════════════════════════════════════════════════

/// Error respons dari server (4xx, 5xx).
class ServerException extends AppException {
  /// HTTP status code dari response.
  final int? statusCode;

  const ServerException({
    required super.message,
    required super.code,
    this.statusCode,
    super.technicalMessage,
  });

  /// 400 Bad Request — input user tidak valid.
  factory ServerException.badRequest({String? detail}) => ServerException(
        message: detail ?? 'Data yang dikirim tidak valid. Periksa kembali input Anda.',
        code: 'SERVER_BAD_REQUEST',
        statusCode: 400,
      );

  /// 403 Forbidden — user tidak punya akses.
  factory ServerException.forbidden() => const ServerException(
        message: 'Anda tidak memiliki izin untuk melakukan tindakan ini.',
        code: 'SERVER_FORBIDDEN',
        statusCode: 403,
      );

  /// 404 Not Found — resource tidak ditemukan.
  factory ServerException.notFound({String? resource}) => ServerException(
        message: '${resource ?? 'Data'} tidak ditemukan.',
        code: 'SERVER_NOT_FOUND',
        statusCode: 404,
      );

  /// 409 Conflict — data duplikat.
  factory ServerException.conflict({String? detail}) => ServerException(
        message: detail ?? 'Data sudah ada. Gunakan data yang berbeda.',
        code: 'SERVER_CONFLICT',
        statusCode: 409,
      );

  /// 413 Payload Too Large — file terlalu besar.
  factory ServerException.payloadTooLarge() => const ServerException(
        message: 'File terlalu besar. Maksimal ukuran yang diizinkan: 10MB.',
        code: 'SERVER_PAYLOAD_TOO_LARGE',
        statusCode: 413,
      );

  /// 429 Too Many Requests — rate limit.
  factory ServerException.tooManyRequests() => const ServerException(
        message: 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
        code: 'SERVER_RATE_LIMITED',
        statusCode: 429,
      );

  /// 500+ Internal Server Error.
  factory ServerException.internalError({String? detail}) => ServerException(
        message: 'Terjadi kesalahan di server. Tim kami sedang memperbaikinya.',
        code: 'SERVER_INTERNAL_ERROR',
        statusCode: 500,
        technicalMessage: detail,
      );

  /// 503 Service Unavailable — server sedang maintenance.
  factory ServerException.maintenance() => const ServerException(
        message: 'Server sedang dalam pemeliharaan. Coba lagi dalam beberapa menit.',
        code: 'SERVER_MAINTENANCE',
        statusCode: 503,
      );
}

// ══════════════════════════════════════════════════════════════════════
// AUTH EXCEPTIONS — Error autentikasi & otorisasi
// ══════════════════════════════════════════════════════════════════════

/// Error terkait autentikasi (login, signup, session).
class AuthException extends AppException {
  const AuthException({
    required super.message,
    required super.code,
    super.technicalMessage,
  });

  /// Kredensial login salah (email/password tidak cocok).
  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Email atau password salah. Silakan coba lagi.',
        code: 'AUTH_INVALID_CREDENTIALS',
      );

  /// Email sudah terdaftar.
  factory AuthException.emailAlreadyExists() => const AuthException(
        message: 'Email ini sudah terdaftar. Coba masuk atau gunakan email lain.',
        code: 'AUTH_EMAIL_EXISTS',
      );

  /// Session expired — user perlu login ulang.
  factory AuthException.sessionExpired() => const AuthException(
        message: 'Sesi Anda telah berakhir. Silakan masuk kembali.',
        code: 'AUTH_SESSION_EXPIRED',
      );

  /// Token refresh gagal.
  factory AuthException.tokenRefreshFailed({String? detail}) => AuthException(
        message: 'Gagal memperbarui sesi. Silakan masuk kembali.',
        code: 'AUTH_TOKEN_REFRESH_FAILED',
        technicalMessage: detail,
      );

  /// OAuth provider error (Google, Facebook, GitHub).
  factory AuthException.oauthFailed({String? provider, String? detail}) =>
      AuthException(
        message: 'Gagal masuk dengan ${provider ?? 'penyedia'}. Coba lagi nanti.',
        code: 'AUTH_OAUTH_FAILED',
        technicalMessage: detail,
      );

  /// OAuth login dibatalkan oleh pengguna.
  factory AuthException.cancelled() => const AuthException(
        message: 'Autentikasi dibatalkan oleh pengguna.',
        code: 'AUTH_CANCELLED',
      );

  /// OTP salah atau expired.
  factory AuthException.invalidOtp() => const AuthException(
        message: 'Kode verifikasi salah atau sudah kadaluarsa.',
        code: 'AUTH_INVALID_OTP',
      );

  /// User belum verifikasi email.
  factory AuthException.emailNotVerified() => const AuthException(
        message: 'Email belum diverifikasi. Periksa inbox Anda.',
        code: 'AUTH_EMAIL_NOT_VERIFIED',
      );
}

// ══════════════════════════════════════════════════════════════════════
// STORAGE / DEVICE EXCEPTIONS — Error perangkat lokal
// ══════════════════════════════════════════════════════════════════════

/// Error terkait storage, permission, atau hardware device.
class DeviceException extends AppException {
  const DeviceException({
    required super.message,
    required super.code,
    super.technicalMessage,
  });

  /// Izin lokasi ditolak oleh user.
  factory DeviceException.locationPermissionDenied() => const DeviceException(
        message: 'Izin lokasi ditolak. Aktifkan di pengaturan perangkat.',
        code: 'DEVICE_LOCATION_DENIED',
      );

  /// GPS/Location service tidak aktif.
  factory DeviceException.locationServiceDisabled() => const DeviceException(
        message: 'Layanan lokasi tidak aktif. Nyalakan GPS Anda.',
        code: 'DEVICE_LOCATION_DISABLED',
      );

  /// Izin kamera ditolak.
  factory DeviceException.cameraPermissionDenied() => const DeviceException(
        message: 'Izin kamera ditolak. Aktifkan di pengaturan perangkat.',
        code: 'DEVICE_CAMERA_DENIED',
      );

  /// Storage penuh.
  factory DeviceException.storageFull() => const DeviceException(
        message: 'Penyimpanan perangkat penuh. Hapus beberapa file terlebih dahulu.',
        code: 'DEVICE_STORAGE_FULL',
      );
}

// ══════════════════════════════════════════════════════════════════════
// GENERIC / UNEXPECTED EXCEPTIONS
// ══════════════════════════════════════════════════════════════════════

/// Error tidak terduga yang tidak masuk kategori lain.
class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'Terjadi kesalahan tak terduga. Coba lagi nanti.',
    super.code = 'UNEXPECTED_ERROR',
    super.technicalMessage,
  });
}
