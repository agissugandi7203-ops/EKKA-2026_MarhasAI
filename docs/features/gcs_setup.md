# Panduan Lengkap Konfigurasi Google Cloud Storage (GCS) & Cloud Vision API
Dokumen ini menyajikan langkah-langkah praktis dan detail dari awal hingga akhir untuk melakukan setup Google Cloud Storage (GCS) dan Google Cloud Vision API pada proyek **Genesis.id**. Ikuti panduan ini agar integrasi Fitur 3 (Pelaporan Spasial dan Sensor Gambar PII) berjalan lancar tanpa kendala izin akses.

---

## 1. Persiapan Proyek Google Cloud Platform (GCP)

Jika Anda belum memiliki proyek GCP, ikuti langkah berikut:
1. Buka [Google Cloud Console](https://console.cloud.google.com/).
2. Di bagian atas halaman, klik menu drop-down proyek lalu klik **New Project**.
3. Beri nama proyek Anda (misal: `genesis-hub-project`) dan klik **Create**.
4. Catat **Project ID** Anda (misalnya: `genesis-hub-project-456712`). Nilai ini akan dimasukkan ke variabel `GCS_PROJECT_ID` di file `.env`.

---

## 2. Mengaktifkan API yang Dibutuhkan

Fitur pelaporan membutuhkan dua layanan utama dari Google Cloud, yaitu **Cloud Storage** (untuk menyimpan gambar) dan **Cloud Vision API** (untuk mendeteksi wajah & plat nomor guna penyensoran PII).

1. Pada kolom pencarian di bagian atas GCP Console, ketik **Cloud Storage API**. Pilih produk tersebut dan klik **Enable** (jika belum aktif secara bawaan).
2. Kembali ke kolom pencarian, ketik **Cloud Vision API**. Klik produk tersebut dan klik **Enable**.

---

## 3. Membuat & Mengonfigurasi Storage Bucket

Bucket adalah wadah utama tempat foto laporan akan disimpan secara cloud.

1. Buka menu **Cloud Storage** > **Buckets** pada panel navigasi kiri, lalu klik **Create**.
2. **Name your bucket**: Masukkan nama bucket yang unik secara global (contoh: `genesis-id-reports`). Catat nama ini untuk variabel `GCS_BUCKET_NAME` di file `.env`.
3. **Choose where to store your data**:
   * Pilih **Region**.
   * Pilih **`asia-southeast2` (Jakarta)** agar proses upload dan download foto memiliki latensi yang sangat rendah untuk pengguna di Indonesia.
4. **Choose a storage class**: Pilih **Standard** (pilihan terbaik untuk data yang sering diakses).
5. **Choose how to control access to objects**:
   * Pilih **Uniform** (direkomendasikan oleh Google) agar semua objek di dalam bucket memiliki aturan keamanan yang seragam.
   * **PENTING**: **Hapus centang (uncheck)** pada pilihan *"Enforce public access prevention on this bucket"*. Jika pilihan ini dicentang, Anda tidak akan bisa membuat foto laporan dapat diakses secara publik.
6. Klik **Create**.

---

## 4. Mengatur Hak Akses Publik Baca (`allUsers`)

Agar aplikasi Flutter dan Dashboard Admin Next.js dapat menampilkan foto laporan langsung melalui tautan URL (misal: `https://storage.googleapis.com/genesis-id-reports/nama_file.jpg`), bucket harus diberi izin agar bisa dibaca secara publik oleh siapapun.

> [!WARNING]
> Pengaturan ini hanya memberikan izin **Membaca (Read-Only)** kepada publik. Publik **tidak** diberikan hak akses menulis, memodifikasi, atau menghapus file di dalam bucket.

Langkah konfigurasi:
1. Masuk ke halaman detail bucket yang baru Anda buat (`genesis-id-reports`).
2. Klik tab **Permissions** di bagian atas.
3. Klik tombol **Grant Access**.
4. Di bagian **New principals**, ketik: `allUsers` (pastikan mengetik persis seperti ini).
5. Di bagian **Select a role**, cari dan pilih: **`Cloud Storage`** > **`Storage Object Viewer`**.
6. Klik **Save**.
7. Muncul konfirmasi peringatan keamanan bahwa bucket akan dapat diakses secara publik, klik **Allow Public Access**.

Sekarang, setiap file yang diunggah ke bucket ini secara otomatis dapat diakses oleh publik menggunakan URL format:
`https://storage.googleapis.com/[NAMA_BUCKET]/[NAMA_FILE]`

---

## 5. Membuat Kunci Akses Server (Service Account JSON)

Backend NestJS berjalan di server tersendiri dan membutuhkan kredensial khusus berbentuk file `.json` untuk mengunggah file ke bucket GCS Anda.

1. Buka menu **IAM & Admin** > **Service Accounts** pada navigasi GCP.
2. Klik tombol **Create Service Account** di bagian atas.
3. **Service account details**:
   * Service account name: `genesis-backend-storage`
   * Klik **Create and Continue**.
4. **Grant this service account access to project** (Pemberian Peran):
   * Klik drop-down role, cari dan pilih: **`Cloud Storage`** > **`Storage Object Admin`** (peran ini memberikan hak penuh bagi backend untuk mengunggah, memperbarui, dan menghapus gambar laporan).
   * Klik **Continue** lalu **Done**.
5. Setelah service account berhasil dibuat, cari email service account tersebut di daftar (`genesis-backend-storage@...`).
6. Klik pada email service account tersebut untuk membuka pengaturannya, lalu pilih tab **Keys** di bagian atas.
7. Klik tombol **Add Key** > **Create new key**.
8. Pilih format **JSON** lalu klik **Create**.
9. File rahasia berformat `.json` akan otomatis diunduh ke komputer Anda. 

---

## 6. Integrasi ke Kode Backend Proyek

Setelah file JSON terunduh, integrasikan ke dalam codebase NestJS Anda dengan aman:

1. Buat folder bernama `secrets` di dalam direktori `backend` proyek Anda (jika belum ada).
2. Pindahkan file JSON kredensial yang baru diunduh ke dalam folder tersebut dan ubah namanya menjadi `gcs-key.json`.
3. Jalur file ini akan menjadi `backend/secrets/gcs-key.json`.

> [!CAUTION]
> **KEAMANAN UTAMA**: Pastikan folder `secrets/` atau file `*.json` di dalamnya terdaftar di file `backend/.gitignore` Anda. Jangan pernah mengunggah kunci service account ini ke GitHub karena siapa saja yang mendapatkan file ini dapat memanipulasi penyimpanan cloud Anda.

---

## 7. Pengisian File `.env` Backend

Buka berkas `backend/.env` Anda dan isi variabel berikut menggunakan data yang telah dikumpulkan:

```env
# Kredensial Google Cloud Storage (GCS)
GCS_PROJECT_ID=genesis-hub-project-456712
GCS_BUCKET_NAME=genesis-id-reports
GCS_KEY_FILE_PATH=secrets/gcs-key.json
```

---

## 8. Ringkasan & Checklist Keamanan

| Parameter | Pengaturan yang Direkomendasikan | Alasan Keamanan / Fungsional |
| :--- | :--- | :--- |
| **GCS Bucket Region** | `asia-southeast2` (Jakarta) | Latensi terendah untuk target pengguna di Indonesia. |
| **Access Prevention** | Off (Dinonaktifkan) | Wajib agar file gambar laporan dapat diakses melalui URL internet publik. |
| **Access Control** | Uniform | Memudahkan pengelolaan hak akses berskala besar tanpa perlu set ACL per file individu. |
| **allUsers Role** | `Storage Object Viewer` | Hanya mengizinkan publik membaca gambar (`GET`). Tidak bisa mengunggah atau menghapus data. |
| **Backend Service Account Role** | `Storage Object Admin` | Mengizinkan server backend melakukan upload, edit, dan delete file laporan secara terprogram. |
| **Penyimpanan File Key JSON** | Di dalam folder `backend/secrets/` | Harus dimasukkan ke dalam `.gitignore` untuk mencegah kebocoran kredensial di repositori publik. |

---

## 9. Mengatasi Kebijakan Organisasi GCP (`iam.disableServiceAccountKeyCreation`)

Jika Anda melihat pesan error berikut saat mencoba mengunduh kunci JSON Service Account:
> *Enforced Organization Policies IDs: iam.disableServiceAccountKeyCreation. Possible Causes: Your Organization Policy Administrator enforced the Organization Policy to prevent security incidents related to Service Account keys.*

Artinya, administrator organisasi Google Cloud Anda mengaktifkan kebijakan keamanan yang melarang pembuatan file kunci JSON lokal.

Ada **dua cara** untuk menyelesaikannya:

### Solusi A: Menonaktifkan Kebijakan Keamanan (Jika Anda adalah Admin/Pemilik Proyek)
Jika akun Anda memiliki hak sebagai **Organization Policy Administrator** (`roles/orgpolicy.policyAdmin`) di Google Cloud:

1. Pada navigasi sebelah kiri di GCP Console, cari dan pilih **IAM & Admin** > **Organization Policies**.
2. Di kolom pencarian, cari kebijakan: **`Disable service account key creation`** (atau ID constraint: **`constraints/iam.disableServiceAccountKeyCreation`**).
3. Klik pada kebijakan tersebut untuk membukanya, lalu klik tombol **Edit Policy** di bagian atas.
4. Pada bagian **Policy values**, pilih **Customize**.
5. Pada tab rule yang ada, ubah status aturan tersebut menjadi **Off** (Nonaktif). Ini akan mengizinkan pembuatan kunci Service Account.
6. Klik **Save**. 
7. Tunggu sekitar 1–2 menit, kemudian silakan ulangi langkah pembuatan kunci JSON Service Account pada **Langkah 5** di atas.

---

### Solusi B: Autentikasi Tanpa File JSON Key (Bypass & Paling Direkomendasikan)
Jika Anda tidak bisa mengubah kebijakan organisasi di atas, Anda tidak perlu mengunduh file JSON secara lokal. Google Cloud SDK mendukung autentikasi asinkronus menggunakan **Application Default Credentials (ADC)**.

#### **1. Untuk Pengujian Lokal (Development)**
Alih-alih menyalin berkas JSON key, Anda dapat masuk ke GCP langsung dari komputer development Anda:
1. Pasang **Google Cloud CLI (gcloud)** di komputer Anda jika belum ada.
2. Buka terminal/PowerShell, jalankan perintah masuk berikut:
   ```bash
   gcloud auth application-default login
   ```
3. Browser akan terbuka dan meminta Anda masuk menggunakan akun Google Cloud yang memiliki akses ke proyek tersebut.
4. Setelah berhasil masuk, Google SDK secara otomatis menyimpan token akses di komputer Anda.
5. Pada file `backend/.env`, Anda dapat **mengosongkan** atau menghapus baris `GCS_KEY_FILE_PATH`. Library Google Cloud Storage di Node.js akan otomatis menggunakan autentikasi ADC tersebut tanpa perlu membaca file JSON!

#### **2. Untuk Lingkungan Produksi (Deployment di Cloud Run)**
Saat Anda mendeploy backend NestJS ke Google Cloud Run:
1. Anda **tidak perlu mengunggah file JSON**.
2. Masuk ke konfigurasi deployment **Cloud Run Service** Anda.
3. Di tab **Security** > Bagian **Service Account**, pilih Service Account yang telah Anda buat di **Langkah 5** (`genesis-backend-storage@...`).
4. Dengan cara ini, container backend Anda secara otomatis mewarisi seluruh izin akses Service Account tersebut untuk membaca/menulis ke GCS secara langsung tanpa konfigurasi file kunci tambahan di `.env`.

