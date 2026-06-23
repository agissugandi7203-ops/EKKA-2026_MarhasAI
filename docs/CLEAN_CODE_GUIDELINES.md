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

### A. Arsitektur Error Flutter (Implementasi Genesis.id)
Aplikasi Flutter Genesis.id sudah menerapkan penanganan error berlapis:

1. **Global Error Catcher** (`main.dart`):
   - `runZonedGuarded` untuk uncaught errors
   - `FlutterError.onError` untuk framework errors
   - `PlatformDispatcher.instance.onError` untuk async Dart errors
   - Custom `ErrorWidget.builder` → `GenesisErrorWidget` (menggantikan Red Screen of Death)

2. **Hierarki Exception** (`core/errors/app_exception.dart`):
   - Sealed class `AppException` dengan subclass: `NetworkException`, `ServerException`, `AuthException`, `DeviceException`, `UnexpectedException`
   - Setiap exception punya pesan ramah pengguna berbahasa Indonesia

3. **Error Mapper** (`core/errors/error_handler.dart`):
   - `ErrorHandler.handle()` mengkonversi `DioException`, `SocketException`, `FormatException`, `TypeError` ke `AppException`
   - Mapping HTTP status: 400→BadRequest, 401→SessionExpired, 403→Forbidden, 404→NotFound, 429→RateLimited, 500→InternalError, 503→Maintenance

4. **Repository Layer**: Semua 4 repo wrap operasi dengan `try-catch` + `ErrorHandler.handle`

5. **BLoC Layer**: 3 BLoC (`AuthBloc`, `ReportsBloc`, `ChatBloc`) menggunakan `ErrorHandler.handle` untuk pesan error user-friendly

6. **UI Presentation** (`core/widgets/genesis_error_widget.dart`):
   - `GenesisErrorWidget` — Fullscreen error dengan ikon kontekstual & tombol retry
   - `GenesisSnackBar` extension pada `BuildContext`:
     - `context.showErrorSnackBar(msg)` — Merah, ikon error
     - `context.showSuccessSnackBar(msg)` — Hijau emerald, ikon check
     - `context.showWarningSnackBar(msg)` — Kuning warning, ikon warning
     - `context.showInfoSnackBar(msg)` — Navy blue, ikon info

7. **AuthListenerWrapper** (`core/widgets/auth_listener_wrapper.dart`):
   - Widget DRY menggantikan pola `BlocListener<AuthBloc, AuthState>` duplikat di 5+ halaman

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
- **Data Layer**: Menangani pemanggilan API (Data Source) dan serialisasi data (Model). Semua operasi dibungkus `try-catch` + `ErrorHandler.handle`.
- **Domain Layer**: Berisi Entity murni dan Usecase (proses bisnis mandiri yang tidak bergantung pada framework/library luar).
- **Presentation Layer**: Widget UI yang berinteraksi dengan State Management (BLoC/Cubit). Widget hanya boleh bertugas menggambar UI berdasarkan state saat ini. Error ditampilkan via `GenesisSnackBar` extension.

---

## 5. Memory Safety & Null Safety (Flutter)

- **TextEditingController**: Selalu di-dispose di `dispose()` lifecycle. Untuk dialog, gunakan `.then()` callback untuk dispose.
- **Cubit/BLoC Scoping**: Scope ke `ShellRoute` lokal jika lifecycle terbatas (contoh: `SetupCubit` hanya aktif selama 4 halaman setup wizard).
- **Null Safety Defensive**: Model `fromJson()` gunakan fallback value untuk field nullable (`createdAt ?? ''`).
- **Safe Cast**: Route `extra` parameter di-cast secara aman (`extra as String? ?? ''`) untuk mencegah `TypeError`.
- **Relative Imports**: Gunakan path relatif (`../`), bukan `package:mobile/...`, untuk import internal.

