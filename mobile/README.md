# Genesis.id Mobile App (Flutter)

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.19%20%7C%20Dart%20v3.x-blue.svg)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%7C%20Feature--First-brightgreen.svg)](#)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC-blue.svg)](#)
[![Location Spasial](https://img.shields.io/badge/spasial-Geolocator%20%7C%20PostGIS-orange.svg)](#)

Aplikasi gawai **Genesis.id** dibangun sepenuhnya menggunakan **Flutter** (Dart) untuk sisi warga/komunitas. Aplikasi ini menangani interaksi perangkat keras native seperti kamera untuk memotret anomali lingkungan, koordinat GPS spasial presisi tinggi, interogasi gambar ("AI Per-Seksi"), chatbot edukasi berbasis RAG, serta gamifikasi kepedulian sosial.

---

## 1. Fitur Utama Mobile (Logic & Network)
1.  **Otomatisasi Dio Client**: Client HTTP Dio kustom yang memiliki interceptor otomatis untuk menyisipkan token JWT Supabase aktif di setiap header request ke backend NestJS.
2.  **Auth BLoC (State Management)**: Mengelola status masuk (Google OAuth & Email/Password) serta mendeteksi secara otomatis kebutuhan pengisian lokasi onboarding (Kabupaten/Kota) pada login pertama kali.
3.  **Onboarding Geolokasi**: Meminta izin GPS satu kali menggunakan package `geolocator` untuk mendeteksi secara otomatis kota domisili warga untuk dikunci di leaderboard (mencegah penyelewengan GPS).
4.  **Profile & Gamifikasi**: Menampilkan data profil, bar XP, level keaktifan, total kontribusi laporan, status *streak harian*, dan grid katalog lencana (*badges*).

---

## 2. Struktur Clean Architecture
```
mobile/lib/
├── core/
│   ├── config/           # Konfigurasi Supabase URL & Anon Key
│   └── network/          # Kustom DioClient dengan JWT interceptor
└── features/
    ├── auth/             # Modul login email/password & Google OAuth
    ├── profile/          # Profil pengguna, streak harian, dan lencana
    └── leaderboard/      # Papan peringkat global & kota teraktif
```

---

## 3. Cara Menjalankan Aplikasi
1.  Masuk ke direktori `mobile/`.
2.  Pasang dependensi Flutter:
    ```bash
    flutter pub get
    ```
3.  Buka berkas `lib/core/config/supabase_config.dart` dan lengkapi URL Supabase serta Anon Key proyek Anda.
4.  Jalankan aplikasi di emulator atau perangkat fisik:
    ```bash
    flutter run
    ```

---

## 4. Panduan Penulisan Kode (Clean Code)
Aplikasi mobile ini diwajibkan mengikuti panduan arsitektur ketat agar kode tidak berantakan:
*   **Dilarang Keras** menuliskan atau menyisipkan kunci `SUPABASE_SERVICE_ROLE_KEY` di aplikasi Flutter ini.
*   **Dilarang Keras** menggunakan tipe data `dynamic` secara bebas. Parsing JSON wajib dikonversi langsung menggunakan class model (`ProfileModel`, `BadgeModel`, dll.).
*   Semua logika bisnis, state management, dan pemanggilan API dilarang ditulis di dalam file UI/Widget. Wajib menggunakan **Auth BLoC**.

Selengkapnya mengenai aturan penulisan kode di Flutter silakan baca berkas:
👉 **[FLUTTER_CLEAN_CODE.md (Panduan Clean Code)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/FLUTTER_CLEAN_CODE.md)**
👉 **[MOBILE_ARCHITECTURE.md (Arsitektur Mobile)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/MOBILE_ARCHITECTURE.md)**
