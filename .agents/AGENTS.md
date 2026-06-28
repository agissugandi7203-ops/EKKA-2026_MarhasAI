# Aturan Agen AI (Project-Scoped Rules)

Selamat datang di proyek **Genesis.id**! Proyek ini berskala besar dan terdiri dari tiga komponen utama: Backend (NestJS + Fastify), Frontend (Next.js), dan Mobile (Flutter).

Sebelum memulai tugas apa pun atau menulis kode, Anda **WAJIB** membaca dokumen konteks berikut untuk memahami status proyek dan arsitektur yang ada:

1.  **[PROJECT_CONTEXT.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/PROJECT_CONTEXT.md)**: Gambaran umum arsitektur proyek, teknologi yang digunakan, dan status pengerjaan fitur.
2.  **[CLEAN_CODE_GUIDELINES.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/CLEAN_CODE_GUIDELINES.md)**: Standar penulisan kode global (anti-slip) untuk memastikan kode konsisten dan bebas bug.
3.  **[INTEGRATION_GUIDE.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/INTEGRATION_GUIDE.md)**: Cara mengintegrasikan Backend, Frontend, dan Mobile menggunakan generator API OpenAPI.
4.  **[BACKEND_ARCHITECTURE.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/BACKEND_ARCHITECTURE.md)**: Detail arsitektur backend NestJS + Fastify, alur keamanan JWT & RBAC (Role-Based Access Control), dan katalog API.
5.  **[MOBILE_ARCHITECTURE.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/MOBILE_ARCHITECTURE.md)**: Detail arsitektur Flutter kustom Dio, pemrosesan Data Sources, serta logika alur onboarding lokasi pada Auth BLoC.
6.  **[SEO_GUIDELINE.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/SEO_GUIDELINE.md)**: Panduan konfigurasi SEO, penanganan DNS, Google Search Console, dan sitemap dinamis/statis.
7.  **[chat.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/features/chat.md)**: Panduan fitur Chatbot RAG, skema vector, model OpenRouter, dan respon streaming.

---

## 🛑 Aturan Keamanan & Desain Penting (WAJIB DIPATUHI)

### 1. Peran Pengguna (RBAC)
*   Sistem membedakan pengguna berdasarkan kolom `role` di tabel `public.profiles`. Nilainya adalah `'citizen'` (warga biasa / pengguna Flutter) dan `'admin'` (administrator / pengelola Next.js dashboard).
*   Gunakan dekorator `@Roles('admin')` bersama dengan `RolesGuard` di backend NestJS untuk mengamankan rute sensitif.

### 2. Keamanan Kunci Rahasia (Service Role Key)
*   **JANGAN PERNAH** menuliskan atau menyisipkan kunci `SUPABASE_SERVICE_ROLE_KEY` di sisi frontend web (Next.js) or mobile (Flutter). 
*   Kunci bypass keamanan ini hanya boleh diletakkan di berkas `.env` server backend NestJS. Semua operasi admin yang sensitif (seperti menghapus akun pengguna, memodifikasi lencana pengguna secara manual) wajib disalurkan melalui endpoint admin NestJS.

### 3. Otomatisasi Header JWT pada Flutter
*   Aplikasi Flutter berinteraksi dengan API NestJS menggunakan kustom `DioClient` yang secara otomatis menyisipkan token JWT Supabase aktif ke header `Authorization: Bearer <token>`. 
*   Saat menulis pemanggilan API baru di Flutter, gunakan `DioClient` untuk memastikan otentikasi berjalan lancar.

### 4. Pengelolaan Lencana (Badges) Dinamis
*   Lencana disimpan di tabel `public.badges`. Relasi lencana yang didapat pengguna disimpan di `public.profile_badges` (Many-to-Many).
*   Admin memiliki kontrol penuh untuk memberikan (`POST /badges/award`) atau mencabut (`DELETE /badges/revoke`) lencana pengguna melalui endpoint admin NestJS.
*   Admin juga berhak mengoreksi data gamifikasi pengguna (XP, Level, Streak) secara manual melalui endpoint `PATCH /profiles/:id/gamification`.

### 5. Domain Produksi & SEO (GenesisHub)
*   **Domain Frontend**: `https://genesisHub.web.id`
*   **Domain Backend**: `https://genesisHub.my.id`
*   Setiap kali memodifikasi routing atau menambahkan halaman baru di frontend Next.js, Anda **WAJIB** memperbarui file `public/sitemap.xml` dan memastikan bahwa metadata halaman (title, description, canonical url) telah diset dengan benar untuk kepatuhan SEO.
*   Klien API di Flutter wajib mengarah ke domain produksi backend `https://genesisHub.my.id` secara bawaan.

