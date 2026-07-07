import '../constants/app_constants.dart';

/// Validator form reusable Genesis.id.
///
/// Setiap validator mengembalikan [String?]:
/// - `null` jika valid
/// - Pesan error jika tidak valid
///
/// Validasi ini diselaraskan dengan DTO validation di backend NestJS
/// (class-validator rules) untuk konsistensi client-server.
///
/// Penggunaan:
/// ```dart
/// TextFormField(validator: Validators.email);
/// ```
abstract final class Validators {
  /// Validasi field wajib diisi.
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validasi format email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    // RFC 5322 simplified regex — cukup untuk validasi client-side.
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi password.
  /// Minimal 8 karakter, 1 huruf besar, 1 angka.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < AppConstants.passwordMinLength) {
      return 'Password minimal ${AppConstants.passwordMinLength} karakter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf besar';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }
    return null;
  }

  /// Validasi konfirmasi password cocok.
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != originalPassword) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validasi username.
  /// Hanya huruf, angka, dan underscore — selaras dengan backend regex.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.length < AppConstants.usernameMinLength) {
      return 'Username minimal ${AppConstants.usernameMinLength} karakter';
    }
    if (value.length > AppConstants.usernameMaxLength) {
      return 'Username maksimal ${AppConstants.usernameMaxLength} karakter';
    }

    // Selaras dengan backend regex: /^[a-zA-Z0-9_]+$/
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username hanya boleh huruf, angka, dan underscore';
    }
    return null;
  }

  /// Otomatis membersihkan nama dari Google/Input menjadi format username yang valid.
  /// Menghilangkan spasi, koma, titik, simbol, dan mengubah menjadi lowercase.
  static String sanitizeUsername(String name) {
    // 1. Ubah ke huruf kecil
    String clean = name.toLowerCase();
    
    // 2. Hilangkan spasi, koma, titik, simbol, karakter khusus
    // Hanya sisakan a-z, 0-9, dan underscore (_)
    clean = clean.replaceAll(RegExp(r'[^a-z0-9_]'), '');
    
    // 3. Fallback jika kosong setelah pembersihan
    if (clean.isEmpty) {
      clean = 'warrior';
    }

    // 4. Batasi panjang maksimal 20 karakter agar lolos validasi usernameMaxLength
    if (clean.length > 20) {
      clean = clean.substring(0, 20);
    }
    
    return clean;
  }

  /// Validasi nama lengkap.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama lengkap minimal 2 karakter';
    }
    if (value.length > AppConstants.fullNameMaxLength) {
      return 'Nama lengkap maksimal ${AppConstants.fullNameMaxLength} karakter';
    }
    return null;
  }
}
