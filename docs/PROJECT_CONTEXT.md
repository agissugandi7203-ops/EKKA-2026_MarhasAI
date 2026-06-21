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
  ├── auth/               # Modul autentikasi & RBAC Guard
  ├── profiles/           # Modul profil & onboarding
  ├── badges/             # Modul katalog lencana (badges)
  ├── leaderboard/        # Modul papan peringkat global & kota
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
- **Mobile (Flutter)**: Menerapkan Clean Architecture berbasis fitur.
  ```
  mobile/lib/
  ├── core/               # Fungsi utilitas global dan modul network
  └── features/
      ├── auth/
      │   ├── data/       # Model & repositori API
      │   ├── domain/     # Entity & usecase bisnis
      │   └── presentation/# Widget UI & State Management (BLoC/Notifier)
      ├── profile/        # Profil user, streak, & badges
      └── leaderboard/    # Papan peringkat global & wilayah kota
  ```

---

## 4. Strategi Integrasi (API-First OpenAPI)
Proyek ini mengintegrasikan Backend, Frontend, dan Mobile dengan spesifikasi **OpenAPI (Swagger)** untuk menghindari kesalahan ketik manual:
1. **NestJS** mempublikasikan file spesifikasi OpenAPI `swagger.json` secara otomatis saat dijalankan.
2. **Next.js** menghasilkan tipe data TypeScript dan service call menggunakan pustaka `openapi-typescript` / `orval`.
3. **Flutter** menghasilkan class model Dart dan API client menggunakan package `swagger_parser` / `openapi_generator_cli`.

Hal ini memastikan bahwa setiap perubahan skema data di Backend akan langsung mendeteksi error di sisi Frontend dan Mobile saat proses build.
