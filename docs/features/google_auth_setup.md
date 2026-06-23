# Panduan Lengkap Konfigurasi Google Sign-In dengan Supabase & Flutter

Dokumen ini menjelaskan alur kerja, tipe antarmuka, dan langkah-langkah detail untuk mengonfigurasi **Google Sign-In** menggunakan **Supabase Auth** pada aplikasi mobile **Genesis.id** (Flutter).

---

## 1. Alur & Tampilan Login Google (Web Redirect vs Native Pop-up)

Proyek Genesis.id menggunakan metode **Native Google Sign-In (Pop-up)**. 

### **Apa bedanya dengan Web Redirect?**
*   **Web Redirect**: Aplikasi mengarahkan user keluar dari aplikasi menuju browser web Chrome/Safari untuk masuk, lalu mengarahkan kembali (redirect) via deep link. Ini kurang mulus dan sering membuat pengguna bingung.
*   **Native Pop-up (Digunakan Proyek Ini)**: Aplikasi membuka dialog bottom-sheet/pop-up bawaan OS Android/iOS untuk memilih akun Google yang sudah terdaftar di handphone. Pengguna cukup mengetuk akun mereka tanpa mengetik ulang sandi, sangat mulus dan terasa premium.

### **Bagaimana Cara Kerjanya?**
```
┌──────────────┐         ┌────────────────┐         ┌──────────────┐
│ Flutter App  │  ─────→  │ Google Pop-up  │  ─────→  │ Google Auth  │
│ (User Clicks)│         │ (Account Select│         │ (ID Token)   │
└──────────────┘         └────────────────┘         └──────────────┘
       ▲                                                           │
       │                                                           ▼
┌──────────────┐         ┌────────────────┐         ┌──────────────┐
│ Authenticated│  ←─────  │ Supabase Auth  │  ←─────  │ Kirim Token  │
│   Session    │         │ (Verify Token) │         │   ke App     │
└──────────────┘         └────────────────┘         └──────────────┘
```
1. Aplikasi Flutter meminta izin akun menggunakan plugin `google_sign_in`.
2. Pengguna memilih akun pada dialog **Pop-up**.
3. Google mengembalikan **ID Token** dan **Access Token** ke aplikasi Flutter.
4. Aplikasi Flutter mengirimkan **ID Token** tersebut ke **Supabase** via `signInWithIdToken()`.
5. Supabase memverifikasi keaslian token ke server Google, jika valid, Supabase membuat sesi pengguna baru dan mengembalikan JWT Token.

---

## 2. Langkah 1: Konfigurasi di Google Cloud Console

Anda harus mendaftarkan aplikasi Anda di Google Cloud Console untuk mendapatkan kredensial OAuth.

