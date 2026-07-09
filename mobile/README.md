# Genesis Mobile Application (Flutter)

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.19%20%7C%20Dart%20v3.x-blue.svg)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%7C%20Feature--First-brightgreen.svg)](#)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%7C%20Cubit-blue.svg)](#)
[![Navigation](https://img.shields.io/badge/Navigation-GoRouter-purple.svg)](#)
[![Design System](https://img.shields.io/badge/Design-Material%203-teal.svg)](#)

<div align="center">
  <a href="https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk">
    <img src="https://img.shields.io/badge/📥_DOWNLOAD_APK_ANDROID_(arm64)-02569B?style=for-the-badge&logo=android&logoColor=white" alt="Download APK Android" />
  </a>
</div>

---

Genesis Mobile adalah aplikasi gawai berbasis Android yang dirancang khusus untuk warga kota Genesis agar dapat melaporkan masalah lingkungan secara spasial, melakukan konsultasi hukum perda melalui asisten cerdas, serta berpartisipasi dalam gamifikasi kebersihan kota.

**Backend API**: `https://genesisHub.my.id` | **Web Dashboard**: `https://genesisHub.web.id`

## 1. Fitur Utama & Logika Bisnis

Aplikasi mobile Genesis mengimplementasikan fitur-fitur kompleks berikut:

- **Autentikasi Komprehensif (Supabase & Google OAuth)**: Menyediakan alur registrasi, login, lupa kata sandi, verifikasi OTP, hingga reset kata sandi. Terintegrasi juga dengan Google Sign-in menggunakan Supabase ID Token.
- **Onboarding Setup Wizard (4 Langkah)**:
  - *Langkah 1: Welcome Screen*: Penjelasan awal proses pendaftaran profil.
  - *Langkah 2: Geolokasi & Geocoding*: Mendapatkan izin GPS perangkat, mengambil koordinat, dan melakukan reverse geocoding untuk menentukan wilayah administrasi kota secara otomatis.
  - *Langkah 3: Izin Notifikasi*: Meminta izin notifikasi perangkat secara elegan. Mengintegrasikan izin `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` pada manifest Android guna menjamin dialog izin berjalan dinamis pada Android 13+ (API 33+).
  - *Langkah 4: Kelengkapan Profil*: Mengisi nama lengkap dan username unik. Menggunakan widget `AuthListenerWrapper` terpadu di root halaman setup profil untuk memastikan BLoC listener tetap aktif selama proses pendaftaran disubmit, sehingga pengguna langsung dialihkan otomatis ke dashboard beranda setelah submit selesai tanpa tersangkut di loading screen.
- **Transisi Tour Bebas Kedip**: Menggunakan transisi custom cross-fade (`_fadeTransitionPage` di GoRouter) untuk rute tour pra-onboarding (`preOnboarding` dan `introduction`), menghilangkan efek flicker transisi bawaan OS.
- **Laporan Masalah Lingkungan (Kamera & GPS)**: Mengakses kamera fisik untuk memotret sampah/limbah, mengambil koordinat GPS real-time, dan mengirimkannya ke server. Sistem dilengkapi deteksi duplikasi laporan serupa dalam radius 50 meter.
  - *Inisialisasi Kamera Mulus (First-Time Access Fix)*: Menambahkan jeda waktu (*delay*) singkat sebesar 300ms setelah izin kamera pertama kali diberikan sebelum mendeteksi daftar kamera (`availableCameras()`), memberi waktu bagi OS native untuk sinkronisasi perangkat keras agar terhindar dari error `CameraAccessDenied`.
- **Asisten AI Chatbot Warga (Geni & Obrolan Analisis)**:
  - **Streaming SSE**: Menerima respons teks secara mengalir (Server-Sent Events) untuk latensi visual yang rendah.
  - **Speech-to-Text (STT)**: Perekaman suara lokal yang dikirim ke backend untuk ditranskripsi otomatis menggunakan model Whisper-1.
  - **Dinamis Model Selector**: Warga dapat memilih model AI (`Geni-Flash`, `Geni-Pro` dengan thinking configuration, atau `DeepSeek-Chat`) melalui bottom sheet.
  - **Multimodal Input**: Mendukung pengiriman file PDF dan gambar untuk dianalisis oleh AI.
  - **Unifikasi UI Premium Obrolan (ChatGPT Style)**: Kotak input obrolan pada asisten utama dan asisten hasil analisis AI disamakan menggunakan container 3D flat (radius 24px, border 1.5px, bayangan solid, dan tombol kirim bergradien navy) yang mendukung *auto-expand* (melebar dari 1 hingga 5 baris). Respons AI ditampilkan secara bersih tanpa balon abu-abu (ChatGPT style) dengan typewriter effect dan auto-scroll yang super smooth (viewport-sensitive menggunakan `WidgetsBinding` frame callbacks).
- **Gamification & Poin Sembako**:
  - Papan peringkat (*Leaderboard*) global dan per kota.
  - Leveling system (XP bertambah +100 setiap laporan disetujui, naik level setiap kelipatan 1000 XP).
  - Daily Quest tracker ("Submit 1 report" memberikan bonus XP tambahan).
  - Redemption Center untuk menukarkan akumulasi koin dengan sembako (Minyak Goreng, Beras Premium, dll).

---

## 2. Arsitektur Kode (Clean Architecture)

Aplikasi mobile ini menerapkan pemisahan tanggung jawab yang ketat berbasis **Clean Architecture** dan **Feature-First**:

```text
lib/
├── core/
│   ├── config/              # Kredensial Supabase & Konfigurasi Global
│   ├── constants/           # Konstanta spacing, radius, durasi, rules
│   ├── errors/              # Struktur penanganan error terpusat
│   ├── network/             # DioClient kustom dengan JWT Bearer Interceptor
│   ├── router/              # Konfigurasi GoRouter & Redirect Guard
│   ├── theme/               # Design System Material 3 terpusat
│   ├── utils/               # Validasi & Dart extensions (GenesisSnackBar)
│   └── widgets/             # Widget modular (GenesisButton, GenesisTextField, dll)
└── features/
    ├── splash/              # Animasi pembuka (3 detik)
    ├── introduction/        # 3 slides pengenalan fitur
    ├── auth/                # Alur masuk & daftar akun (5 halaman)
    ├── setup/               # Post-login onboarding wizard (4 langkah)
    ├── home/                # Beranda utama & akses cepat
    ├── profile/             # Profil warga, statistik streak, & lencana
    ├── leaderboard/         # Ranking kontribusi warga global & kota
    └── reports/             # Pelaporan spasial & upload data
```

Setiap fitur dalam direktori `features/` dibagi menjadi tiga lapisan:
1. **Data Layer**: Terdiri dari `datasources` (HTTP API Calls & Supabase SDK) dan `models` (deserialisasi JSON).
2. **Domain Layer**: Kontrak repositori (`repositories`) yang mendefinisikan interaksi data (Dependency Inversion Principle).
3. **Presentation Layer**: UI (`pages`, `widgets`) dan pengelola status aplikasi menggunakan `bloc` atau `cubit`.

---

## 3. Manajemen Status (State Management BLoC/Cubit)

Genesis menggunakan `flutter_bloc` untuk memisahkan logika bisnis dari UI:
- **`AuthBloc`**: Mengelola status autentikasi (`Authenticated`, `Unauthenticated`, `AuthFailure`). Menangani transisi navigasi global dan mendeteksi apakah pengguna membutuhkan onboarding setup wizard.
- **`SetupCubit`**: Mengelola state pendaftaran 4 langkah. Di-scope secara lokal pada sub-router sehingga otomatis di-dispose setelah selesai untuk menghindari kebocoran memori (*memory leak*).
- **`ReportsBloc`**: Mengelola pengunggahan laporan baru, validasi status duplikasi laporan dari backend, dan penarikan riwayat laporan aktif.
- **`ChatBloc`**: Mengelola riwayat obrolan dan pemrosesan stream Server-Sent Events (SSE) yang masuk dari NestJS.

---

## 4. Penanganan Error Terpusat

Aplikasi menggunakan pendekatan terpusat untuk mendeteksi dan menampilkan error:
- **`AppException`**: Struktur `sealed class` yang mengkategorikan kesalahan menjadi `NetworkException`, `ServerException`, `AuthException`, `DeviceException`, dan `UnexpectedException`.
- **`ErrorHandler`**: Mengkonversi error pustaka eksternal (seperti `DioException` atau `SocketException`) menjadi `AppException` yang ramah bagi pengguna.
- **`GenesisErrorWidget`**: Antarmuka visual yang menggantikan "Red Screen of Death" bawaan Flutter ketika terjadi kegagalan rendering widget di layar.
- **`GenesisSnackBar`**: Ekstensi `BuildContext` untuk menampilkan pemberitahuan mengambang (*floating*) yang rapi (`context.showErrorSnackBar`, `context.showSuccessSnackBar`).

---

## 5. Design System & Typography

- **Nunito**: Digunakan untuk elemen tulisan besar (*display* dan *headline*) karena bentuknya yang melengkung lembut (*rounded*), memberikan kesan ramah dan modern.
- **Plus Jakarta Sans**: Digunakan untuk teks isi (*body*) karena memiliki keterbacaan (*readability*) yang sangat tinggi pada layar gawai.
- **Palet Warna**:
  - **Navy** (`#0A1628` - `#1B3A76`): Warna primer, memberikan kesan profesional.
  - **Burgundy** (`#800020` - `#A3324B`): Warna sekunder untuk maskot.
  - **Gold** (`#C8922A`): Warna aksen untuk XP, Koin, Lencana, dan Peringkat.
  - **Emerald** (`#1B7A4E`): Warna aksen lingkungan, status berhasil, dan streak harian.

---

## 6. Persiapan & Cara Menjalankan

### Prasyarat
- Flutter SDK (v3.19+)
- Perangkat Android fisik atau Emulator Android dengan API level 29+

### Langkah-langkah Menjalankan

1. Masuk ke direktori proyek mobile:
   ```bash
   cd mobile
   ```

2. Unduh paket dependensi Flutter:
   ```bash
   flutter pub get
   ```

3. Konfigurasi Kredensial Supabase:
   Buka file [supabase_config.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/core/config/supabase_config.dart) dan sesuaikan URL serta Publishable Key dengan proyek Supabase Anda:
   ```dart
   class SupabaseConfig {
     static const String url = 'YOUR_SUPABASE_URL';
     static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

4. Jalankan kode generator untuk parser spesifikasi API (jika ada perubahan kontrak API):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Hubungkan perangkat Android dan jalankan aplikasi dalam mode pengembangan:
   ```bash
   flutter run
   ```

6. Lakukan analisis kualitas kode untuk memastikan kepatuhan terhadap aturan penulisan:
   ```bash
   flutter analyze
   ```

---

## 7. Pengambilan & Penyematan Screenshots

Setiap halaman utama aplikasi harus memiliki screenshot panduan yang ditaruh pada folder aset dokumentasi.

### Cara Pengambilan Screenshot Berkualitas:
1. Jalankan aplikasi pada Emulator Android (disarankan menggunakan resolusi standar Pixel 5 atau Pixel 6).
2. Gunakan perintah pintasan emulator atau jalankan:
   ```bash
   adb shell screencap -p /sdcard/screen.png
   adb pull /sdcard/screen.png ./docs/assets/screenshots/mobile/nama_halaman.png
   ```
3. Letakkan semua gambar screenshot ke direktori `docs/assets/screenshots/mobile/` dengan penamaan:
   - `splash.png`: Halaman splash screen pembuka.
   - `intro.png`: Halaman slider pengenalan.
   - `login.png`: Halaman login utama.
   - `setup_location.png`: Halaman perizinan lokasi onboarding.
   - `home.png`: Beranda utama dashboard warga.
   - `report_camera.png`: Pratinjau pengambilan foto laporan.
   - `chat_geni.png`: Aliran chat RAG dengan asisten Geni.
   - `leaderboard.png`: Tampilan peringkat kontribusi kota.

Penyematan gambar di dalam dokumentasi menggunakan format:
```markdown
<img src="../docs/assets/screenshots/mobile/nama_file.png" width="280" alt="Deskripsi Halaman" />
```

---

## 6. Detail Arsitektur State Management & Lifecycle BLoC (Deep Dive)

Untuk mempermudah audit teknis bagi dewan juri, bagian ini menjelaskan secara terperinci aliran logika bisnis dan siklus hidup komponen gawai pada aplikasi Genesis:

### A. Aliran Autentikasi & Integrasi Token JWT Supabase
Aplikasi mobile Genesis mengamankan seluruh request API menggunakan otentikasi token JWT dinamis yang dipasok oleh Supabase:
*   **`AuthBloc`**: Mengelola status masuk/keluar pengguna (`Unauthenticated`, `Authenticating`, `Authenticated`, `AuthError`).
*   **Interceptor Dio Client**: Kustom `DioClient` mengimplementasikan interceptor penjelajah header untuk menyisipkan token JWT secara asinkron dari session aktif Supabase pada setiap request keluar:
    ```dart
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          return handler.next(options);
        },
      ),
    );
    ```
*   **Refresh Token**: Dio Interceptor secara otomatis menangani error `401 Unauthorized` dengan menembak penyedia refresh session Supabase, memperbarui token secara in-memory, dan mengulang kembali (*retry*) request klien yang tertunda tanpa gangguan visual bagi pengguna.

### B. Setup Onboarding Wizard BLoC Lifecycle & AuthListenerWrapper
Wizard onboarding berjalan melalui status terverifikasi bertahap. Masalah kritis di mana state loading memutus navigasi telah diselesaikan:
*   **Geolokasi & Izin Notifikasi**: GPS mengambil data koordinat lintang/bujur dan mengirimkannya ke endpoint `/profiles/onboard` bersamaan dengan status persetujuan `POST_NOTIFICATIONS`.
*   **Aligning `AuthListenerWrapper`**: Agar `BlocListener<AuthBloc, AuthState>` tidak terhapus dari memori (*unmounted*) sewaktu memicu state loading, ia diposisikan pada root widget tree tertinggi halaman `SetupProfilePage`. Hal ini menjamin status listener tetap aktif mengawasi perubahan ke state `Authenticated` untuk memicu aksi navigasi GoRouter `context.go('/home')` secara instan dan bebas kedip.

### C. Sinkronisasi Modul Kamera Fisik & Anti-Race Condition
Akses kamera pada menu `reports_page.dart` menangani transisi izin perangkat keras dengan aman:
*   **Jeda OS Native**: Ketika sistem dialog izin kamera OS Android muncul, status aplikasi Flutter beralih ke `AppLifecycleState.inactive`. Seketika pengguna menekan "Allow", aplikasi aktif kembali dan langsung menjalankan pendeteksian perangkat keras.
*   **Delay 300ms**: Tanpa jeda, OS belum selesai mengalokasikan memori hardware ke driver kamera, memicu error `CameraAccessDenied`. Solusinya adalah menyisipkan jeda sinkronisasi:
    ```dart
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Jeda 300ms yang menjamin sinkronisasi OS native selesai
      await Future.delayed(const Duration(milliseconds: 300));
      final cameras = await availableCameras();
      _initializeCameraController(cameras.first);
    }
    ```

### D. Optimasi Scroll Viewport-Sensitive & Typewriter Streaming SSE
Respons visual Markdown obrolan dari Geni AI dirancang sangat mulus tanpa stutters:
*   **PostFrameCallback**: Setiap karakter baru yang mengalir masuk dari Server-Sent Events (SSE) memicu pembaruan UI. Pemanggilan scroll diprogram menggunakan `WidgetsBinding.instance.addPostFrameCallback` agar bergulir pasca frame selesai dirender, mencegah konflik pengukuran tinggi konten dinamis.
*   **Ambang Batas 150px**: Untuk melindungi pengalaman membaca pengguna, auto-scroll dinonaktifkan sementara jika jarak scroll viewport pengguna ke batas bawah melebihi 150px (artinya pengguna sengaja scroll ke atas untuk meninjau pesan lama).

### E. Manajemen Memori & Pembuangan Sumber Daya (Disposal)
Semua halaman/widget mematuhi standar bebas kebocoran memori (*memory leak-free*) sesuai dengan **`AGENTS.md`**:
*   Penggunaan `TextEditingController` untuk input bar, `ScrollController` untuk viewport chat, dan `CameraController` untuk sensor kamera dibersihkan secara eksplisit di dalam metode lifecycle `dispose()`:
    ```dart
    @override
    void dispose() {
      _textController.dispose();
      _scrollController.dispose();
      _cameraController?.dispose();
      _streamSubscription?.cancel();
      super.dispose();
    }
    ```
*   Setiap animasi transisi Lottie diatur agar berhenti berputar ketika elemen visual bergeser keluar dari layar (*off-screen*).

