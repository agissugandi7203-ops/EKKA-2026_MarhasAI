# Clean Code & Robust Programming Guidelines (Anti-Slip)

Dokumen ini mendefinisikan aturan dan prinsip penulisan kode global di seluruh sub-proyek (NestJS, Next.js, Flutter). Tujuannya adalah membuat kode mudah dipahami, modular, dan meminimalisir bug atau kesalahan logika (anti-slip).

---

## 1. Prinsip Umum Clean Code

### A. SOLID Principles
Setiap modul, kelas, dan fungsi harus mengikuti prinsip SOLID:
1. **Single Responsibility Principle (SRP)**: Sebuah kelas atau fungsi hanya boleh memiliki satu alasan untuk berubah (fokus pada satu tugas).
2. **Open/Closed Principle (OCP)**: Kode harus terbuka untuk ekstensi tetapi tertutup untuk modifikasi (gunakan polimorfisme/interface).
3. **Liskov Substitution Principle (LSP)**: Subclass harus dapat menggantikan superclass-nya tanpa merusak perilaku aplikasi.
4. **Interface Segregation Principle (ISP)**: Lebih baik membuat banyak interface kecil yang spesifik daripada satu interface besar yang memaksa client mengimplementasikan method yang tidak mereka gunakan.
5. **Dependency Inversion Principle (DIP)**: Modul tingkat tinggi tidak boleh bergantung pada modul tingkat rendah. Keduanya harus bergantung pada abstraksi (gunakan Dependency Injection).

### B. DRY (Don't Repeat Yourself) & KISS (Keep It Simple, Stupid)
- Jangan menduplikasi logika bisnis. Buatlah helper, hooks, atau utility global jika kode digunakan di lebih dari 2 tempat.
- Buat kode sesederhana mungkin. Jangan menggunakan teknik pemrograman kompleks (over-engineering) jika solusi sederhana sudah cukup.

---

## 2. Standardisasi Bahasa & Type Safety

### A. Larangan Tipe Data Dinamis (Strict Type-Safety)
- **TypeScript (NestJS & Next.js)**: 
  - **Dilarang keras** menggunakan tipe data `any`. Gunakan tipe data spesifik, `unknown` (jika benar-benar tidak diketahui), atau generics.
  - Aktifkan `"strict": true` di `tsconfig.json`.
- **Dart (Flutter)**:
  - **Dilarang keras** menggunakan tipe data `dynamic` secara bebas. 
  - Selalu definisikan tipe kembalian fungsi secara eksplisit (jangan mengandalkan inferensi implisit untuk fungsi publik).

### B. Validasi Input di Batas Aplikasi (Defensive Programming)
Setiap data yang masuk ke sistem dari luar (request API, input form, input file) harus divalidasi dengan ketat:
- **NestJS Backend**: Gunakan `ValidationPipe` global dengan `class-validator` dan `class-transformer` untuk memvalidasi Body Request DTO.
- **Next.js Frontend**: Gunakan library skema validasi seperti `Zod` bersama React Hook Form untuk memvalidasi input sebelum dikirim ke server.
- **Flutter Mobile**: Manfaatkan `FormBuilder` atau validator bawaan Flutter untuk input UI, dan validasi data JSON dari API menggunakan factory constructor `fromJson()` yang aman.

---

## 3. Penanganan Eror yang Aman (Error Handling)

- **Jangan menelan eror (silent catch)**. Blok `catch` yang kosong dilarang keras. Minimal, log eror tersebut atau teruskan ke Exception Handler.
- **NestJS**: Gunakan Exception Filters global bawaan NestJS (misal `HttpException`, `BadRequestException`) untuk memastikan format response eror ke client selalu konsisten.
- **Next.js & Flutter**: Gunakan konsep Error Boundary di frontend/UI agar aplikasi tidak crash total saat terjadi eror di sub-komponen UI. Tampilkan UI fallback yang ramah pengguna.
- Gunakan tipe data `Result` (atau pustaka pemrograman fungsional seperti `fpdart` untuk Flutter) untuk menangani operasi yang rentan gagal daripada terus-menerus menggunakan `try-catch`.

---

## 4. Struktur Kode & Separation of Concerns (SoC)

### A. NestJS (Backend)
Pemisahan lapisan logika yang ketat:
- **Controller**: Hanya menangani request HTTP, routing, dan validasi DTO tingkat awal. Tidak boleh ada logika bisnis di sini.
- **Service**: Berisi logika bisnis utama, kalkulasi, dan koordinasi data.
- **Repository / Entity**: Menangani akses langsung ke database atau sumber data eksternal.

### B. Next.js (Frontend)
- **Pages/App routing**: Hanya berisi susunan layout halaman dan pemanggilan komponen fitur.
- **Components**: Komponen murni UI yang menerima data lewat props. Hindari memanggil API langsung dari dalam komponen UI dasar.
- **Custom Hooks**: Tempatkan state UI kompleks dan logika fetch API (menggunakan React Query / SWR) di dalam custom hooks.

### C. Flutter (Mobile)
- **Data Layer**: Menangani pemanggilan API (Data Source) dan serialisasi data (Model).
- **Domain Layer**: Berisi Entity murni dan Usecase (proses bisnis mandiri yang tidak bergantung pada framework/library luar).
- **Presentation Layer**: Widget UI yang berinteraksi dengan State Management (BLoC/Cubit, Riverpod, atau ChangeNotifier). Widget hanya boleh bertugas menggambar UI berdasarkan state saat ini.