### **A. Buat OAuth Consent Screen**
1. Buka [Google Cloud Console](https://console.cloud.google.com/).
2. Pastikan Anda berada di proyek yang benar (misalnya `arief-fajar`).
3. Buka menu **APIs & Services** > **OAuth consent screen**.
4. Pilih User Type: **External** -> klik **Create**.
5. Isi data aplikasi:
   * **App name**: `Genesis.id`
   * **User support email**: Email admin Anda.
   * **Developer contact information**: Email admin Anda.
6. Klik **Save and Continue** hingga selesai (biarkan scopes bawaan).

### **B. Buat Client ID: Web Application (Paling Penting!)**
Supabase membutuhkan Client ID bertipe **Web Application** agar dapat bertindak sebagai mediator pemverifikasi token dari Google.
1. Masuk ke **APIs & Services** > **Credentials**.
2. Klik tombol **Create Credentials** di bagian atas -> pilih **OAuth client ID**.
3. **Application type**: Pilih **Web application**.
4. **Name**: `Genesis Supabase Web Client`.
5. **Authorized redirect URIs**: Masukkan URL redirect dari Supabase Anda (bisa didapatkan di Supabase Dashboard -> Auth -> Providers -> Google -> *Redirect URL*). Contoh:
   `https://[PROJECT-ID].supabase.co/auth/v1/callback`
6. Klik **Create**.
7. **Catat & Simpan**: 
   * **Client ID** (contoh: `123456789-abcde.apps.googleusercontent.com`)
   * **Client Secret** (contoh: `GOCSPX-xxxxxxxxx`)

### **C. Buat Client ID: Android Client**
Agar dialog pop-up dapat muncul di Android saat fase pengembangan (development) dan produksi (production).
1. Klik **Create Credentials** > **OAuth client ID**.
2. **Application type**: Pilih **Android**.
3. **Name**: `Genesis Android Debug`.
4. **Package name**: Masukkan package ID aplikasi Flutter Anda. Sesuai konfigurasi gradle, isikan: **`com.example.mobile`**.
5. **SHA-1 certificate fingerprint**: Masukkan fingerprint kunci debug laptop Anda (lihat cara mendapatkannya di bawah).
6. Klik **Create**.

> [!TIP]
> **Cara Mendapatkan SHA-1 Fingerprint (Debug Keystore)**:
> Buka PowerShell atau Command Prompt, jalankan perintah berikut:
> ```bash
> keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore"
> ```
> *Password default keystore adalah:* **`android`**
> Copy deretan kode SHA1 yang dihasilkan (contoh: `5E:8F:16:C2:...`).

---

## 3. Langkah 2: Konfigurasi di Supabase Console

Setelah mendapatkan kredensial dari GCP Console, masukkan data tersebut ke Supabase agar Supabase dapat mengenali login dari aplikasi Anda.

1. Buka [Supabase Dashboard](https://supabase.com/dashboard).
2. Masuk ke menu **Authentication** > **Providers** > klik **Google**.
3. Atur konfigurasi berikut:
   * **Enable Google Provider**: Nyalakan toggle (**ON**).
   * **Client ID (for OAuth)**: Masukkan **Client ID** dari langkah **Web Application** di atas.
   * **Client Secret (for OAuth)**: Masukkan **Client Secret** dari langkah **Web Application** di atas.
   * **Authorized Client IDs**: Masukkan **Client ID Web Application** (sama dengan kolom Client ID di atas). 
4. Klik **Save**.

---

## 4. Langkah 3: Konfigurasi di Sisi Flutter (Klien)

Karena Anda menggunakan Native Login, Anda perlu menyelaraskan konfigurasi di Flutter.

### **A. Pengaturan Android (`google-services.json`)**
Untuk mengaktifkan layanan Google Sign-In secara penuh di Android:
1. Buka kembali halaman GCP Credentials.
2. Di baris **Android Client ID** yang telah Anda buat, klik tombol unduh (**Download JSON**) di sebelah kanan.
3. Ubah nama file yang diunduh menjadi **`google-services.json`**.
4. Pindahkan file tersebut ke direktori proyek Flutter Anda di:
   `mobile/android/app/google-services.json`

### **B. Pengaturan iOS (Jika Diperlukan)**
Jika Anda menguji di iOS Simulator / Device:
1. Buat **OAuth client ID** bertipe **iOS** di Google Cloud Console menggunakan Bundle ID aplikasi iOS Anda.
2. Unduh file plist-nya, ubah nama menjadi `GoogleService-Info.plist`, dan masukkan ke folder `ios/Runner/` via Xcode.
3. Di file `AuthRemoteDataSourceImpl` pada baris inisialisasi `GoogleSignIn`, Anda perlu memasukkan parameter `clientId` yang merujuk pada Client ID iOS Anda:
   ```dart
   final GoogleSignIn googleSignIn = GoogleSignIn(
     clientId: 'CLIENT-ID-IOS-ANDA.apps.googleusercontent.com',
     scopes: ['email'],
   );
   ```

---

## 5. Ringkasan Checklist Kredensial Google Auth

| Jenis Kredensial | Dibuat Di | Digunakan Di | Fungsi Utama |
| :--- | :--- | :--- | :--- |
| **OAuth Consent Screen** | GCP Console | Seluruh Project | Mengonfigurasi nama & logo aplikasi saat dialog login muncul. |
| **Web Client ID** | GCP Console | Supabase Console | Digunakan oleh Supabase untuk memverifikasi ID Token yang dikirim dari handphone. |
| **Android Client ID + SHA-1** | GCP Console | Google Internal (GCP) | Mendaftarkan tanda tangan (keystore) aplikasi agar Google mengizinkan pop-up muncul di Android. |
| **google-services.json** | GCP Console | `mobile/android/app/` | Berisi data konfigurasi project Google agar SDK Android mengenali API Google. |
