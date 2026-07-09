# Project Context (Single Source of Truth)

Dokumen ini adalah acuan utama mengenai struktur, arsitektur, dan status pengembangan proyek **LKS Dikdasmen**. Setiap agen AI yang mengerjakan proyek ini harus merujuk ke dokumen ini terlebih dahulu.

---

## 1. Ringkasan Proyek
Proyek ini adalah sistem multi-platform yang terdiri dari:
- **Backend (NestJS)**: API Gateway dan bisnis logika server.
- **Frontend (Next.js)**: Aplikasi web untuk administrator/guru/operator (Web App).
- **Mobile (Flutter)**: Aplikasi mobile untuk siswa/pengguna umum (Android & iOS).

---

## 2. Struktur Direktori Utama
Proyek ini menggunakan struktur monorepo sederhana yang dibagi menjadi tiga sub-direktori utama:
- `backend/` : Aplikasi NestJS (TypeScript, Node.js).
- `frontend/` : Aplikasi Next.js App Router (TypeScript, React).
- `mobile/` : Aplikasi Flutter (Dart).
- `docs/` : Folder dokumentasi terpusat (arsitektur, panduan clean code, spesifikasi fitur).

---

## 3. Strategi Pengorganisasian Fitur (Feature-First)
Untuk memastikan skalabilitas jangka panjang dan isolasi tugas yang jelas bagi agen AI, proyek ini menggunakan pendekatan **Feature-First** (Pengorganisasian Berbasis Fitur):

### A. Struktur Dokumentasi (`docs/features/`)
Dokumentasi teknis untuk setiap fitur disimpan secara terpisah di folder `docs/features/` (misal: `auth.md`, `scores.md`). Setiap dokumen fitur harus menjelaskan:
1. Deskripsi bisnis fitur.
2. Alur data (*flow diagram* sederhana).
3. Kontrak API (request & response).
4. Penyesuaian khusus pada Backend, Frontend, dan Mobile.

### B. Struktur Kode Program
- **Backend (NestJS)**: Menggunakan modul NestJS bawaan untuk memisahkan fitur.
  ```
  backend/src/
  ├── auth/               # Modul autentikasi, RBAC Guard, & ChatThrottlerGuard
  ├── profiles/           # Modul profil & onboarding
  ├── badges/             # Modul katalog lencana (badges)
  ├── leaderboard/        # Modul papan peringkat global & kota
  ├── reports/            # Modul pelaporan masalah lingkungan spasial (Fitur 3)
  ├── storage/            # Modul Google Cloud Storage & Vision PII sensor (Fitur 3)
  ├── openrouter/         # Integrasi API OpenRouter (global)
  ├── knowledge-base/     # CRUD berkas regulasi kota oleh admin (Fitur 5)
  ├── chat/               # Chatbot AI RAG & streaming SSE warga (Fitur 5)
  └── common/             # Interceptor, guard, decorator global
  ```
- **Frontend (Next.js)**: Memisahkan folder `features` untuk logika bisnis dan UI dashboard interaktif.
  ```
  frontend/src/
  ├── app/                # Halaman / routing (Next.js App Router)
  ├── features/           # Logika bisnis per fitur
  │   ├── auth/           # Login admin
  │   ├── dashboard/      # Panel visualisasi chart (Tremor / Recharts)
  │   └── api-portal/     # Dokumentasi API untuk instansi B2G
  └── components/         # Komponen UI global (Button, Card, dll)
  ```
- **Mobile (Flutter)**: Menerapkan Clean Architecture berbasis fitur dengan Design System terpusat.
  ```
  mobile/lib/
  ├── core/
  │   ├── config/         # Supabase credentials
  │   ├── constants/      # Spacing, radius, durasi, form rules, SVG icons
  │   ├── errors/         # [NEW] Penanganan error terpusat
  │   │   ├── app_exception.dart   # Hierarki sealed class AppException
  │   │   └── error_handler.dart   # Mapper: DioException → AppException
  │   ├── network/        # DioClient + JWT interceptor
  │   ├── router/         # GoRouter + Routes constants + redirect guard
  │   ├── theme/          # AppColors, AppTextStyles, AppTheme, AppDecorations
  │   ├── utils/          # Validators, extensions (GenesisSnackBar)
  │   └── widgets/        # GenesisButton, GenesisTextField, GenesisLoading,
  │                       # GenesisErrorWidget, AuthListenerWrapper, IosButton
  └── features/
      ├── splash/         # Splash screen animasi (3 detik)
      ├── introduction/   # Pre-onboarding + 3-screen intro (swipeable)
      ├── auth/           # Login, Sign Up, Forgot PW, OTP, Reset PW
      │   ├── data/       # DataSource (Supabase Auth SDK) & Repository
      │   ├── domain/     # Repository interface (DIP)
      │   └── presentation/# AuthBloc, 5 pages, AuthListenerWrapper
      ├── setup/          # Post-login wizard (Welcome, Lokasi, Notif, Profil)
      ├── home/           # Beranda utama
      ├── profile/        # Profil user, streak, & badges
      ├── leaderboard/    # Papan peringkat global & wilayah kota
      ├── reports/        # Pelaporan spasial & upload data layer
      └── chat/           # Chatbot AI RAG warga (data source, model, BLoC)
  ```

