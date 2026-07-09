# Genesis Backend Service (NestJS & Fastify)

[![NestJS Version](https://img.shields.io/npm/v/@nestjs/core.svg)](#)
[![Performance](https://img.shields.io/badge/performance-Fastify%20~45.000%20req/s-brightgreen)](#)
[![Security](https://img.shields.io/badge/security-Supabase%20JWT%20%7C%20RBAC-blue)](#)
[![Database](https://img.shields.io/badge/database-Supabase%20%28PostgreSQL%29-red.svg)](#)
[![API Live](https://img.shields.io/badge/🟢_API-LIVE-02569B?style=for-the-badge)](https://genesisHub.my.id/api)
[![Swagger Docs](https://img.shields.io/badge/📖_Swagger-Docs-E0234E?style=for-the-badge&logo=swagger&logoColor=white)](https://genesisHub.my.id/api)

<div align="center">
  <a href="https://genesisHub.my.id/api">
    <img src="https://img.shields.io/badge/⚙️_Buka_API_Swagger_Docs-E0234E?style=for-the-badge&logo=nestjs&logoColor=white" alt="API Swagger" />
  </a>
</div>

---

Layanan backend **Genesis** dirancang menggunakan arsitektur modular **NestJS** dengan engine adapter **Fastify** untuk memproses throughput request yang tinggi (mencapai ~45.000 request per detik). Backend ini mengelola seluruh logika bisnis utama, mulai dari sensor privasi gambar, geospasial dedup, kalkulasi gamifikasi, hingga chatbot regulasi RAG.

**Base URL Produksi**: `https://genesisHub.my.id`

---

## 1. Fitur Utama & Modul Sistem

Setiap fitur dirancang secara modular dengan pemisahan tanggung jawab (*Separation of Concerns*) yang ketat:

### A. Autentikasi & RBAC (Role-Based Access Control)
- **`AuthGuard`**: Memvalidasi JWT token Supabase dari header otorisasi HTTP (`Authorization: Bearer <token>`).
- **`RolesGuard`**: Menangani hak akses berbasis peran (misalnya membatasi endpoint dashboard admin hanya untuk role `'admin'` dan membiarkan endpoint pelaporan terbuka untuk `'citizen'`).

### B. Geospasial Spasial Deduplication (PostGIS)
- Menggunakan ekstensi PostGIS pada PostgreSQL untuk menyimpan data lokasi laporan dalam format geometri spasial `POINT(longitude latitude)`.
- Mengintegrasikan fungsi RPC `check_duplicate_report` dengan fungsi `ST_DWithin` untuk mendeteksi laporan serupa dalam radius 50 meter secara dinamis, sehingga mencegah laporan spam ganda di lapangan.

### C. Sensor Privasi Gambar (GCP Vision API & Sharp)
- Memproses gambar laporan secara in-memory untuk mendeteksi data sensitif (PII) seperti wajah dan plat nomor kendaraan melalui **Google Cloud Vision API**.
- Menggunakan pustaka **Sharp** untuk memburamkan (*blurring*) koordinat wajah dan plat nomor secara Gaussian sebelum gambar disimpan di **Google Cloud Storage (GCS)**.

### D. Chatbot AI RAG (Retrieval-Augmented Generation) & Whisper STT
- **Vektor Similarity Search**: Menghasilkan embedding teks (768 dimensi) melalui Google GenAI SDK (Vertex AI) dan mencari regulasi kota yang relevan di tabel Supabase `knowledge_base` menggunakan indeks HNSW.
- **SSE Streaming**: Mengirimkan jawaban asisten AI secara real-time chunk-by-chunk melalui Server-Sent Events (SSE).
- **Whisper STT**: Menerima unggahan rekaman suara warga dalam format base64 `.m4a` dan memanggil model Whisper-1 via Vertex AI / OpenRouter adapter untuk menghasilkan transkripsi teks secara presisi.
- **Prompt Injection Guardrails**: Sistem filter input lokal untuk mendeteksi dan meredaksi serangan bypass system prompt (misalnya character-spaced evasion, encoding evasion, dan typoglycemia).
- **Pengerasan Pemetaan Model (Hardcoded Model Mapping)**: Nama model dipetakan secara keras (*hardcoded*) di backend (`openrouter.service.ts`) ke Google Cloud Vertex AI: `'gemini-3.5-flash'` untuk Flash (kecepatan streaming SSE instan) dan `'gemini-3.1-pro-preview'` untuk Pro (dengan *thinking config* penalaran hukum/perda).

### E. Gamifikasi & Leaderboard Engine
- Mengelola XP warga, streak harian, dan lencana (*badges*).
- Menyediakan endpoint peringkat warga global (*Global Leaderboard*) dan kabupaten/kota terbersih (*City Leaderboard*) yang ditarik dari Postgres Views.

### F. Skrip Pemeliharaan Admin (Maintenance Scripts)
- **`delete_test_users.js`**: Skrip pemeliharaan admin untuk mendeteksi dan menghapus seluruh akun pengujian dari tabel `profiles` dan `auth.users` Supabase secara otomatis (menggunakan SDK Admin) jika alamat email/metadata mengandung unsur kata `arieffajar` atau `testing` guna menjaga integritas data dashboard.

---

## 2. Struktur Direktori Kode

```text
src/
├── auth/               # Sistem otentikasi JWT & Roles Guard
├── profiles/           # Logika profil warga, onboarding, & gamifikasi
├── badges/             # Pengelolaan katalog dan pemberian lencana
├── leaderboard/        # Endpoint data peringkat global & wilayah
├── reports/            # API pelaporan masalah lingkungan spasial
├── storage/            # Integrasi GCS & sensor gambar PII
├── openrouter/         # Integrasi Google GenAI SDK (Vertex AI) - *nama modul tetap openrouter demi kompatibilitas*
├── knowledge-base/     # CRUD dokumen hukum perda bagi admin
├── chat/               # Chatbot AI RAG & Transkripsi Audio
└── common/             # Interceptor, guard, & decorator global
```

---

## 3. Prasyarat & Pemasangan

### Prasyarat
- Node.js (v18+)
- Supabase Project dengan ekstensi `postgis` dan `vector`
- Akun Google Cloud dengan akses Google Cloud Storage, Cloud Vision API, dan Vertex AI
- Kunci API Google Cloud / OpenRouter (disimpan dalam variabel OPENROUTER_API_KEY)

### Langkah Pemasangan

1. Masuk ke direktori backend:
   ```bash
   cd backend
   ```

2. Instal dependensi Node.js:
   ```bash
   npm install
   ```

3. Konfigurasi file `.env`:
   Salin file `.env.example` ke `.env`:
   ```bash
   cp .env.example .env
   ```
   Lengkapi variabel lingkungan berikut:
   ```env
   PORT=3000
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   OPENROUTER_API_KEY=your-openrouter-key
   GCP_PROJECT_ID=your-gcp-project
   GCP_CLIENT_EMAIL=your-service-account-email
   GCP_PRIVATE_KEY=your-service-account-private-key
   GCS_BUCKET_NAME=your-gcs-bucket-name
   ```

4. Jalankan aplikasi dalam mode pengembangan:
   ```bash
   npm run start:dev
   ```

5. Lakukan kompilasi build produksi:
   ```bash
   npm run build
   npm run start:prod
   ```

---

## 4. Skrip Pembantu & Importer Regulasi

Kami menyediakan beberapa skrip otomatisasi di dalam folder `scripts/` untuk mengisi basis pengetahuan AI (RAG):

### A. Pengunggahan Massal Regulasi (Bulk Upload)
Mengunggah seluruh dokumen regulasi `.txt` atau `.md` dari folder lokal ke basis data Supabase (otomatis melakukan chunking dan pembuatan embedding vektor):
```bash
npx ts-node scripts/bulk-upload-knowledge.ts ../docs/regulations "<supabase_service_role_key>" "http://localhost:3000"
```

### B. Simulasi Penarikan Data JDIHN
Mengambil data undang-undang dan peraturan menteri langsung secara terprogram dari portal API JDIH Nasional, memilahnya, dan memasukkannya ke database:
```bash
npx ts-node scripts/scrape-and-import-jdih.ts "<supabase_service_role_key>" "http://localhost:3000"
```

---

## 5. Ringkasan API Kontrak

| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| `GET` | `/auth/verify` | JWT | Memverifikasi validitas token JWT dari klien |
| `GET` | `/profiles/me` | JWT | Mengambil profil detail warga dan lencana |
| `POST` | `/profiles/onboard` | JWT | Mengisi data profil & kota tinggal pada login pertama |
| `POST` | `/reports` | JWT | Mengunggah laporan baru (Multipart: file, lat, lng, desc) |
| `GET` | `/reports` | JWT | Mengambil seluruh riwayat laporan |
| `POST` | `/chat/stream` | JWT | Konsultasi AI RAG dengan respon streaming SSE |
| `POST` | `/chat/transcribe` | JWT | Transkripsi pesan suara menjadi teks (Whisper) |
| `GET` | `/leaderboard/global` | JWT | Mengambil daftar peringkat warga aktif global |
| `GET` | `/leaderboard/city` | JWT | Mengambil peringkat kota terbersih |
| `POST` | `/knowledge-base` | Admin | Menambahkan regulasi baru ke basis pengetahuan RAG |
| `DELETE`| `/profiles/:id` | Admin | Menghapus akun user secara cascade di Supabase |

---

## 6. Pengujian & Kualitas Kode

Backend dilengkapi dengan pengujian unit (*unit testing*) dan integrasi menggunakan Jest.
```bash
# Menjalankan Linter
npm run lint

# Menjalankan Unit Test
npm run test

# Menjalankan Integration Test
npm run test:e2e
```
