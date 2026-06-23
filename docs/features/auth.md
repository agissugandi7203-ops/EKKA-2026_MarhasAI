# Fitur: Autentikasi (Auth)

## 1. Deskripsi Bisnis
Modul autentikasi menangani seluruh alur masuk, pendaftaran, dan pemulihan password pengguna Genesis.id. Mendukung login email/password dan Google OAuth.

---

## 2. Alur Data

```
┌─────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
│  Mobile  │ ──→  │ Supabase │ ──→  │   JWT    │ ──→  │  NestJS  │
│  (Auth)  │      │   Auth   │      │  Token   │      │ Backend  │
└─────────┘      └──────────┘      └──────────┘      └──────────┘
     │                                                      │
     └──── DioClient: Bearer <token> ──────────────────────┘

1. Mobile login via Supabase Auth SDK → mendapat JWT token
2. JWT disimpan di Supabase session (otomatis)
3. DioClient interceptor auto-inject Bearer token ke setiap request
4. NestJS AuthGuard verify token via supabase.auth.getUser(token)
```

---

## 3. Halaman Auth (5 Pages)

### A. Login Page (`/login`)
- Input: Email + Password
- Tombol: Masuk, Masuk dengan Google, Lupa Password, Daftar
- Setelah login berhasil:
  - Cek `ProfileRepository.getMyProfile()` → `cityOrDistrict` kosong?
  - Ya → Navigate ke Setup Wizard
  - Tidak → Navigate ke Home

### B. Sign Up Page (`/sign-up`)
- Input: Email + Password + Konfirmasi Password
- Tombol: Daftar, Masuk dengan Google, Sudah punya akun
- Validasi: password min 8 karakter, 1 huruf besar, 1 angka
- Setelah pendaftaran sukses:
  - Memancarkan `SignUpSuccess`.
  - Menampilkan SnackBar informasi (durasi 15 detik) untuk meminta pengecekan **Folder SPAM** email (`emailRedirectTo` diatur ke `genesis://login-callback`).
  - Mengarahkan kembali ke halaman Login (tidak boleh masuk instan tanpa konfirmasi email).

### C. Forgot Password Page (`/forgot-password`)
- Input: Email
- Tombol: Kirim Kode Verifikasi
- Mengirim email reset via `supabase.auth.resetPasswordForEmail()` (dengan `redirectTo: 'genesis://login-callback'`).
- Setelah sukses: Menampilkan SnackBar informasi cek **Folder SPAM** (durasi 15 detik) lalu navigasi ke halaman OTP.

### D. OTP Verification Page (`/otp-verification`)
- Input: 6-digit PIN code (OTP dari email).
- Auto-submit saat 6 digit terisi, memverifikasi via `supabase.auth.verifyOTP(type: recovery)`.
- Menyediakan Countdown timer 60 detik untuk kirim ulang kode.
- **Spotlight Peringatan Spam**: Memuat banner info khusus di halaman OTP yang secara menonjol menyuruh user mengecek **Folder SPAM** karena domain aplikasi baru.
- Dapat juga dipicu secara otomatis jika user mengklik tautan reset password di email (deep-link `passwordRecovery` event akan dideteksi oleh `AuthBloc` untuk memancarkan `OtpVerified` dan melompati input OTP langsung ke form ubah password).

### E. Reset Password Page (`/reset-password`)
- Input: Password Baru + Konfirmasi.
- Tombol: Simpan Password Baru.
- Update password via `supabase.auth.updateUser(password: ...)`.
- Setelah sukses: `AuthBloc` akan langsung mengambil status onboarding pengguna dari `/profiles/me`. Jika pengguna membutuhkan onboarding, ia akan langsung diarahkan ke halaman Setup Wizard (`Routes.setupWelcomeName`), dan jika tidak membutuhkan onboarding, ia akan langsung diarahkan ke halaman Beranda (`Routes.homeName`). Hal ini menghindari proses sign out dan login ulang yang merepotkan.
- **Pencegahan Keterpentalan Screen (Redirect Guard)**: Untuk mencegah user terpental kembali ke halaman login/welcome saat transisi perpindahan halaman ini, `AppRouter` secara khusus memperlakukan state `PasswordResetSuccess` sebagai state terautentikasi (`isAuthenticated`) di dalam redirect guard. Hal ini membuat transisi berjalan instan langsung menuju halaman target tanpa ada kedipan layar login atau welcome.