---

## 4. Strategi Integrasi (API-First OpenAPI)
Proyek ini mengintegrasikan Backend, Frontend, dan Mobile dengan spesifikasi **OpenAPI (Swagger)** untuk menghindari kesalahan ketik manual:
1. **NestJS** mempublikasikan file spesifikasi OpenAPI `swagger.json` secara otomatis saat dijalankan.
2. **Next.js** menghasilkan tipe data TypeScript dan service call menggunakan pustaka `openapi-typescript` / `orval`.
3. **Flutter** menghasilkan class model Dart dan API client menggunakan package `swagger_parser` / `openapi_generator_cli`.

Hal ini memastikan bahwa setiap perubahan skema data di Backend akan langsung mendeteksi error di sisi Frontend dan Mobile saat proses build.

---

## 5. Strategi Deployment Produksi (Google Cloud Run + Docker)
Proyek ini dikonfigurasi untuk siap dideploy secara mandiri ke Google Cloud Run dengan kontainerisasi Docker:
1. **Backend (NestJS)**: Berkas Dockerfile multi-stage memisahkan devDependencies untuk menjaga ukuran kontainer agar cold-start cepat. Mengikat port dinamis `PORT` Cloud Run (default: 8080) pada IP `0.0.0.0`.
2. **Frontend (Next.js)**: Memanfaatkan mode `output: "standalone"` di konfigurasi Next.js untuk menyalin hasil optimal file tracing tanpa direktori `node_modules` besar. Citra yang dihasilkan sangat ringan (~100 MB) dan dijalankan dengan user non-root `nextjs` demi keamanan.

---

## 6. Fitur Unggulan Terbaru & Status Implementasi (SELESAI 100%)

Seluruh fitur inti dan integrasi multimedia canggih pada **Genesis.id** telah diselesaikan dan diuji dengan hasil **0 error/warning** baik di backend maupun mobile client:

### A. Integrasi RAG, Whisper STT & OpenRouter (Flutter-to-Backend) - [SELESAI]
*   **Chatbot RAG & SSE Streaming**: Asisten Geni AI mendukung streaming SSE (*Server-Sent Events*) real-time dari backend NestJS ke mobile client. Menggunakan model `google/gemini-2.5-flash` (bawaan), `google/gemini-2.5-pro`, dan `deepseek/deepseek-chat` via OpenRouter.
*   **Whisper STT (Speech-to-Text)**: Perekaman suara audio `.m4a` secara lokal di Flutter via `record` & `path_provider`, lalu dikirim secara aman ke endpoint backend `/chat/transcribe` untuk ditranskripsi menjadi teks menggunakan API model **OpenAI Whisper-1** via OpenRouter.
*   **Multimodal PDF & Image Inputs**: Pengguna dapat mengirim dokumen PDF (`file` type base64 data-url) dan gambar kamera/galeri untuk dianalisis oleh asisten Geni AI.

### B. Integrasi Google Vision API (PII Sensor) & Google Cloud Storage - [SELESAI]
*   **Sensor Gambar PII Otomatis**: Backend `PiiRedactionService` memanggil **Google Cloud Vision API** (`faceDetection` & `textDetection`) untuk mendeteksi wajah dan plat nomor kendaraan secara in-memory dari foto laporan yang dikirim warga.
*   **Sensor Sharp Blur**: Area terdeteksi otomatis diburamkan (*blurred*) menggunakan library `sharp` sebelum diunggah ke Google Cloud Storage melalui `GcsService`.
*   **Anti-Spam Spasial PostGIS**: Memanfaatkan PostGIS RPC `check_duplicate_report` untuk mendeteksi laporan serupa dalam radius 50 meter secara geografis sebelum menyimpan record baru.

### C. UI Dashboard Admin & Analisis AI Scan - [SELESAI]
*   **AI Scan Bottom Sheet**: Saat foto laporan diambil di Flutter, pengguna dapat mengeklik "AI Scan" untuk memicu analisis instan `/reports/analyze` di backend, menampilkan kategori sampah, tingkat keparahan, akurasi AI, dan rekomendasi tindakan secara interaktif menggunakan format Markdown.

