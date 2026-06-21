# Genesis.id - Platform Crowdsourcing & DaaS Lingkungan Nasional (LKS EKKA-2026)

[![Project Status](https://img.shields.io/badge/status-active-brightgreen.svg)](#)
[![Stack](https://img.shields.io/badge/stack-NestJS%20%7C%20Next.js%20%7C%20Flutter-blue.svg)](#)
[![Database](https://img.shields.io/badge/database-Supabase%20%28PostgreSQL%29-red.svg)](#)
[![Responsible AI](https://img.shields.io/badge/Responsible%20AI-PII%20Blurring%20%7C%20PostGIS%20AntiSpam-orange.svg)](#)

**Genesis.id** adalah platform crowdsourcing isu lingkungan dan layanan **Data-as-a-Service (DaaS)** untuk B2G/B2B. Dibuat khusus untuk Lomba Kompetensi Siswa (LKS) Dikmen Tingkat Nasional 2026 (Ekshibisi Kecerdasan Artifisial - Studi Kasus 2: Lingkungan). Platform ini memberdayakan warga untuk memetakan masalah lingkungan via gawai, lalu menyalurkan data analitik tervalidasi AI kepada pemerintah melalui Public API.

---

## 1. Arsitektur Proyek (Monorepo)

Proyek ini terbagi menjadi tiga pilar utama yang terintegrasi secara harmonis:

1.  **[Backend (NestJS + Fastify)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/backend)**: API Gateway berkecepatan tinggi (~45.000 req/s), pengelola sensor gambar (PII Redaction), geo-deduplikasi spasial PostGIS, integrasi Gemini AI (Vertex AI), dan RAG Chatbot.
2.  **[Mobile Client (Flutter)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile)**: Aplikasi warga untuk melaporkan isu lingkungan dengan penandaan GPS, sensor kamera, interogasi gambar ("AI Per-Seksi"), serta maskot & leaderboard gamifikasi.
3.  **[Web Dashboard & Portal (Next.js)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend)**: Dasbor analitik interaktif berbasis chart (Tremor/Recharts) untuk admin memoderasi laporan dan memantau trafik, serta portal dokumentasi API untuk kebutuhan B2G.

---

## 2. Struktur Direktori Utama

```
LKS Dikdasmen/
├── backend/            # Aplikasi NestJS (TypeScript, Node.js)
├── frontend/           # Aplikasi Web Next.js App Router (TypeScript, React)
├── mobile/             # Aplikasi Mobile Flutter (Dart)
├── docs/               # Dokumentasi terpusat proyek
│   ├── PROJECT_CONTEXT.md       # SSOT konteks & status proyek
│   ├── CLEAN_CODE_GUIDELINES.md # Pedoman penulisan kode global (anti-slip)
│   ├── INTEGRATION_GUIDE.md     # Panduan integrasi otomatis OpenAPI
│   ├── BACKEND_ARCHITECTURE.md   # Detail arsitektur backend & katalog API
│   ├── MOBILE_ARCHITECTURE.md    # Arsitektur Dio, Data Source & BLoC Flutter
│   └── FLUTTER_CLEAN_CODE.md    # Panduan clean code Dart & Flutter
└── README.md           # Berkas petunjuk root (Dokumen ini)
```

---

## 3. Alur Data Utama (Core Loop)

```
[Flutter App] ──> Ambil Foto & GPS ──> Sensor PII (sharp) ──> Simpan di GCS
                                                                    │
[Leaderboard] <── +XP & Level <── Setuju / Tolak <── Gemini AI / Admin Web
```

---

## 4. Cara Memulai Pengembangan (Local Setup)

### A. Prasyarat (Prerequisites)
Pastikan Anda sudah menginstal:
*   [Node.js](https://nodejs.org/) (v18+)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+)
*   [Git](https://git-scm.com/)

### B. Langkah Setup
1.  **Database & Cloud**:
    *   Buat proyek di [Supabase Cloud](https://supabase.com). Aktifkan ekstensi `postgis` dan `vector`.
    *   Jalankan query SQL dari berkas [01_initial_schema.sql](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/database/01_initial_schema.sql) di SQL Editor Supabase Anda.
2.  **Konfigurasi Backend**:
    *   Masuk ke folder `backend/`, salin `.env.example` menjadi `.env`, lalu isi kredensial Supabase Anda.
    *   Jalankan backend:
        ```bash
        cd backend
        npm install
        npm run start:dev
        ```
3.  **Konfigurasi Mobile**:
    *   Masuk ke folder `mobile/`, buka file `lib/core/config/supabase_config.dart`, lalu masukkan URL dan Anon Key Supabase Anda.
    *   Jalankan Flutter:
        ```bash
        cd mobile
        flutter pub get
        flutter run
        ```