---

## 4. BLoC State Management

### Events
| Event | Trigger |
|-------|---------|
| `AuthCheckRequested` | App startup |
| `SignInRequested(email, password)` | Tombol Masuk |
| `SignUpRequested(email, password)` | Tombol Daftar |
| `GoogleSignInRequested` | Tombol Google |
| `SignOutRequested` | Tombol Keluar |
| `ForgotPasswordRequested(email)` | Tombol Kirim Kode |
| `VerifyOtpRequested(email, token)` | PIN 6 digit selesai |
| `ResetPasswordRequested(newPassword)` | Tombol Simpan |

### States
| State | Navigasi |
|-------|----------|
| `AuthInitial` | — |
| `AuthLoading` | Show spinner |
| `Authenticated(user, needsOnboarding)` | Home / Setup Wizard |
| `Unauthenticated` | Login |
| `AuthFailure(errorMessage)` | Show snackbar error |
| `PasswordResetEmailSent(email)` | → OTP Page |
| `OtpVerified` | → Reset Password Page |
| `PasswordResetSuccess` | → Login Page |

---

## 5. Clean Architecture Layer

```
auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart    # Supabase Auth SDK calls
│   └── repositories/
│       └── auth_repository_impl.dart       # Implementasi konkret
├── domain/
│   └── repositories/
│       └── auth_repository.dart            # Interface abstraksi (DIP)
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                  # Event handlers
    │   ├── auth_event.dart                 # 8 events
    │   └── auth_state.dart                 # 8 states
    ├── pages/
    │   ├── login_page.dart
    │   ├── sign_up_page.dart
    │   ├── forgot_password_page.dart
    │   ├── otp_verification_page.dart
    │   └── reset_password_page.dart
    └── widgets/
        ├── auth_header.dart                # Logo + title + subtitle
        ├── social_sign_in_button.dart      # Google Sign-In button
        └── auth_footer_link.dart           # "Belum punya akun? Daftar"
```

---

## 6. Kontrak API (Backend NestJS)

Auth di backend hanya memiliki 1 endpoint untuk verifikasi token:

### `GET /auth/verify`
- **Header**: `Authorization: Bearer <supabase-jwt-token>`
- **Response (200)**:
  ```json
  {
    "authenticated": true,
    "message": "Token authentication successful",
    "user": {
      "id": "uuid-string-user",
      "email": "user@example.com"
    }
  }
  ```

> **Catatan**: Login/Register/Reset Password semua dilakukan langsung ke Supabase Auth SDK. Backend NestJS hanya memverifikasi JWT token untuk endpoint-endpoint yang dilindungi.

---

## 7. Validasi Form (Selaras dengan Backend)

| Field | Rule | Referensi Backend |
|-------|------|-------------------|
| Email | RFC 5322 regex | class-validator `@IsEmail()` |
| Password | Min 8 char, 1 uppercase, 1 digit | `@MinLength(8)` |
| Username | `^[a-zA-Z0-9_]+$`, 3-30 char | `/^[a-zA-Z0-9_]+$/` regex |
| Full Name | 2-100 char | `@MinLength(2)`, `@MaxLength(100)` |

---

## 8. Panduan Konfigurasi Supabase Auth (Dashboard)

Untuk memastikan alur autentikasi email, OTP, dan pemulihan password berjalan lancar di aplikasi Flutter dan Next.js, Anda wajib mengonfigurasi pengaturan berikut di **Supabase Console**:

### A. Konfigurasi Provider Email
1. Buka dashboard proyek Supabase Anda.
2. Navigasi ke menu **Authentication** -> **Providers** -> klik **Email**.
3. Pastikan konfigurasi diatur sebagai berikut:
   *   **Enable Signup**: `true` (Mengizinkan pendaftaran akun baru).
   *   **Confirm Email**: `true` (Wajib memverifikasi email sebelum login) atau `false` (Bisa langsung login setelah daftar).
   *   **Secure email change**: `true`.
   *   **Double Confirm Email Change**: `true`.

