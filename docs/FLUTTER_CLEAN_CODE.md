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
> Jangan menulis warna acak (*ad-hoc colors*) di dalam Widget. Selalu gunakan Token Desain dari tema global aplikasi.

*   **Pemisahan Warna**: Semua warna harus diambil dari `Theme.of(context).colorScheme` atau file konfigurasi palet warna global yang disepakati.
*   **Pemisahan Logika UI**: 
    *   Widget harus bersifat *stateless* jika memungkinkan. Jika butuh state, gunakan `BlocBuilder` atau `BlocConsumer` untuk mendengarkan perubahan state dari BLoC.
    *   Fungsi tombol (`onPressed`) hanya boleh mengirim Event ke BLoC (misal: `context.read<AuthBloc>().add(SignInRequested(...))`), tidak boleh memanggil API atau merubah database secara langsung.

---

## 5. Ceklis Sebelum Melakukan Commit / Push
Sebelum mengunggah kode ke GitHub, jalankan perintah berikut di direktori `mobile/` untuk memastikan kualitas kode:
1.  `flutter format .` $\rightarrow$ Merapikan format kode Dart.
2.  `flutter analyze` $\rightarrow$ Memastikan tidak ada warning, lints, atau error kode statis.
