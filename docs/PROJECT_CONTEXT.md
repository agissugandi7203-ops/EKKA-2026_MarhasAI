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

## 6. Roadmap & Rencana Fitur Masa Depan

Berdasarkan kesiapan sistem saat ini (Fondasi Backend, Mobile Network/BLoC, dan SEO telah siap), berikut adalah rencana pengerjaan fitur selanjutnya untuk mencapai tingkat produksi penuh:

### A. Integrasi RAG & OpenRouter (Flutter-to-Backend)
*   **Alasan**: Menghubungkan visualisasi chat melayang citizen dan analitik bottom-sheet AI Scan di Flutter ke server NestJS.
*   **Teknis**:
    *   Uji endpoint `/chat/stream` menggunakan SSE (Server-Sent Events) decoder di Flutter BLoC dengan real host production `https://genesisHub.my.id`.
    *   Ingestion pipeline regulasi daerah (.pdf/txt) dari Next.js Admin Dashboard ke NestJS `/knowledge-base` untuk auto-vectorize ke Supabase pgvector.

### B. Integrasi Google Vision API (PII Sensor) & Google Cloud Storage
*   **Alasan**: Menghubungkan fungsionalitas kamera nyata di Flutter dengan PII censorship wajah & plat nomor otomatis di backend NestJS.
*   **Teknis**:
    *   Konfigurasi `GOOGLE_APPLICATION_CREDENTIALS` (Service Account Key) di `.env` server backend.
    *   Aktifkan call Google Vision API untuk deteksi boundary box wajah dan teks plat nomor.
    *   Hubungkan stream/buffer gambar terpotong ke Sharp library untuk Gaussian Blurring, dilanjutkan upload otomatis ke bucket GCS via GcsService.
    *   Ganti pengiriman mock camera di Flutter ke multipart file upload asli `POST /reports`.

### C. Fitur Notifikasi Real-time (FCM & Realtime DB)
*   **Alasan**: Memberitahu warga kapan laporan mereka divalidasi dinas atau mendapatkan lencana baru secara instan.
*   **Teknis**: Integrasi Firebase Admin SDK di NestJS untuk Push Notifications (FCM) dan Supabase Realtime Channel untuk in-app notification badge.

### D. Integrasi UI Dashboard Admin (Next.js Frontend)
*   **Alasan**: Menyediakan antarmuka manajemen laporan, catalog lencana, dan edit basis pengetahuan perda bagi Admin/Operator Dinas.
*   **Teknis**: Pembuatan halaman visualisasi analitik laporan (Tremor/Recharts), panel peninjauan manual laporan (`pending_human`), dan upload perda.

### E. Sistem Penugasan Dinas & GIS Map Interaktif (Spatial GIS)
*   **Alasan**: Dinas kebersihan kota perlu memetakan sebaran tumpukan sampah secara geografis untuk penugasan kru taktis.
*   **Teknis**: Integrasi Leaflet/Google Maps di Next.js & Flutter Map dengan memanfaatkan PostgreSQL/PostGIS spatial query (`ST_DWithin` & GeoJSON).

### F. Toko Rewards & Penukaran Poin Gamifikasi (E-Voucher)
*   **Alasan**: Meningkatkan partisipasi pelaporan warga dengan hadiah voucher nyata (voucher bus kota, e-wallet).
*   **Teknis**: Katalog `rewards` dan transaksi penukaran `user_redemptions` dengan validasi kuota voucher di backend.