---

## Aturan Khusus Setiap Pengerjaan Fitur:
*   Jika Anda diminta mengerjakan atau memperbaiki suatu fitur, periksalah dokumen spesifik fitur tersebut di folder [docs/features/](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/features/).
*   Selalu patuhi prinsip clean code yang ada dalam [CLEAN_CODE_GUIDELINES.md](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/docs/CLEAN_CODE_GUIDELINES.md).
*   Jangan membuat perubahan besar pada arsitektur tanpa membuat/memperbarui rancangan spesifikasi terlebih dahulu.

---

## 💡 Prinsip Clean Code Agen AI (Clean Code & Robustness Rules)

Sebagai Agen AI pengembang Genesis.id, Anda **WAJIB** mematuhi prinsip-prinsip clean code dan ketahanan sistem (*robustness*) berikut ini secara konsisten di seluruh lapisan sub-proyek (Next.js, NestJS, dan Flutter):

### 1. Strict Type Safety (Anti-`any` & Anti-`dynamic`)
*   **Next.js & NestJS (TypeScript)**: Dilarang keras menulis tipe `any`. Selalu definisikan tipe data, interface, atau gunakan generics secara eksplisit. Aktifkan `"strict": true` pada `tsconfig.json`.
*   **Flutter (Dart)**: Gunakan tipe data spesifik (hindari `dynamic` kecuali saat parsing payload JSON mentah). Selalu nyatakan tipe kembalian fungsi (*return type*) secara eksplisit.

### 2. Pencegahan Kebocoran Memori & Sumber Daya (Resource Disposal)
*   **React/Next.js Hooks**: Setiap kali menggunakan `useEffect` yang mendaftarkan `addEventListener`, mendaftarkan timer (`setInterval`/`setTimeout`), atau meluncurkan animasi (`requestAnimationFrame`), Anda **WAJIB** mengembalikan fungsi pembersihan (*cleanup function*) untuk membatalkannya guna mencegah kebocoran memori.
*   **Flutter Controllers**: Semua objek yang mengimplementasikan pembuangan sumber daya (seperti `TextEditingController`, `ScrollController`, `StreamSubscription`) harus secara eksplisit dibuang (*disposed*) di dalam metode lifecycle `dispose()`.

### 3. Optimalisasi Performa Scroll & Rendering (Smooth Scroll Guarantee)
*   **Offscreen Execution Pause**: Untuk operasi latar belakang yang intensif (seperti looping canvas, pemrosesan frame video, atau animasi terus-menerus), gunakan `IntersectionObserver` di Next.js untuk menjeda proses ketika elemen sedang berada di luar layar (off-screen) agar tidak membebani performa gulir (*scroll*) pengguna.
*   **Passive Listeners**: Di sisi web, jika membuat *event listener* pada scroll, gunakan `{ passive: true }` untuk mencegah hambatan interaksi pada utas utama browser.

### 4. Penanganan Eror yang Aman & User-Friendly (Robust Error Handling)
*   **No Silent Catch**: Jangan pernah menelan eror di dalam blok `catch` kosong. Minimal, cetak dengan logger yang sesuai (`console.error` di Next.js, `Logger` di NestJS, atau `debugPrint`/`talker` di Flutter).
*   **UI Fallbacks**: Gunakan *Error Boundary* (di React) atau `GenesisErrorWidget` (di Flutter) agar aplikasi tidak crash total (*crash to black/red screen*) ketika terjadi kesalahan pada sub-komponen UI.

### 5. Pemisahan Tanggung Jawab (Separation of Concerns - SoC)
*   **Next.js**: Pisahkan logika visual (UI Component) dari logika bisnis/data fetching. Letakkan status kompleks dan pemanggilan API di dalam *Custom Hooks* (seperti React Query/SWR).
*   **NestJS**: Jaga agar *Controller* tetap tipis (hanya mengurusi request, routing, validasi DTO) dan letakkan seluruh logika bisnis di dalam *Service*.
*   **Flutter**: Widget presentasi hanya boleh menangani gambar UI berdasarkan status saat ini. Seluruh status aplikasi, logika bisnis, dan interaksi repositori wajib ditangani oleh BLoC/Cubit.