### B. Konfigurasi Layanan SMTP (Wajib untuk Produksi)
Secara default, Supabase membatasi pengiriman email maksimal **3 email per jam** (menggunakan SMTP internal bawaan). Anda wajib memasang SMTP kustom untuk produksi (seperti Gmail SMTP, Resend, SendGrid, atau Mailgun):
1. Navigasi ke **Authentication** -> **SMTP Settings**.
2. Nyalakan toggle **Enable Custom SMTP**.
3. Isi parameter berikut (Contoh menggunakan Gmail SMTP):
   *   **Sender Email**: `no-reply@genesisHub.web.id` (Sesuaikan dengan domain)
   *   **Sender Name**: `Genesis.id Support`
   *   **Host**: `smtp.gmail.com` (Atau SMTP provider Anda)
   *   **Port**: `587` (Gunakan TLS) atau `465` (SSL)
   *   **Username**: Alamat email pengirim
   *   **Password**: *App Password* khusus yang dibuat dari Google Account Settings (bukan password email biasa).

### C. Konfigurasi Redirect URL (Deep Linking)
Saat pengguna melakukan klik pada link verifikasi email, Magic Link, atau tautan reset password di handphone, Supabase harus tahu ke mana ia harus mengarahkan kembali pengguna agar masuk ke dalam aplikasi Flutter:
1. Navigasi ke **Authentication** -> **URL Configuration**.
2. **Site URL**: `https://genesisHub.web.id` (Domain utama frontend Next.js).
3. **Redirect URLs**: Tambahkan redirect URL untuk schema deep link Flutter Anda:
   *   `genesis://login-callback` (Skema deep link terpusat untuk seluruh callback autentikasi aplikasi mobile).
   *   `https://genesisHub.web.id/reset-password` (Bila membuka web admin).

### D. Konfigurasi Keamanan & Durasi OTP
1. Navigasi ke **Authentication** -> **Security**.
2. **Email OTP Expiry**: Set ke `600` detik (10 menit) agar masa aktif OTP tidak terlalu singkat.
3. **Minimum Token Length**: Set ke `6` digit (Sesuai dengan `otp_verification_page.dart` yang menangani kode 6-angka).
4. Klik **Save**.
5. **Konfigurasi Reset Password Email Template**: Pada menu **Authentication** -> **Email Templates** -> **Reset Password**, pastikan isi email mengirimkan kode 6-angka (menggunakan variable `{{ .Token }}`) jika Anda menginginkan user menginput OTP secara manual, atau menggunakan `{{ .ConfirmationURL }}` yang mengarah to `genesis://login-callback` untuk deep-linking otomatis ke aplikasi.

---

## 9. Visual & UX Enhancements

Untuk memberikan pengalaman pengguna yang sangat premium dan bebas kendala visual (anti-annoyance), kami menerapkan optimasi berikut:

### A. Penanganan Keyboard & Posisi Tombol Aksi (Accept Button)
*   **Masalah**: Tombol aksi utama (seperti "Confirm", "Create Account", "Selesai & Mulai!") terangkat naik mengikuti tinggi keyboard ketika user sedang memfokuskan kursor pada kolom input teks. Hal ini merusak estetika antarmuka iOS/premium.
*   **Solusi**: Scaffolds pada seluruh halaman autentikasi (`LoginPage`, `SimpleSignInPage`, `SignUpPage`, `ForgotPasswordPage`, `OtpVerificationPage`, `ResetPasswordPage`) serta halaman wizard onboarding (`SetupProfilePage`) diatur dengan `resizeToAvoidBottomInset: false`. Hal ini menjaga posisi tombol tetap melekat rapi di bagian bawah layar tanpa ikut bergeser ke atas keyboard.

### B. Pencegahan Pemotongan Pesan Validasi (Input Error Text Wrapping)
*   **Masalah**: Pesan kesalahan validasi (seperti pemberitahuan aturan password harus mengandung huruf besar/angka) terpotong di ujung layar (cropped/truncated) karena pembatasan baris bawaan Flutter (`errorMaxLines` default bernilai 1).
*   **Solusi**:
    *   Mengatur properti `errorMaxLines: 5` secara terpusat pada `InputDecorationTheme` di dalam berkas [app_theme.dart](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/mobile/lib/core/theme/app_theme.dart).
    *   Menerapkan batas toleransi pembungkusan `errorMaxLines: 5` di seluruh dekorasi input kustom (`_buildRoundedField` pada seluruh halaman auth dan `GenesisTextField` untuk profil). Ini menjamin pesan kesalahan yang panjang akan otomatis terbungkus (wrap) menjadi beberapa baris secara elegan dan memiliki pembatas margin yang konsisten dari tepi layar.


