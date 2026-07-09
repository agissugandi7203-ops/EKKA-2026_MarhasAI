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

---

## 📢 Pembaruan Mobile Terbaru (Latest Mobile Updates)

Berikut adalah log pembaruan kritis di sisi aplikasi mobile (Flutter) untuk menjamin keandalan fungsionalitas dan konsistensi UI/UX:

### 1. 📷 Inisialisasi Kamera Mulus (First-Time Camera Access Fix)
*   **Akar Masalah**: OS native membutuhkan waktu beberapa milidetik untuk memperbarui cache izin dan mengaktifkan kembali sensor kamera setelah dialog pop-up disetujui pertama kali. Pemanggilan `availableCameras()` secara langsung dalam mikrodetik yang sama memicu error `CameraAccessDenied`.
*   **Perbaikan**: Menambahkan jeda waktu (*delay*) singkat sebesar 300ms (`await Future.delayed(const Duration(milliseconds: 300));`) setelah izin kamera diberikan agar OS menyelesaikan sinkronisasi hardware native sebelum dipanggil oleh Flutter.

### 2. 💬 Unifikasi Desain Input Obrolan AI Analisis
*   **Perbaikan**: Desain input obrolan AI Analisis (`reports_page.dart`) kini disamakan persis dengan halaman obrolan utama (`chat_page.dart`):
    *   **Visual 3D Flat**: Kotak input bergaya 3D flat premium dengan border radius 24px, ketebalan border 1.5px warna Slate (`#E2E8F0`), bayangan flat, dan tombol kirim bergradien navy.
    *   **Auto-Expanding TextField**: Mengonfigurasi `TextField` dengan `minLines: 1` dan `maxLines: 5` serta input multiline. Tinggi kotak input membesar otomatis menyesuaikan jumlah baris/paragraf teks masukan pengguna.
    *   **Clean Markdown View**: Penghapusan balon background abu-abu (`AppColors.navy50`) pada respons AI. Teks markdown kini dirender langsung di atas layar secara bersih mirip ChatGPT/Geni Chat dengan pembatas garis tipis (`Divider`) di bawahnya.

### 3. 🌊 Optimasi Scroll & Typewriter Smooth
*   **Perbaikan**: Logika scroll pada typewriter obrolan AI Analisis ditingkatkan menggunakan `WidgetsBinding.instance.addPostFrameCallback` untuk pergeseran baris baru pasca rendering frame teks baru.
*   **Threshold Checking**: Sistem hanya melakukan auto-scroll jika posisi layar berada di dasar obrolan (jarak scroll < 150px), mencegah lompatan paksa layar saat pengguna sedang menelusuri riwayat obrolan di atas.

### 4. 🔔 Deklarasi Izin Notifikasi Android 13+
*   **Perbaikan**: Mendaftarkan `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` di `AndroidManifest.xml` agar dialog permohonan izin notifikasi tidak terbypass secara otomatis pada gawai Android terbaru (API level 33 ke atas).

### 5. 🧩 Fix Onboarding Stuck (Setup Profile Stuck)
*   **Perbaikan**: Memindahkan `AuthListenerWrapper` ke root utama widget tree `SetupProfilePage` agar status BLoC listener tetap aktif selama proses pendaftaran disubmit. Pengguna kini langsung dialihkan otomatis ke dashboard beranda setelah submit profil selesai tanpa tersangkut di loading screen.

### 6. 🎬 Transisi Tour Bebas Kedip
*   **Perbaikan**: Menggunakan transisi custom cross-fade (`_fadeTransitionPage`) pada GoRouter untuk rute tour pra-onboarding (`preOnboarding` dan `introduction`), menghilangkan efek flicker transisi bawaan OS.

---

## 1. Fitur Utama & Logika Bisnis

Aplikasi mobile Genesis mengimplementasikan fitur-fitur kompleks berikut:

- **Autentikasi Komprehensif (Supabase & Google OAuth)**: Menyediakan alur registrasi, login, lupa kata sandi, verifikasi OTP, hingga reset kata sandi. Terintegrasi juga dengan Google Sign-in menggunakan Supabase ID Token.
- **Onboarding Setup Wizard (4 Langkah)**:
  - *Langkah 1: Welcome Screen*: Penjelasan awal proses pendaftaran profil.
  - *Langkah 2: Geolokasi & Geocoding*: Mendapatkan izin GPS perangkat, mengambil koordinat, dan melakukan reverse geocoding untuk menentukan wilayah administrasi kota secara otomatis.
  - *Langkah 3: Izin Notifikasi*: Meminta izin notifikasi perangkat secara elegan.
  - *Langkah 4: Kelengkapan Profil*: Mengisi nama lengkap dan username unik yang langsung divalidasi ke backend.
- **Laporan Masalah Lingkungan (Kamera & GPS)**: Mengakses kamera fisik untuk memotret sampah/limbah, mengambil koordinat GPS real-time, dan mengirimkannya ke server. Sistem dilengkapi deteksi duplikasi laporan serupa dalam radius 50 meter.
- **Asisten AI Chatbot Warga (Geni)**:
  - **Streaming SSE**: Menerima respons teks secara mengalir (Server-Sent Events) untuk latensi visual yang rendah.
  - **Speech-to-Text (STT)**: Perekaman suara lokal yang dikirim ke backend untuk ditranskripsi otomatis menggunakan model Whisper-1.
  - **Dinamis Model Selector**: Warga dapat memilih model AI (`Geni-Flash`, `Geni-Pro`, atau `DeepSeek-Chat`) melalui bottom sheet.
  - **Multimodal Input**: Mendukung pengiriman file PDF dan gambar untuk dianalisis oleh AI.
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
