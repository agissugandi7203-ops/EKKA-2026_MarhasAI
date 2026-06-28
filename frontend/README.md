# Genesis Frontend Dashboard (Next.js)

[![Framework](https://img.shields.io/badge/Framework-Next.js%2016.2--React%2019-blue.svg)](#)
[![TypeScript](https://img.shields.io/badge/Language-TypeScript%205-teal.svg)](#)
[![Styling](https://img.shields.io/badge/Styling-TailwindCSS%204-purple.svg)](#)
[![SEO Ready](https://img.shields.io/badge/SEO-Optimized-brightgreen.svg)](#)

Genesis Frontend Dashboard adalah aplikasi portal web administrasi dan pusat kendali platform kebersihan kota Genesis yang dibangun menggunakan **Next.js** dan **React**. Portal ini berfungsi untuk memoderasi laporan warga, mengelola gamifikasi, serta mengunggah regulasi hukum ke basis pengetahuan RAG.

---

## 1. Fitur Utama & Modul Dashboard

Dashboard Admin (`/admin`) dilindungi oleh otentikasi JWT dengan tingkat hak akses `admin` yang ketat. Antarmukanya dibagi menjadi modul-modul berikut:

- **Overview Analytics**: Visualisasi kesehatan platform real-time menggunakan kartu metrik ringkasan (jumlah laporan, antrean verifikasi, warga aktif) dan bagan grafik kustom SVG (Bagan batang mingguan dan diagram donat status laporan).
- **Spatial Reports (Moderasi Laporan)**: Moderasi laporan masalah lingkungan secara spasial. Dilengkapi peta interaktif **Leaflet** (dengan ubin CartoDB Voyager) untuk memplot pin lokasi GPS laporan, serta laci detail untuk meninjau foto, klasifikasi AI Vision, dan melakukan aksi setuju/tolak/hapus.
- **Citizen Management**: Panel pencarian profil warga kota untuk mengoreksi data gamifikasi (XP, level, streak), memberikan atau mencabut lencana (*badges*), serta menangguhkan (*ban*) atau menghapus akun.
- **RAG Knowledge Base**: Antarmuka untuk mengelola regulasi perda. Admin dapat menambah dokumen hukum yang secara otomatis dipotong-potong (*chunking*) dan diubah menjadi embedding vektor di backend.
- **Challenge Center**: CRUD tantangan gamifikasi (Daily Quest / Seasonal Event) berbasis penambahan XP untuk memotivasi warga.
- **Broadcast Center**: Mengirim pesan pemberitahuan massal (*push notifications*) ke perangkat warga berdasarkan kategori info, peringatan, atau acara.
- **System Audit Log**: Catatan aktivitas admin yang bersifat read-only dan tidak dapat diubah (*immutable*) demi transparansi kepatuhan audit sistem.
- **Mode Dual (Live & Simulator)**:
  - *Live Mode*: Menghubungkan dashboard ke REST API produksi di `https://genesisHub.my.id`. Jika terjadi kegagalan jaringan, state akan dikosongkan dan menampilkan banner error (tidak ada toleransi silent fallback ke mock data).
  - *Simulator Mode*: Memanfaatkan data lokal ter-emulasi (*localStorage-backed*) untuk kebutuhan presentasi luring (*offline demo*).

---

## 2. Struktur Direktori Proyek

```text
frontend/
├── public/                     # Aset publik, sitemap, robots, & manifest
├── src/
│   ├── app/
│   │   ├── layout.tsx          # Root layout (Metadata SEO, fonts, JSON-LD)
│   │   ├── globals.css         # CSS global, Tailwind directive & token
│   │   ├── page.tsx            # Halaman Landing Page publik
│   │   └── admin/              # Panel dashboard administrasi (/admin)
│   │       ├── page.tsx        # Controller pusat dashboard
│   │       ├── login/          # Halaman otentikasi admin
│   │       └── components/     # Komponen tab modul (Overview, Reports, dll)
│   └── components/             # Komponen UI global (Header, Video Background)
├── Dockerfile                  # Multi-stage production build
└── package.json
```

---

## 3. SEO & Integrasi Metadata

Situs web dikonfigurasi secara ketat untuk mematuhi kaidah SEO modern:
- **Title & Description**: Dikonfigurasi dinamis per halaman untuk deskripsi yang relevan.
- **OpenGraph & Twitter Cards**: Tag OG lengkap (`og:title`, `og:description`, `og:image`, dll) dan kartu twitter berskala besar.
- **JSON-LD (Structured Data)**: Skema `Organization` disuntikkan langsung di root layout.
- **Sitemap & Robots**: File `/sitemap.xml` dinamis dengan 6 rute publik utama, serta `/robots.txt` yang ramah perayap (*crawler*).
- **Search Console & Canonical**: File verifikasi Google HTML dipasang, serta URL kanonik diatur ke `https://genesisHub.web.id`.

---

## 4. Persiapan & Cara Menjalankan

### Prasyarat
- Node.js (v18+)
- npm (v9+)

### Langkah Pemasangan

1. Masuk ke direktori frontend:
   ```bash
   cd frontend
   ```

2. Instal dependensi npm:
   ```bash
   npm install
   ```

3. Konfigurasi Kredensial Environment:
   Buat file `.env.local` di root folder frontend:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   ```
   > **⚠️ PERINGATAN KEAMANAN**: Jangan pernah menyertakan `SUPABASE_SERVICE_ROLE_KEY` di berkas environment frontend. Semua operasi tingkat admin wajib disalurkan melalui backend NestJS.

4. Jalankan aplikasi dalam mode pengembangan:
   ```bash
   npm run dev
   ```
   Aplikasi akan berjalan di `http://localhost:3000`.

5. Build aplikasi untuk produksi:
   ```bash
   npm run build
   npm run start
   ```

---

## 5. Kontainerisasi Docker Produksi

Frontend dilengkapi berkas `Dockerfile` multi-stage untuk kompilasi container yang dioptimalkan:
- **Stage 1 (Builder)**: Melakukan instalasi dependensi penuh dan menjalankan `next build`.
- **Stage 2 (Runner)**: Menggunakan alpine image ringan, menjalankan Next.js dengan mode `standalone`, serta menjalankan proses dengan pengguna non-root `nextjs` (UID 1001) demi keamanan infrastruktur. Ukuran image yang dihasilkan tereduksi dari ~500MB menjadi ~100MB.

Kompilasi Docker:
```bash
docker build -t genesis-frontend .
docker run -p 3000:3000 genesis-frontend
```

---

## 6. Screenshots & Dokumentasi Visual

Untuk presentasi luring atau pemuatan portofolio, tempatkan tangkapan layar antarmuka dashboard ke folder aset:
- **Path Penyimpanan**: `docs/assets/screenshots/frontend/`
- **File Rekomendasi**:
  - `landing.png`: Halaman utama landing page.
  - `admin_login.png`: Halaman login admin.
  - `admin_overview.png`: Visualisasi tab overview analitik.
  - `admin_reports.png`: Peta moderasi laporan spasial Leaflet.
  - `admin_rag.png`: Pengelolaan basis pengetahuan regulasi kota.

Penyematan di markdown menggunakan:
```markdown
![Admin Overview](../docs/assets/screenshots/frontend/admin_overview.png)
```
