# Genesis — Smart City Ecological Governance Platform

Frontend repository untuk platform Genesis, sistem pelaporan lingkungan berbasis crowdsourcing dan konsol tata kelola ekologis perkotaan yang dibangun dengan **Next.js 16** dan **Tailwind CSS**.

---

## 👥 Tim Pengembang

Dibuat oleh siswa **SMK Marhas Margahayu** dalam rangka **Lomba Kompetensi Siswa (LKS) Dikdasmen 2026**.

| Nama | Peran |
|---|---|
| Arief Faja Reza Arrofi | Frontend Lead & Full Stack Developer |
| Alysia Fasma Nidai | UI/UX Designer & Frontend Developer |

---

## 🏗️ Arsitektur & Tech Stack

| Layer | Teknologi |
|---|---|
| Framework | Next.js 16 (App Router, Turbopack) |
| Styling | Tailwind CSS v4 |
| Bahasa | TypeScript (strict mode) |
| Auth | Supabase Auth (JWT) |
| Database Client | Supabase JS Client |
| HTTP Client | Native Fetch API |
| Icons | Lucide React |
| Deployment | Docker + Google Cloud Run |

---

## 📁 Struktur Direktori

```
frontend/
├── src/
│   ├── app/
│   │   ├── page.tsx              # Landing page utama (Hero + Bento Grid)
│   │   ├── solutions/page.tsx    # Halaman Solutions
│   │   ├── services/page.tsx     # Halaman Services
│   │   ├── features/page.tsx     # Halaman Features
│   │   ├── docs/page.tsx         # Halaman dokumentasi DaaS API & sandbox
│   │   ├── contact/page.tsx      # Halaman Contact
│   │   ├── admin/
│   │   │   ├── page.tsx          # Dashboard admin utama (semua tab)
│   │   │   ├── login/page.tsx    # Halaman login admin portal
│   │   │   └── components/       # Semua komponen tab admin
│   │   └── globals.css           # Global styles, scrollbar, animasi
│   └── components/
│       ├── Header.tsx            # Navbar dengan sticky+morph scroll effect
│       ├── Footer.tsx            # Footer SaaS reusable
│       └── BoomerangVideoBg.tsx  # Komponen video background loop
├── public/
│   ├── logo.png                  # Logo Genesis
│   └── videos/                  # Video hero untuk setiap halaman
├── Dockerfile                    # Multi-stage Docker build
├── next.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

---

## 🚀 Cara Menjalankan (Development)

```bash
# Install dependencies
npm install

# Jalankan dev server
npm run dev
```

Akses di `http://localhost:3000`

---

## ⚙️ Environment Variables

Buat file `.env.local` di root folder `frontend/`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

> ⚠️ **JANGAN** menyimpan `SUPABASE_SERVICE_ROLE_KEY` di sini. Kunci tersebut hanya boleh ada di backend NestJS.

---

## 🔑 Halaman Utama

| Route | Deskripsi |
|---|---|
| `/` | Landing page dengan Hero, dua Bento Grid section, modal login admin |
| `/solutions` | Solusi geospatial dan AI RAG |
| `/services` | Layanan B2G dan API enterprise |
| `/features` | Fitur gamifikasi, peta, AI visual |
| `/docs` | Dokumentasi DaaS API dengan live sandbox interaktif |
| `/contact` | Informasi kontak dan dukungan |
| `/admin` | Dashboard administrator (protected, JWT required) |
| `/admin/login` | Portal login admin |

---

## 🎨 Desain System

- **Warna Section**: `#dde2ef` (biru-abu lembut) untuk kontras terhadap kartu putih
- **Kartu**: `bg-white` dengan `border-slate-200` dan `shadow-[0_4px_20px_rgba(15,23,42,0.08)]`
- **Tipografi**: Body text `text-slate-600`, judul `text-slate-900`
- **Navbar**: Morphing effect — transparent saat top, menjadi kapsul floating saat scroll
- **Scrollbar**: Custom floating scrollbar transparan

---

## 🐳 Build & Deploy

```bash
# Build produksi
npm run build

# Build Docker image
docker build -t genesis-frontend .

# Jalankan container
docker run -p 3000:3000 genesis-frontend
```

---

## 📡 Integrasi Backend

Frontend berkomunikasi dengan backend NestJS di `https://genesisHub.my.id`. Semua request ke endpoint protected menggunakan header:

```http
Authorization: Bearer <supabase_jwt_token>
```

Untuk dokumentasi endpoint lengkap, buka halaman `/docs` dan gunakan **DaaS Sandbox Studio** secara langsung.

---

## 📜 Lisensi

Hak cipta © 2026 Tim Genesis — SMK Marhas Margahayu. Dibuat untuk LKS Dikdasmen 2026.
