# Dokumentasi Arsitektur Mobile App Genesis.id (Flutter)

Dokumen ini memuat detail arsitektur tingkat tinggi (*high-level architecture*), struktur folder, modul data/repositori, konfigurasi jaringan, serta manajemen state untuk aplikasi mobile **Genesis.id** (Flutter).

---

## 1. Desain Arsitektur & Struktur Folder

Aplikasi mobile Genesis.id menerapkan pola **Clean Architecture** yang dikombinasikan dengan pembagian direktori **Feature-First** (Berbasis Fitur). Struktur ini memisahkan UI, logika bisnis, dan pemrosesan data secara terisolasi agar kode mudah dikembangkan, diuji, dan aman dari bug.

```
mobile/lib/
├── core/
│   ├── config/           # Konfigurasi proyek (Supabase credentials)
│   └── network/          # Koneksi HTTP kustom (Dio Client)
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/ # Pemanggilan Supabase Auth SDK langsung
    │   │   └── repositories/# Implementasi repositori auth
    │   ├── domain/
    │   │   └── repositories/# Interface abstraksi repositori auth
    │   └── presentation/
    │       └── bloc/        # Logika state BLoC (AuthBloc)
    ├── profile/
    │   ├── data/
    │   │   ├── datasources/ # Pemanggilan API NestJS untuk data profil
    │   │   ├── models/      # Serialisasi JSON (ProfileModel & BadgeModel)
    │   │   └── repositories/# Implementasi repositori profil
    │   └── domain/
    │       └── repositories/# Interface abstraksi repositori profil
    └── leaderboard/
        ├── data/
        │   ├── datasources/ # Pemanggilan API NestJS untuk peringkat
        │   ├── models/      # Serialisasi JSON (UserLeaderboard & CityLeaderboard)
        │   └── repositories/# Implementasi repositori leaderboard
        └── domain/
            └── repositories/# Interface abstraksi repositori leaderboard
    └── reports/
        ├── data/
        │   ├── datasources/ # Pemanggilan API NestJS untuk unggahan/daftar laporan
        │   ├── models/      # Serialisasi JSON (ReportModel & UploadReportResponse)
        │   └── repositories/# Implementasi repositori laporan
        ├── domain/
        │   └── repositories/# Interface abstraksi repositori laporan
        └── presentation/
            └── bloc/        # Logika state BLoC (ReportsBloc)
```

---

## 2. Lapisan Jaringan Terintegrasi (Dio Client & Supabase JWT)

All pemanggilan API kustom ke NestJS dialirkan melalui **DioClient** ([dio_client.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/core/network/dio_client.dart)).

*   **Otomatisasi Kredensial (Bearer Interceptor)**:
    DioClient menyuntikkan interceptor kustom yang memantau status sesi Supabase secara real-time. Jika pengguna memiliki sesi aktif, token JWT Supabase (`accessToken`) akan disisipkan secara otomatis sebagai `Authorization: Bearer <token>` pada setiap header HTTP request ke NestJS.
*   **Base URL**: Secara bawaan mengarah ke `http://10.0.2.2:3000` (IP localhost khusus untuk Emulator Android).

---

## 3. Implementasi Pemrosesan Data & Repositori

Setiap fitur memiliki lapisan data source yang terisolasi dengan baik:

### A. Autentikasi (Auth)
*   **AuthRemoteDataSource** ([auth_remote_data_source.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/auth/data/datasources/auth_remote_data_source.dart)):
    Menggunakan library `@supabase/supabase-js` Dart SDK. Menangani pendaftaran, login email/password, dan penukaran Google OAuth ID Token ke Supabase secara langsung di sisi klien.
*   **AuthRepositoryImpl** ([auth_repository_impl.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/auth/data/repositories/auth_repository_impl.dart)):
    Membungkus data source untuk menyediakannya ke lapisan presentasi.

### B. Profil & Lencana (Profile)
*   **ProfileModel** ([profile_model.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/profile/data/models/profile_model.dart)):
    Deserialisasi objek profil lengkap dari JSON (termasuk XP, Level, Streak, dan Lencana).
*   **ProfileRemoteDataSource** ([profile_remote_data_source.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/profile/data/datasources/profile_remote_data_source.dart)):
    Memanggil NestJS endpoint `/profiles/me` dan `/profiles/onboard`.

### C. Papan Peringkat (Leaderboard)
*   **LeaderboardRemoteDataSource** ([leaderboard_remote_data_source.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart)):
    Memanggil NestJS endpoint `/leaderboard/global` and `/leaderboard/city` dengan opsi parameter `limit` terkonfigurasi.

### D. Pelaporan Spasial (Reports)
*   **ReportModel** ([report_model.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/reports/data/models/report_model.dart)) & **UploadReportResponse** ([upload_report_response.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/reports/data/models/upload_report_response.dart)):
    Deserialisasi data laporan (PostGIS POINT GeoJSON/WKT) dan status unggahan/duplikat dari NestJS.
*   **ReportRemoteDataSource** ([report_remote_data_source.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/reports/data/datasources/report_remote_data_source.dart)):
    Mengirimkan multipart request berisi file gambar, latitude, longitude, dan deskripsi ke NestJS.
*   **ReportRepositoryImpl** ([report_repository_impl.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/reports/data/repositories/report_repository_impl.dart)):
    Menjembatani akses data laporan ke presentation layer.

---

## 4. Manajemen State & Alur Onboarding (Auth BLoC)

State management autentikasi diatur secara ketat menggunakan **`flutter_bloc`**:
*   **Events** ([auth_event.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/auth/presentation/bloc/auth_event.dart)):
    `AuthCheckRequested`, `SignInRequested`, `SignUpRequested`, `GoogleSignInRequested`, `SignOutRequested`.
*   **States** ([auth_state.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/auth/presentation/bloc/auth_state.dart)):
    `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthFailure`.

### Logika Onboarding di AuthBloc ([auth_bloc.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/features/auth/presentation/bloc/auth_bloc.dart)):
Saat status berubah menjadi `Authenticated`, BLoC akan memanggil `ProfileRepository.getMyProfile()` untuk mendeteksi apakah data `cityOrDistrict` masih kosong.
*   Jika **kosong (NULL)**: `Authenticated` dipancarkan dengan flag `needsOnboarding: true`. UI Flutter akan secara otomatis mengarahkan user ke halaman konfigurasi lokasi GPS.
*   Jika **berisi**: `Authenticated` dipancarkan dengan flag `needsOnboarding: false`. UI Flutter akan langsung mengarahkan user ke beranda utama.

---

## 5. Standar Clean Code Dart di Genesis.id
1.  **Strict Type Safety**: Menghindari tipe data `dynamic` pada parsing JSON atau properti data. Menggunakan class model terdefinisi (`ProfileModel`, `BadgeModel`).
2.  **Immutability**: Semua model data dideklarasikan menggunakan properti `final` untuk mencegah perubahan data yang tidak sengaja.
3.  **Dependency Injection**: Repositori disuntikkan (*injected*) ke konstruktor BLoC secara eksplisit untuk mempermudah pembuatan mock unit test.
