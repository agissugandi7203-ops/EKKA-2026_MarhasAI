# Genesis.id Mobile App (Flutter)

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.19%20%7C%20Dart%20v3.x-blue.svg)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%7C%20Feature--First-brightgreen.svg)](#)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC-blue.svg)](#)
[![Navigation](https://img.shields.io/badge/Navigation-GoRouter-purple.svg)](#)
[![Design System](https://img.shields.io/badge/Design-Material%203-teal.svg)](#)

Aplikasi gawai **Genesis.id** dibangun menggunakan **Flutter** (Dart) untuk sisi warga/komunitas. Menangani kamera untuk memotret anomali lingkungan, koordinat GPS spasial presisi tinggi, gamifikasi kepedulian sosial, serta chatbot edukasi berbasis RAG.

---

## 1. Fitur Utama

| # | Fitur | Keterangan |
|---|-------|------------|
| 1 | **Splash + Introduction** | 3 slides intro (Lapor, Gamifikasi, Kompetisi Kota) + auto-navigate |
| 2 | **Auth Flow (5 halaman)** | Login, Sign Up, Forgot Password, OTP Verification, Reset Password |
| 3 | **Google Sign-In** | OAuth via Supabase `signInWithIdToken` |
| 4 | **Post-Login Setup Wizard** | 4 langkah: Welcome → Lokasi GPS → Notifikasi → Profil |
| 5 | **Profile & Gamifikasi** | XP bar, level, streak harian, katalog lencana |
| 6 | **Onboarding Geolokasi** | Auto-detect kota via reverse geocoding (Geolocator) |
| 7 | **Dio Client + JWT** | Interceptor otomatis Bearer token ke backend NestJS |
| 8 | **Streaming Chatbot AI RAG** | Chatbot asisten warga real-time dengan streaming Server-Sent Events (SSE) |
| 9 | **Dinamis Model AI Selector** | Pemilihan model AI (`Geni-Flash`, `Geni-Pro`, `DeepSeek-Chat`) melalui Modal Bottom Sheet yang terintegrasi langsung dengan state BLoC dan request payload Dio |
| 10| **Voice Waveform Indicator** | Visualisasi gelombang suara dinamis ketika warga merekam suara |
| 11| **Kamera Aktif & GPS Laporan** | Kamera fisik aktif dengan pratinjau foto dan penandaan lokasi GPS Geolocator |

---

## 2. Struktur Clean Architecture

```
mobile/lib/
├── core/
│   ├── config/              # Supabase URL & Publishable Key
│   ├── constants/           # Spacing, radius, durasi, form rules
│   ├── network/             # Kustom DioClient dengan JWT interceptor
│   ├── router/              # GoRouter + Routes constants
│   ├── theme/               # Design System terpusat
│   │   ├── app_colors.dart       # Palet warna (Navy, Burgundy, Gold, Emerald)
│   │   ├── app_text_styles.dart  # Typography (Nunito + Plus Jakarta Sans)
│   │   ├── app_theme.dart        # ThemeData Material 3
│   │   └── app_decorations.dart  # Shadow, gradient, decoration presets
│   ├── utils/               # Validators, extensions
│   └── widgets/             # Reusable branded widgets
│       ├── genesis_button.dart       # Tombol (primary, secondary, text)
│       ├── genesis_text_field.dart   # Input field + password toggle
│       ├── genesis_loading.dart      # Loading indicator
│       └── genesis_scaffold.dart     # Scaffold wrapper + SafeArea
└── features/
    ├── splash/              # Splash screen animasi (3 detik)
    ├── introduction/        # 3 slides pengenalan fitur
    ├── auth/                # Login, Sign Up, Forgot PW, OTP, Reset PW
    ├── setup/               # Post-login wizard (Welcome, Lokasi, Notif, Profil)
    ├── home/                # Beranda utama
    ├── profile/             # Profil user, streak, & badges
    ├── leaderboard/         # Papan peringkat global & kota
    └── reports/             # Pelaporan spasial & upload
```

---

## 3. Alur Navigasi

```
Splash (3s) → [Pertama?] Introduction → Login
                                          ├─→ Sign Up
                                          ├─→ Forgot Password → OTP → Reset Password
                                          └─→ [Auth OK]
                                                ├─→ [Perlu Onboarding] Setup Wizard (4 step)
                                                └─→ Home
```

---

## 4. Design System

### Palet Warna
| Peran | Warna | Hex | Psikologi |
|-------|-------|-----|-----------|
| Primary | Navy | `#152D5C` | Kepercayaan, profesionalisme |
| Mascot | Burgundy | `#800020` | Keberanian, passion |
| Achievement | Gold | `#C8922A` | Prestasi, premium |
| Environment | Emerald | `#1B7A4E` | Alam, keberhasilan |

### Typography
| Level | Font | Karakter |
|-------|------|----------|
| Heading | **Nunito** | Soft, rounded, friendly |
| Body | **Plus Jakarta Sans** | Modern, readable, Indonesia-origin |

## 4.1. Dinamis Model AI Selector & Aliran Data
Aplikasi mobile menyediakan fitur pemilihan model AI secara real-time:
*   **Antarmuka Pengguna (UI)**: Ditempatkan pada Modal Bottom Sheet ketika pengguna menekan tombol `+` di sebelah input composer halaman `ChatPage`.
*   **State Management (BLoC)**:
    1.  Pengguna memilih model pada UI. Model ID disimpan di state lokal halaman Chat (`_selectedModel`).
    2.  Saat mengirim pesan, event `SendMessageRequested(message: _controller.text, model: _selectedModel)` dikirim ke `ChatBloc`.
    3.  `ChatBloc` memanggil `ChatRepository` yang diteruskan ke `ChatRemoteDataSource`.
*   **Payload Dio Interceptor**:
    `ChatRemoteDataSource` mengirimkan data ke backend NestJS `/chat/stream` (SSE) dengan menyertakan kunci `"model"` di dalam JSON body request:
    ```json
    {
      "message": "Apa isi Pasal 28H UUD 1945?",
      "model": "google/gemini-2.5-pro"
    }
    ```

---

## 5. Cara Menjalankan Aplikasi

```bash
# 1. Masuk ke direktori mobile
cd mobile

# 2. Install dependencies
flutter pub get

# 3. Konfigurasi Supabase (edit file)
#    lib/core/config/supabase_config.dart
#    Isi URL dan Publishable Key proyek Supabase Anda

# 4. Jalankan di Android emulator/device
flutter run

# 5. Pastikan kode bersih
flutter analyze
```

> **⚠️ Catatan**: Fokus saat ini adalah **Android**. Pastikan emulator Android atau device fisik terhubung saat menjalankan `flutter run`.

---

## 6. Aset & Placeholder

```
mobile/assets/
├── images/              # Ilustrasi statis (intro, auth, setup)
├── icons/               # Ikon kustom (SVG/PNG)
└── animations/          # Lottie JSON (maskot, achievement, transisi)
    ├── mascot/          # Placeholder → akan diganti animasi JSON
    ├── achievements/    # Streak fire, level up, badge unlock
    └── transitions/     # Loading globe, page transition
```

> Maskot saat ini menggunakan ikon placeholder. Akan digantikan dengan animasi Lottie JSON.

---

## 7. Panduan Clean Code

| Aturan | Deskripsi |
|--------|-----------|
| **No Magic Numbers** | Semua konstanta di `AppConstants` |
| **No Ad-hoc Colors** | Semua dari `AppColors` / `Theme.of(context)` |
| **No Dynamic Types** | Parsing JSON via class model (strict type safety) |
| **No Logic in Widgets** | UI hanya render dari BLoC State |
| **Immutable Models** | Semua properti `final`, perubahan via `copyWith` |
| **Centralized Validators** | Selaras dengan backend DTO (NestJS class-validator) |

📖 Selengkapnya:
- **[FLUTTER_CLEAN_CODE.md](../docs/FLUTTER_CLEAN_CODE.md)** — Standar kode Dart
- **[MOBILE_ARCHITECTURE.md](../docs/MOBILE_ARCHITECTURE.md)** — Arsitektur lengkap
- **[CLEAN_CODE_GUIDELINES.md](../docs/CLEAN_CODE_GUIDELINES.md)** — Standar global