### D. Toko Rewards & Penukaran Poin Sembako Gamifikasi - [SELESAI]
*   **Tukar Poin Sembako**: Menyediakan menu penukaran Poin Sembako claymorphic (Minyak Goreng, Beras Premium, Gula Kristal, Paket Sembako, Voucher Indomaret) yang memvalidasi perolehan koin emas (`xp * 3`) warga dari database secara dinamis.
*   **Podium & List Staggered Bouncy**: Podium papan peringkat 3 besar dan baris ranking meluncur masuk secara staggered menggunakan kurva elastis bouncy `Curves.easeOutBack` untuk nuansa visual premium.

### E. Onboarding Setup, Indikator Loading Global & Lottie Animation Integration - [SELESAI]
*   **12 Lottie Animations Premium**: Seluruh visualisasi statis/mockup atau CircularProgressIndicator/CupertinoActivityIndicator digantikan oleh Lottie: `global_loading.json` (loading spinner global & tombol), `ai_thinking.json` (AI thinking bubbles), `Congratulations.json` (dialog pendaftaran selesai), `list_set_up.json` (wizard welcome), `location_permission.json` (izin lokasi), `notification_permission.json` (izin notifikasi), `lengkapi_profil.json` (formulir profil), `Welcome.json` (dialog welcome beranda), `level_up.json` (dialog naik level), `strike_fire.json` (kartu streak), `badge.json` (kartu koin/EXP), dan `ai_home.json` (chat Geni AI home).
*   **Redirection Sesi Tanpa Kedip**: Alur deteksi sesi masuk di splash screen diperbarui untuk mendengarkan status otentikasi BLoC secara langsung, mengeliminasi kedipan halaman login saat sesi lama dipulihkan.
*   **Validasi Onboarding Ketat**: Mencegah bypass onboarding dengan validasi tiga kolom profil wajib (`username`, `province`, dan `cityOrDistrict`).
*   **Kejelasan Loading Tombol**: Memperbaiki kontras tombol M3 sehingga tidak menjadi abu-abu pudar saat loading dan memperlihatkan indikator loading Lottie dengan sangat jelas.

### F. Pembaruan UX & Bug Fixes Sistem Kritis (LATEST UPDATE) - [SELESAI]
*   **Fix Kamera Pertama Kali (Race Condition)**: Menambahkan jeda waktu singkat (300ms) setelah izin kamera disetujui pertama kali sebelum memanggil `availableCameras()`. Hal ini memberi waktu bagi OS native untuk memperbarui cache izin dan mengaktifkan kembali sensor kamera, melenyapkan error `CameraAccessDenied` saat pertama kali digunakan.
*   **Unifikasi Desain Chat AI Scan**: Input bar obrolan AI Analisis dalam `reports_page.dart` sekarang disamakan persis dengan halaman chat utama (`chat_page.dart`):
    * Kotak input bergaya 3D flat premium (warna putih, border 1.5px abu-abu, bayangan solid/flat, dan tombol kirim bergradien navy).
    * Fitur auto-expand tinggi kotak input (1 hingga 5 baris) secara mulus jika menulis beberapa baris/paragraf.
    * Penghapusan balon abu-abu (`AppColors.navy50`) pada respons AI sehingga teks markdown dirender langsung pada layar (ChatGPT/Geni Chat style) lengkap dengan garis pembatas tipis.
*   **Typewriter & Scroll Super Smooth**: Logika scroll pada efek typewriter obrolan AI Analisis dioptimalkan menggunakan `WidgetsBinding.instance.addPostFrameCallback` agar transisi meluncur halus pasca rendering frame teks baru, dan hanya melakukan auto-scroll jika pengguna berada di posisi bawah chat (menghindari stutters/lompatan paksa).
*   **Penanganan Izin Notifikasi Dinamis**: Mendaftarkan deklarasi `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` pada manifest Android gawai Android 13+ agar dialog permohonan izin notifikasi tidak terbypass secara otomatis.
*   **Penanganan Onboarding Terkunci (Setup Profile Stuck)**: Memosisikan `AuthListenerWrapper` (yang berisi `BlocListener` autentikasi) pada root utama widget tree `SetupProfilePage` sehingga widget tidak ter-unmount secara tidak sengaja ketika sedang submit profil, yang sebelumnya menyebabkan pengguna tersangkut di loading screen tanpa navigasi otomatis.
*   **Transisi Tour Tanpa Kedip**: Memperbarui rute navigasi `preOnboarding` dan `introduction` dalam router mobile untuk menggunakan transisi cross-fade custom (`_fadeTransitionPage`), mengeliminasi kedipan/flickering transisi antar layar tour.
*   **Peta Model AI Keras (Hardcoded Mappings)**: Memaksa pemetaan model di backend `openrouter.service.ts` secara keras (Vertex AI `gemini-3.5-flash` untuk Flash dan `gemini-3.1-pro-preview` untuk Pro) demi menjamin kinerja latensi rendah dan kemampuan berpikir tingkat tinggi (*thinking capabilities*) tanpa resiko fallback model lama.
