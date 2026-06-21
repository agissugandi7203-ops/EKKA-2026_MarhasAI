# Dokumentasi Landing Page (Frontend)

## 1. Ikhtisar
Landing page proyek Genesis.id telah dipisahkan menjadi beberapa halaman terpisah (Multi-Page Application) dengan gaya desain SaaS modern. Tujuan pemisahan ini adalah untuk memperjelas informasi tanpa membuat satu halaman menumpuk, serta mengakomodasi navigasi yang lebih *smooth* dan responsif.

## 2. Struktur Halaman Baru
Terdapat 6 halaman utama di direktori `src/app/` Next.js:
1. `page.tsx` (Beranda/Utama): Memberikan perkenalan singkat tentang Genesis.id.
2. `solutions/page.tsx`: Menjelaskan solusi dan fitur produk secara komprehensif.
3. `services/page.tsx`: Menjelaskan infrastruktur B2G yang digunakan.
4. `features/page.tsx`: Berfokus pada peta *real-time* dan sistem gamifikasi.
5. `docs/page.tsx`: Portal referensi *developer* untuk integrasi API B2G.
6. `contact/page.tsx`: Halaman kontak dukungan 24/7.

Semua halaman tersebut dirancang agar konsisten, luas untuk di-scroll ke bawah (terdapat *dummy section* sementara), dan memancing pengguna dengan CTA yang terstandarisasi.

## 3. Komponen Inti: BoomerangVideoBg
Latar belakang video telah diganti dari komponen bawaan yang patah-patah menjadi mesin putar mundur (*ping-pong* / *boomerang loop*) khusus:
- **Lokasi Komponen**: `src/components/BoomerangVideoBg.tsx`
- **Sistem Kerja**: Komponen ini memutar video sekali sambil menangkap *frame*-nya pada `<canvas>` *offscreen* menggunakan `requestAnimationFrame` yang dibatasi pada maksimal **30 FPS**.
- **Kelancaran Backward**: Setelah video menyentuh detik ke-8 atau berakhir, video dipertahankan di latar (opacity 1) namun ditimpa langsung dengan `<canvas>` di posisi indeks terakhir. Ini menghilangkan *flicker* atau kedipan layar ketika terjadi transisi penukaran elemen DOM.
- **Optimasi Memori**: Pembatasan 30 FPS dan format `image/webp` (kualitas 0.7) menjaga agar memori *client-side* tetap hemat meskipun digunakan di *looping* jangka panjang.

## 4. Perbaikan Estetika UI & UX
Beberapa penyesuaian UX (*User Experience*) tingkat lanjut yang telah diterapkan:
- **Navigasi (*Navbar*) SaaS**: *Header* menjadi transparan murni dan tanpa *outline* putih di saat status *scrolled-top*. Saat pengguna melakukan *scroll* ke bawah, *navbar* berubah menjadi `sticky` berwujud putih padat / abu-abu dengan efek bayangan minimalis.
- **Keterbacaan (*Readability*) Overlay**: Lapisan `bg-black/50` diatur sebagai `absolute inset-0 z-10` menutupi video untuk menjaga kontras dan visibilitas tulisan putih (*hero text*) pada berbagai variasi cahaya latar video.
- **Penyelarasan Z-Index**: Z-Index diatur tegas: `z-50` untuk Navbar, `z-20` untuk Teks, `z-10` untuk transisi / *overlay*, dan `z-0` untuk komponen Video/Canvas.
- **Tombol Unduh (CTA)**: Tidak ada *section* unduh khusus yang dituju secara intrusif di halaman muka (awalnya di `/#download`). Tombol navigasi dirancang siap-hubung ke Google Play / App Store dan diseragamkan dengan ikon `lucide-react` (seperti *ShieldCheck*).

---
**Catatan untuk Agen Selanjutnya**: Jika Anda ingin mengimplementasikan portal Admin / RBAC, mulailah dengan memodifikasi rute komponen Navbar yang terhubung dengan modul Autentikasi Fastify Backend.
