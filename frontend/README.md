# Genesis.id Web Portal & Dashboard (Next.js)

[![Next.js Version](https://img.shields.io/badge/Next.js-v15.0%20%7C%20App%20Router-black.svg)](#)
[![Aesthetics](https://img.shields.io/badge/Aesthetics-Sleek%20Dark%20%7C%20Glassmorphism-purple.svg)](#)
[![Charts](https://img.shields.io/badge/charts-Tremor%20%7C%20Recharts-blue.svg)](#)

Aplikasi Web Frontend **Genesis.id** dibangun menggunakan **Next.js App Router** (TypeScript & React). Bagian ini berfungsi sebagai etalase publik (Landing Page), dasbor analitik interaktif bagi instansi pemerintah (DaaS), serta portal administrasi untuk memoderasi data.

---

## 1. Komponen Utama Web
1.  **Landing Page & CTA**: Halaman pemasaran utama untuk mengedukasi warga tentang platform crowdsourcing lingkungan dan tombol unduh aplikasi mobile (Flutter).
2.  **Admin Dashboard (Moderator Panel)**: Dasbor bagi administrator (manusia) untuk:
    *   Memantau metrik data masuk (jumlah warga terdaftar, grafik volume laporan).
    *   Memoderasi antrean laporan dari AI yang memiliki confidence score rendah.
    *   Menghapus/menolak akun pengguna yang melakukan spamming.
    *   Mengatur lencana dan gamifikasi secara manual.
    *   **Pengelolaan Knowledge Base AI (RAG Panel)**: Antarmuka visual untuk mengunggah perda baru (melakukan chunking & auto-embedding secara dinamis), meninjau daftar regulasi aktif, dan menghapus data referensi hukum yang kedaluwarsa.
3.  **API Documentation Portal (DaaS)**: Menyediakan Swagger UI / Dokumentasi OpenAPI interaktif yang menjelaskan bagaimana instansi pemerintah/smart city dapat mengintegrasikan data lingkungan spasial Genesis.id ke sistem mereka.

---

## 2. Struktur Proyek Web
```
frontend/src/
├── app/                # Next.js App Router Pages (Layout, Loading, Page entry points)
├── features/           # Logika bisnis terisolasi per fitur
│   ├── auth/           # Otentikasi login admin
│   ├── dashboard/      # Panel visualisasi chart (Tremor / Recharts)
│   └── api-portal/     # Dokumentasi API spesifikasi OpenAPI
├── components/         # Komponen UI global (Button, Card, Glassmorphic Container)
└── utils/              # Helper dan konfigurasi supabase client
```

---

## 3. Rekomendasi Library Chart & Visualisasi
Untuk merender data dashboard secara interaktif dan memukau juri LKS Nasional, proyek ini dirancang untuk menggunakan:
*   **Tremor (tremor.so)**: Untuk merender metric cards, donut charts (proporsi limbah), dan bar charts (10 kota terbersih) dengan visualisasi modern bertema *dark-mode* dan *glassmorphism*.
*   **Recharts**: SVG charting library untuk membuat area charts dengan degradasi warna yang bersinar (*neon glow effect*).

---

## 4. Setup & Jalankan Lokal
1.  Masuk ke direktori `frontend/` dan instal dependensi:
    ```bash
    npm install
    ```
2.  Konfigurasikan berkas `.env.local` berisi URL Supabase dan Anon Key Anda.
3.  Jalankan server pengembangan lokal:
    ```bash
    npm run dev
    ```
4.  Buka browser pada alamat `http://localhost:3000`.

---

## 5. Hubungan dengan Sub-Proyek Lain
*   Web Dashboard memanggil database **Supabase** secara langsung untuk menggambar grafik analytics (read-only) demi kecepatan performa.
*   Web Dashboard memanggil API **NestJS Backend** untuk aksi admin sensitif (seperti `DELETE /profiles/:id` atau `POST /badges/award`) karena aksi ini membutuhkan kunci *Service Role Key* yang tidak boleh diekspos ke browser web.
