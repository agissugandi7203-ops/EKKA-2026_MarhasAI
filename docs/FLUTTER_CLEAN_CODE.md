# Panduan Clean Code & Standar Pengembangan Flutter (Genesis.id)

Dokumen ini mendefinisikan standar penulisan kode Dart, arsitektur, dan aturan yang **WAJIB** diikuti oleh setiap developer maupun agen AI dalam mengembangkan aplikasi mobile **Genesis.id**. Tujuannya adalah menjaga kode tetap bersih, modular, dapat diuji (*testable*), dan bebas dari bug.

---

## 1. Aturan Struktur Folder (Clean Architecture + Feature-First)

Kode harus diletakkan berdasarkan modul fitur di bawah folder `lib/features/`, dipisahkan ke dalam tiga lapisan (*layer*) utama:

1.  **Data Layer (`data/`)**:
    *   **`datasources/`**: Hanya menangani request jaringan (pemanggilan API NestJS via Dio atau Supabase SDK).
    *   **`models/`**: Representasi data JSON. Semua properti harus dideklarasikan sebagai `final` (immutable) dan menyertakan constructor `fromJson()` / `toJson()`.
    *   **`repositories/`**: Implementasi konkret dari kontrak interface repositori di domain layer.
2.  **Domain Layer (`domain/`)**:
    *   **`repositories/`**: Interface kontrak data murni. Lapisan ini tidak boleh bergantung pada library HTTP (Dio), database (Supabase), atau framework UI.
    *   **`entities/`**: Objek bisnis inti (jika diperlukan untuk abstraksi model).
3.  **Presentation Layer (`presentation/`)**:
    *   **`bloc/`**: State management menggunakan library `flutter_bloc`. Memproses *Event* untuk menghasilkan *State*.
    *   **`pages/`** / **`widgets/`**: Antarmuka visual (Widget). Lapisan ini **hanya** bertugas merender UI berdasarkan State saat ini. Tidak boleh ada logika bisnis di dalam Widget.

---

## 2. Standar Penulisan Kode Dart (Anti-Slip)

### A. Strict Type Safety (Keamanan Tipe Data)
*   **Dilarang Keras** menggunakan tipe data `dynamic` secara bebas. 
*   Setiap parsing JSON harus segera dikonversi ke class model terdefinisi (misal: `ProfileModel.fromJson(data)`).
*   Semua fungsi publik harus memiliki tipe kembalian (*return type*) yang dideklarasikan secara eksplisit (jangan mengandalkan inferensi tipe implisit).
*   Gunakan tipe data `double` secara konsisten untuk koordinat GPS (`latitude` dan `longitude`).

### B. Immutability (Data Tidak Boleh Diubah Langsung)
*   Semua properti kelas di dalam data model atau BLoC state harus ditandai sebagai `final`.
*   Untuk memodifikasi state atau model, gunakan metode `copyWith(...)` jika kelas memiliki banyak properti.
*   Gunakan package **`equatable`** untuk semua kelas Event dan State di BLoC agar perbandingan objek berbasis nilai (*value-based comparison*) berjalan lancar dan mencegah render ulang UI yang tidak perlu.

---

## 3. Aturan Koneksi Jaringan (Dio Client)

*   **Pemanggilan API NestJS**: Wajib menggunakan **`DioClient`** global dari `lib/core/network/dio_client.dart`.
*   **Otomatisasi Token**: DioClient secara otomatis menyisipkan Supabase JWT Bearer token ke dalam Authorization header. Jangan menulis logika penulisan token secara manual di setiap service pemanggilan.
*   **Supabase Direct Operations**: Untuk autentikasi (login/register) dan operasi langsung ke Supabase, gunakan instance `Supabase.instance.client` melalui `AuthRemoteDataSource`.

---

## 4. Aturan Pembuatan UI (Widget & Styling)

> [!WARNING]
> Jangan menulis warna acak (*ad-hoc colors*) di dalam Widget. Selalu gunakan Token Desain dari design system.

### A. Design System Terpusat
*   **Warna**: Semua warna harus diambil dari `AppColors` (`core/theme/app_colors.dart`). Tidak boleh ada `Color(0xFF...)` di file widget.
*   **Typography**: Gunakan `AppTextStyles` (`core/theme/app_text_styles.dart`). Tidak boleh ada `TextStyle(fontSize: ...)` ad-hoc.
*   **Dekorasi**: Gunakan `AppDecorations` (`core/theme/app_decorations.dart`) untuk shadow, border radius, dan gradient.
*   **Konstanta**: Gunakan `AppConstants` (`core/constants/app_constants.dart`) untuk spacing, radius, dan durasi animasi. Tidak boleh ada magic number.

### B. Widget Reusable
*   Gunakan `GenesisButton` untuk semua tombol (3 varian: primary, secondary, text).
*   Gunakan `GenesisTextField` untuk semua input form (sudah include password toggle).
*   Gunakan `GenesisLoading` untuk loading indicator.
*   Gunakan `GenesisScaffold` untuk scaffold dengan SafeArea dan gradient otomatis.
*   Jangan membuat widget ad-hoc yang duplikasi fungsi widget di atas.

### C. Pemisahan Logika UI
*   Widget harus bersifat *stateless* jika memungkinkan. Jika butuh state, gunakan `BlocBuilder` atau `BlocConsumer`.
*   Fungsi tombol (`onPressed`) hanya boleh mengirim Event ke BLoC, tidak boleh memanggil API langsung.

---

## 5. Aturan Navigasi
*   Seluruh navigasi menggunakan **GoRouter** terpusat di `core/router/app_router.dart`.
*   Path route didefinisikan di `Routes` class — tidak boleh ada string path hardcoded di widget.
*   Gunakan `context.goNamed(Routes.loginName)` atau `context.pushNamed(...)`, bukan `Navigator.push()`.

---

## 6. Aturan Validasi Form
*   Semua validator disimpan di `core/utils/validators.dart`.
*   Validator harus selaras dengan DTO validation di backend NestJS (class-validator).
*   Contoh: password minimal 8 karakter, 1 huruf besar, 1 angka — sama seperti di backend.

---

## 7. Ceklis Sebelum Melakukan Commit / Push
Sebelum mengunggah kode ke GitHub, jalankan perintah berikut di direktori `mobile/`:
1.  `dart format .` → Merapikan format kode Dart.
2.  `flutter analyze` → Memastikan tidak ada warning, lints, atau error kode statis.
3.  `flutter test` → Memastikan semua test case berjalan.
