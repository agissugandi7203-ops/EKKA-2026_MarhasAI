# Genesis.id — Platform Crowdsourcing & DaaS Lingkungan Nasional (LKS EKKA-2026)

🚀 **Platform Crowdsourcing Isu Lingkungan & Layanan Data-as-a-Service (DaaS) Pintar Berbasis Kecerdasan Artifisial Tingkat Tinggi**

[![Project Status](https://img.shields.io/badge/status-active-brightgreen.svg)](#)
[![Stack](https://img.shields.io/badge/stack-NestJS%20%7C%20Next.js%20%7C%20Flutter-blue.svg)](#)
[![Database](https://img.shields.io/badge/database-Supabase%20%28PostgreSQL%29-red.svg)](#)
[![Responsible AI](https://img.shields.io/badge/Responsible%20AI-GCP%20Vision%20PII%20Blurring%20%7C%20PostGIS%20AntiSpam-orange.svg)](#)
[![STT Voice](https://img.shields.io/badge/Voice%20AI-OpenAI%20Whisper--1-blueviolet.svg)](#)
[![Guardrails](https://img.shields.io/badge/Security-Prompt%20Injection%20Guardrails-purple.svg)](#)

---

## 📖 1. Latar Belakang & Urgensi Masalah

Pertumbuhan area urban yang cepat memicu tantangan pengelolaan lingkungan yang masif. Pemerintah sering kali mengalami keterlambatan dalam mendeteksi tumpukan sampah liar, kerusakan fasilitas kebersihan, atau pencemaran sungai karena keterbatasan personel lapangan. Di sisi lain, pelaporan konvensional oleh warga memiliki kendala utama:
1. **Spamming & Duplikasi Laporan Spasial**: Banyak warga melaporkan satu tumpukan sampah yang sama berulang kali, menyebabkan beban administrasi yang tinggi dan tidak efisien.
2. **Kebocoran Privasi (PII Leak)**: Foto laporan sering kali tidak sengaja memperlihatkan wajah orang lain atau plat nomor kendaraan pribadi yang melanggar UU Pelindungan Data Pribadi (UU PDP).
3. **Ketidakakuratan Klasifikasi Laporan**: Petugas kota kesulitan memilah jenis sampah (organik, anorganik, B3) dan tingkat bahayanya secara manual dalam waktu singkat.
4. **Ketidakramahan Layanan Informasi**: Portal regulasi pemerintah yang panjang, kaku, dan sulit dipahami warga.

**Genesis.id** hadir sebagai solusi komprehensif. Warga dapat melaporkan isu lingkungan secara instan, sementara AI mengelola sensor privasi gambar, menduplikasi laporan secara spasial, mengklasifikasikan jenis sampah, dan bertindak sebagai asisten hukum interaktif yang cerdas.

---

## ⚡ 2. Fitur Unggulan Sistem (The "Flex" Factor)

### 📌 A. Geospasial Anti-Spam (PostGIS Spatial Deduplication)
Sistem dilengkapi dengan filter spasial cerdas untuk menghindari duplikasi laporan. Sebelum laporan disimpan ke database:
*   Backend mengeksekusi fungsi RPC PostGIS `check_duplicate_report(lat, lng)` untuk memindai radius **50 meter** dari lokasi laporan baru.
*   Jika ditemukan laporan dengan status aktif pada radius tersebut, sistem secara otomatis akan menggabungkan laporan baru tersebut (*report merging*) alih-alih membuat entitas baru. Hal ini menghemat ruang penyimpanan, mencegah tumpang tindih visual di peta admin, dan memfokuskan sumber daya petugas di lapangan.

### 📌 B. PII Censorship Sensor (Google Cloud Vision API & Sharp)
Untuk mematuhi regulasi UU PDP secara ketat, platform menerapkan sensor data sensitif gambar secara in-memory sebelum diunggah ke Google Cloud Storage (GCS):
*   **Deteksi Wajah & Plat Nomor**: Gambar yang diunggah dikirim ke **Google Cloud Vision API** untuk mendeteksi koordinat wajah (`faceDetection`) dan plat nomor kendaraan (`textDetection`).
*   **Gaussian Blurring**: Backend memetakan koordinat bounding box yang dideteksi, lalu membramkan area tersebut menggunakan library `sharp` dengan kekuatan Gaussian blur optimal. Warga aman melapor tanpa khawatir melanggar hak privasi orang lain.

### 📌 C. AI Decision Engine & Auto-Approval
Setiap laporan yang berhasil disensor akan dianalisis secara asinkron oleh model kecerdasan artifisial vision:
*   AI mengklasifikasikan tipe sampah (Plastik, Organik, B3, Kertas, Logam, Kaca, dll), memperkirakan tingkat bahaya (*low, medium, high*), serta menghitung skor keyakinan (*confidence score*).
*   **Persetujuan Otomatis**: Jika laporan tersebut valid (`isValid = true`) dan memiliki keyakinan di atas **85%** (`confidence_score > 0.85`), sistem backend NestJS langsung memperbarui status laporan menjadi **Approved** dan memberikan poin reward serta XP kepada warga secara instan tanpa perlu persetujuan manual dari admin dinas kebersihan.

### 📌 D. Asisten Geni AI Chatbot RAG & Whisper STT
Sistem chatbot RAG (*Retrieval-Augmented Generation*) terintegrasi OpenRouter menyediakan asisten hukum perkotaan yang interaktif bernama Geni:
*   **Perekaman Suara Whisper STT**: Menggunakan paket `record` dan `path_provider` pada gawai, suara warga direkam ke format `.m4a` temporer dan dikirim ke backend NestJS `/chat/transcribe` untuk dikonversikan menjadi teks menggunakan model **OpenAI Whisper-1** via OpenRouter.
*   **Multimodal Input (Image & PDF)**: Chatbot AI mendukung input file dokumen PDF dan gambar secara langsung menggunakan parser `cloudflare-ai` / `mistral-ocr` di OpenRouter untuk interogasi dokumen hukum yang kompleks atau pengenalan objek visual.
*   **Vektor Cosine Similarity Supabase**: Potongan regulasi perda disimpan di tabel `knowledge_base` dengan ekstensi `pgvector` berdimensi `768` (model `google/gemini-embedding-2`), dipanggil melalui RPC `match_documents` untuk membatasi jawaban asisten hanya pada dokumen perda valid (anti-halusinasi).
*   **Advanced Prompt Injection Guardrails**: Backend dilengkapi penyaring prompt input cerdas untuk mencegah serangan instruksi sistem:
    *   *Character-Spaced Evasion*: Menghapus spasi antar karakter terpisah (contoh: `i g n o r e  p r e v i o u s` -> `ignore previous`).
    *   *Encoding-Based Evasion*: Mendekode format Hex (Continuous / Spaced) dan Base64 sebelum pemindaian.
    *   *Typoglycemia*: Mendeteksi kata-kata yang diacak huruf tengahnya (contoh: `ignroe`, `systme`).
    *   *Redaction*: Konten berbahaya diredaksi otomatis menjadi `[PROMPT_INJECTION]` agar aman dikirim ke LLM.

### 📌 E. Gamifikasi & Toko Rewards Sembako
*   **Visual Claymorphic**: Profil warga didesain ulang dengan gaya *claymorphism* modern dengan garis Slate tebal `1.5` dan bayangan lembut.
*   **Redemption Center Sembako**: Poin hasil laporan valid yang terhitung secara dinamis dari database (`xp * 3`) dapat ditukarkan di carousel sembako mockup berisi 5 item bernilai tinggi (Minyak Goreng 1L, Beras 2kg, Gula Kristal 1kg, Paket Sembako Lengkap, Voucher Indomaret Rp 50.000).
*   **Leaderboard Staggered Bouncy**: Podium top 3 besar peringkat kota dan baris list ranking meluncur masuk secara staggered menggunakan kurva elastis bouncy `Curves.easeOutBack` yang memanjakan mata juri dan pengguna.

---

## 🏗️ 3. Arsitektur Sistem & Aliran Data

### Sistem Arsitektur Monorepo
```mermaid
graph TD
    A[Flutter App Warga] -->|Kirim Laporan & GPS| B(API Gateway NestJS + Fastify)
    B -->|Check 50m Radius| C[PostgreSQL + PostGIS]
    B -->|Censor Wajah & Plat Nomor| D[GCP Vision API]
    D -->|Gaussian Blurring| E[Sharp Image Engine]
    E -->|Upload Buffer Ter-Sensor| F[Google Cloud Storage]
    B -->|Asynchronous Analysis| G[OpenRouter AI Vision Classify]
    G -->|Confidence > 85% & Valid| H[Auto-Approve & Reward User]
```

### RAG Chatbot Flow dengan Whisper STT
```mermaid
sequenceDiagram
    participant Citizen as Flutter Client (Warga)
    participant Backend as NestJS + Fastify Server
    participant Whisper as OpenRouter Whisper STT
    participant DB as Supabase pgvector
    participant LLM as OpenRouter LLM Stream

    Citizen->>Citizen: Rekam Suara (.m4a)
    Citizen->>Backend: Post /chat/transcribe (base64 audio)
    Backend->>Whisper: Request transkripsi suara
    Whisper-->>Backend: Kembalikan teks transkripsi
    Backend-->>Citizen: Tampilkan teks di Input Chat
    Citizen->>Backend: Post /chat/stream (Teks + PDF/Gambar)
    Backend->>Backend: Cek Evasion & Prompt Injection Guardrails
    Backend->>Backend: Generate Embedding (gemini-embedding-2)
    Backend->>DB: Kueri match_documents (Cosine Similarity 768)
    DB-->>Backend: 3 Dokumen Perda Terkait
    Backend->>LLM: Kirim Konteks Perda + Riwayat Obrolan + File
    LLM-->>Citizen: Aliran teks chunk SSE + Blinking Cursor █
```

---

## 🛠️ 4. Spesifikasi & Pilihan Model AI

Genesis.id menggunakan orkestrasi model AI terkemuka untuk memastikan efisiensi latensi, biaya, dan akurasi analisis:
1.  **google/gemini-2.5-flash**: Model default penyedia chat completion cepat dengan latensi sangat rendah, ideal untuk percakapan harian.
2.  **google/gemini-2.5-pro**: Digunakan untuk analisis dokumen regulasi daerah yang rumit atau penalaran kompleks.
3.  **deepseek/deepseek-chat (DeepSeek-V3)**: Pilihan model alternatif untuk completion terstruktur berkinerja tinggi.
4.  **openai/whisper-1**: Model transkripsi suara (Speech-to-Text) berakurasi tinggi dengan pemrosesan bahasa Indonesia alami yang sangat baik.
5.  **google/gemini-embedding-2**: Model penghasil representasi vektor 768 dimensi untuk basis pengetahuan regulasi hukum lingkungan.

---

## 📑 5. Daftar Regulasi Hukum yang Terpasang (Knowledge Base)

Basis pengetahuan asisten RAG Geni AI dilengkapi dengan produk hukum resmi Indonesia tingkat nasional hingga lokal:
*   `UUD 1945 Pasal Lingkungan`: Hak atas lingkungan yang baik dan sehat (Pasal 28H) & pembangunan berkelanjutan berwawasan lingkungan (Pasal 33).
*   `UU No. 18 Tahun 2008 tentang Pengelolaan Sampah`: Kewajiban reduce-reuse-recycle, larangan membakar sampah terbuka, dan tanggung jawab produsen.
*   `UU No. 32 Tahun 2009 tentang Perlindungan & Pengelolaan Lingkungan Hidup`: Aturan AMDAL, UKL-UPL, baku mutu air/udara, denda pidana pencemaran lingkungan hingga Rp15 Miliar.
*   `Perda Kota Bandung No. 9 Tahun 2018 tentang Pengelolaan Sampah`: Gerakan Kang Pisman, pembagian tempat sampah 3 warna (hijau, kuning, merah), jadwal pembuangan pukul 18:00-21:00 WIB, denda OTT Rp 50.000, serta penahanan KTP oleh PPNS.
*   `PP RI No. 22 Tahun 2021 tentang Penyelenggaraan PPLH`: Persetujuan lingkungan hidup, baku mutu emisi industri, dan baku mutu air nasional.
*   `Permen LHK No. 6 Tahun 2021 tentang Pengelolaan Limbah B3`: Tata cara penyimpanan, pelabelan simbol limbah B3, batas kedaluwarsa penyimpanan (90-180 hari), dan manifest elektronik (Festronik).
*   `UU RI No. 18 Tahun 2013 tentang Pencegahan Perusakan Hutan`: Pencegahan pembalakan liar, perambahan hutan, dan denda pidana korporasi kehutanan.

---

## 📦 6. Struktur Direktori Proyek

```
LKS Dikdasmen/
├── backend/            # Modul NestJS (Fastify, TypeScript, Node.js)
│   ├── src/
│   │   ├── chat/       # Perekaman suara Whisper & streaming chat
│   │   ├── reports/    # Upload laporan & AI Scan analyze
│   │   ├── storage/    # GCP Storage & Vision PII Blurring
│   │   └── openrouter/ # OpenAI Whisper, Gemini, Embedding client
├── frontend/           # Aplikasi Web Next.js App Router (TypeScript, React)
│   └── src/app/        # Dashboard Analitik Admin & B2G API Portal
├── mobile/             # Aplikasi Mobile Flutter (Dart)
│   └── lib/features/   # Clean Architecture (Auth, Leaderboard, Setup, Chat, Profile)
├── docs/               # Kumpulan spesifikasi fitur & arsitektur
└── README.md           # Berkas petunjuk utama (Dokumen ini)
```

---

## 🛠️ 7. Panduan Instalasi & Setup Lokal (Local Setup)

> [!NOTE]
> *Langkah-langkah instalasi ini ditujukan untuk lingkungan pengembangan lokal (development environment).*

### A. Prasyarat Sistem
*   [Node.js](https://nodejs.org/) (v18+)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+)
*   [Git](https://git-scm.com/)

### B. Konfigurasi Database & Supabase
1. Buat akun dan proyek baru di [Supabase Cloud](https://supabase.com).
2. Di menu ekstensi database, aktifkan ekstensi `postgis` dan `vector`.
3. Jalankan query SQL penyiapan tabel, views, dan RPC `match_documents` serta `check_duplicate_report` yang berada di direktori [docs/database/](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/database) melalui SQL Editor Supabase Anda.

### C. Menjalankan Server Backend (NestJS)
1. Buka terminal, arahkan ke folder `backend/`:
   ```bash
   cd backend
   npm install
   ```
2. Salin berkas `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```
3. Lengkapi kredensial pada berkas `.env` Anda (Supabase URL, Service Role Key, OpenRouter API Key, GCS Credentials, dll).
4. Unggah regulasi perda awal ke database RAG menggunakan CLI script:
   ```bash
   npx ts-node scripts/bulk-upload-knowledge.ts "../docs/regulations" "<your_supabase_service_role_key>" "http://localhost:3000"
   ```
5. Jalankan server backend dalam mode pengembangan:
   ```bash
   npm run start:dev
   ```

### D. Menjalankan Aplikasi Mobile (Flutter)
1. Buka terminal baru, arahkan ke folder `mobile/`:
   ```bash
   cd mobile
   flutter pub get
   ```
2. Pastikan file konfigurasi koneksi database telah sesuai di `lib/core/config/supabase_config.dart`.
3. Jalankan aplikasi pada emulator atau perangkat yang terhubung:
   ```bash
   flutter run
   ```
