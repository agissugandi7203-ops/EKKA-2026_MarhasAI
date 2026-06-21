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

### C. Forgot Password Page (`/forgot-password`)
- Input: Email
- Tombol: Kirim Kode Verifikasi
- Mengirim email reset via `supabase.auth.resetPasswordForEmail()`

### D. OTP Verification Page (`/otp-verification`)
- Input: 6-digit PIN code
- Auto-submit saat 6 digit terisi
- Countdown timer 60 detik untuk kirim ulang
- Verifikasi via `supabase.auth.verifyOTP(type: recovery)`

### E. Reset Password Page (`/reset-password`)
- Input: Password Baru + Konfirmasi
- Tombol: Simpan Password Baru
- Update via `supabase.auth.updateUser(password: ...)`
- Setelah sukses → navigate ke Login

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
