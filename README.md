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
    *   Jalankan seluruh query SQL dari folder [docs/database/](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/database) di SQL Editor Supabase Anda.
2.  **Konfigurasi Backend**:
    *   Masuk ke folder `backend/`, salin `.env.example` menjadi `.env`, lalu isi kredensial Supabase, OpenRouter API Key, dan RAG parameters Anda.
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

---

## 5. Integrasi Chat AI & Pengelolaan Basis Pengetahuan RAG (Knowledge Base)

Sistem chatbot AI pada **Genesis.id** didukung oleh arsitektur **RAG (Retrieval-Augmented Generation)** tingkat tinggi yang terhubung secara real-time dengan basis data peraturan hukum resmi di Supabase.

### A. Sumber Data Hukum Lingkungan Resmi (JDIH Portal)
Asisten AI membatasi jawaban obrolan warga hanya berdasarkan dokumen regulasi valid untuk menghindari halusinasi. Sumber data hukum nasional disinkronkan dan dirangkum dari beberapa portal **JDIH (Jaringan Dokumentasi dan Informasi Hukum)** resmi pemerintah Indonesia:
1.  **JDIH BPHN Kemenkumham (Portal Nasional - jdihn.go.id)**:
    *   **Peran**: Pusat integrasi data dokumen hukum nasional dari seluruh instansi pemerintah daerah, kementerian, dan lembaga tinggi negara.
    *   **Metode Integrasi**: Melalui REST API JDIHN menggunakan protokol pertukaran data JSON berbasis `access_token` dan sinkronisasi `secret_key` instansi.
2.  **JDIH Kementerian LHK (jdih.menlhk.go.id)**:
    *   **Peran**: Menyediakan produk hukum khusus kehutanan dan lingkungan hidup (Peraturan Menteri LHK, Keputusan Menteri LHK, dan Undang-Undang sektoral).
3.  **JDIH BPK RI (peraturan.bpk.go.id)**:
    *   **Peran**: Pusat data hukum terlengkap untuk mengunduh salinan berkas lembaran negara dan penjelasan resmi (UU, PP, Perpres, Permen).
4.  **JDIH Pemerintah Kota Bandung (jdih.bandung.go.id)**:
    *   **Peran**: Regulasi tingkat lokal/daerah kota Bandung (Perda Pengelolaan Sampah, Peraturan Walikota Bandung).

### B. Berkas Regulasi Lokal Terpasang (`docs/regulations/`)
Berkas peraturan lingkungan terperinci telah disiapkan secara lengkap dan terstruktur di dalam repositori untuk segera di-ingest:
*   [UUD 1945 Pasal Lingkungan](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/UUD_1945_Pasal_Lingkungan.txt): Konstitusi dasar Indonesia mengenai hak warga atas lingkungan yang sehat (Pasal 28H) dan demokrasi ekonomi berwawasan lingkungan (Pasal 33).
*   [UU No. 18 Tahun 2008 tentang Pengelolaan Sampah](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/UU_No_18_Tahun_2008_Pengelolaan_Sampah.txt): Regulasi nasional lengkap mengenai reduce-reuse-recycle (3R), kewajiban produsen, larangan pembakaran sampah terbuka, serta sanksi pidana kelalaian.
*   [UU No. 32 Tahun 2009 tentang Perlindungan & Pengelolaan Lingkungan Hidup](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/UU_No_32_Tahun_2009_Lingkungan_Hidup.txt): Kerangka hukum induk pengelolaan lingkungan (AMDAL, UKL-UPL, baku mutu emisi/air, persetujuan lingkungan, dan sanksi denda pidana hingga Rp15 Miliar).
*   [Perda Kota Bandung No. 9 Tahun 2018 tentang Pengelolaan Sampah](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/Perda_Kota_Bandung_No_9_Tahun_2018_Pengelolaan_Sampah.txt): Aturan praktis lokal di Kota Bandung (Gerakan Kang Pisman, pemilahan 3 jenis wadah warna hijau-kuning-merah, retribusi daerah, jadwal pembuangan pukul 18:00-21:00 WIB, denda OTT Rp 50.000, serta penahanan KTP oleh PPNS DLHK).
*   [PP RI No. 22 Tahun 2021 tentang Penyelenggaraan PPLH](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/PP_RI_Nomor_22_Tahun_2021_tentang_Penyelenggaraan_Perlindungan_dan_Pengelolaan_Lingkungan_Hidup.txt): Ketentuan teknis persetujuan lingkungan, pengawasan emisi industri, baku mutu air nasional, serta tata kelola limbah B3.
*   [Permen LHK No. 6 Tahun 2021 tentang Pengelolaan Limbah B3](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/Peraturan_Menteri_LHK_Nomor_6_Tahun_2021_tentang_Tata_Cara_dan_Persyaratan_Pengelolaan_Limbah_B3.txt): Regulasi detail pelabelan simbol B3, penyimpanan limbah B3, batas kedaluwarsa 90-180 hari, dan dokumen Manifest Elektronik (Festronik).
*   [UU RI No. 18 Tahun 2013 tentang Pencegahan Perusakan Hutan](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/regulations/UU_RI_Nomor_18_Tahun_2013_tentang_Pencegahan_dan_Pemberantasan_Perusakan_Hutan.txt): Larangan pembalakan liar, perambahan hutan, serta sanksi pidana korporasi hingga Rp15 Miliar.

### C. Alur Pemrosesan Teks & Vektor RAG
Pecahan dokumen dimasukkan ke database melalui dua skrip CLI otomatis pada direktori `backend/`:

1.  **Unggah Berkas Lokal Massal (`bulk-upload-knowledge.ts`)**:
    Membaca semua file teks `.txt`/`.md` dari folder regulations, membaginya ke dalam ukuran potongan teks kustom, dan mengirimkannya ke endpoint backend.
    ```bash
    cd backend
    npx ts-node scripts/bulk-upload-knowledge.ts "../docs/regulations" "<supabase_service_role_key>" "http://localhost:3000"
    ```

2.  **Scraper JDIH & Importer Otomatis (`scrape-and-import-jdih.ts`)**:
    Menghubungkan sistem secara simulated ke portal API JDIHN nasional untuk mencari produk hukum, mengumpulkan metadata komprehensif, dan mengunggahnya secara real-time.
    ```bash
    cd backend
    npx ts-node scripts/scrape-and-import-jdih.ts "<supabase_service_role_key>" "http://localhost:3000"
    ```

**Teknis Pemrosesan**:
*   **Text Chunking**: String panjang dipecah menggunakan algoritma Smart Space Alignment dengan ukuran token yang diatur pada berkas `.env` (`RAG_CHUNK_SIZE` default 800 karakter, `RAG_CHUNK_OVERLAP` default 150 karakter) untuk menjaga kesatuan arti kalimat.
*   **Vektor Komparasi**: Menggunakan model `google/gemini-embedding-2` melalui OpenRouter API untuk menghasilkan vektor bernilai 768 dimensi.
*   **Pencarian Spasial Kosinus**: Di-indeks menggunakan HNSW pada database Supabase, dicari dengan RPC kustom `match_documents(query_embedding, match_threshold, match_count)` untuk menyajikan konteks dokumen paling relevan ke model LLM (Geni-Flash, Geni-Pro, DeepSeek-Chat) secara streaming SSE.

Untuk informasi detail lainnya mengenai kueri SQL vektor, silakan merujuk pada:
👉 **[KNOWLEDGE_BASE_GUIDE.md (Panduan RAG)](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/KNOWLEDGE_BASE_GUIDE.md)**

