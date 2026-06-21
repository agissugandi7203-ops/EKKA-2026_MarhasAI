# Panduan Integrasi API Dashboard Admin (Next.js)

Dokumen ini adalah tutorial dan panduan referensi cepat untuk tim Frontend (Next.js) dalam mengintegrasikan Dashboard Admin dengan Backend NestJS. Dokumen ini menjelaskan semua API yang tersedia untuk Administrator, format data request/response, serta cara melakukan otorisasi (RBAC).

---

## 1. Otorisasi & Peran (RBAC)

Dashboard Admin **hanya dapat diakses** oleh pengguna dengan peran (`role`) `'admin'`. Semua endpoint admin dilindungi oleh `AuthGuard` dan `RolesGuard`.

*   **Header Wajib**: 
    Setiap request ke backend (kecuali halaman login/auth Supabase) wajib menyertakan token JWT aktif milik admin:
    `Authorization: Bearer <JWT_TOKEN_SUPABASE>`
*   **Pengecekan Peran**:
    Pastikan setelah admin login melalui Supabase Auth di Next.js, Anda memeriksa kolom `role` di profil pengguna (`GET /profiles/me`). Jika nilainya bukan `'admin'`, tolong blokir akses ke panel dashboard.

---

## 2. Modul 1: Manajemen Pengguna (Profiles)

Admin memiliki kendali penuh atas daftar warga (citizen) di platform.

### A. Mendapatkan Semua Profil Pengguna
Mengambil semua daftar warga terdaftar beserta status level/XP mereka untuk monitoring tabel.
*   **Method & Path**: `GET /profiles`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": "4b68db6e-219d-4e9b-b0b2-29ee1a67a84c",
        "username": "citizen_peduli",
        "full_name": "Budi Santoso",
        "avatar_url": "https://...",
        "province": "DKI Jakarta",
        "city_or_district": "Kota Jakarta Pusat",
        "xp": 350,
        "level": 1,
        "report_count": 3,
        "current_streak": 2,
        "last_report_date": "2026-06-20",
        "role": "citizen",
        "created_at": "2026-06-20T08:00:00.000Z",
        "updated_at": "2026-06-21T09:00:00.000Z"
      }
    ]
    ```

### B. Menyesuaikan Status Gamifikasi Pengguna (Koreksi XP/Level)
Digunakan jika admin ingin mengoreksi XP warga secara manual (misalnya memberikan penalti atas laporan palsu).
*   **Method & Path**: `PATCH /profiles/:id/gamification`
*   **Request Body (JSON)**:
    ```json
    {
      "xp": 1200,
      "level": 2,
      "current_streak": 5
    }
    ```
*   **Response (200 OK)**: Mengembalikan objek profil ter-update lengkap.

### C. Menghapus Akun Pengguna Permanen
Menghapus warga dari database dan auth server Supabase (cascade delete).
*   **Method & Path**: `DELETE /profiles/:id`
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "message": "User with ID uuid-string has been successfully deleted"
    }
    ```

---

## 3. Modul 2: Manajemen Lencana (Badges)

Admin dapat memantau katalog lencana serta memberikan/mencabut lencana milik warga secara manual.

### A. Mendapatkan Katalog Lencana
Mengambil semua lencana yang ada di platform untuk ditampilkan di halaman pengaturan lencana.
*   **Method & Path**: `GET /badges`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": "b1e9c201-9a7f-4318-9104-d4b9c1d68369",
        "code": "first_report",
        "name": "Lapor Pertama",
        "description": "Diberikan saat berhasil mengunggah laporan pertama.",
        "icon_url": "https://..."
      }
    ]
    ```

### B. Memberikan Lencana ke Warga
*   **Method & Path**: `POST /badges/award`
*   **Request Body (JSON)**:
    ```json
    {
      "userId": "4b68db6e-219d-4e9b-b0b2-29ee1a67a84c",
      "badgeCode": "first_report"
    }
    ```
*   **Response (201 Created)**:
    ```json
    {
      "success": true,
      "message": "Badge first_report awarded successfully"
    }
    ```

### C. Mencabut Lencana Warga
*   **Method & Path**: `DELETE /badges/revoke`
*   **Request Body (JSON)**:
    ```json
    {
      "userId": "4b68db6e-219d-4e9b-b0b2-29ee1a67a84c",
      "badgeCode": "first_report"
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "message": "Badge first_report revoked successfully"
    }
    ```

---

## 4. Modul 3: Manajemen Laporan Lingkungan (Reports)

Admin bertugas memantau seluruh laporan masalah lingkungan dari warga, menyetujui (`approved`), menolak (`rejected`), atau memindahkannya ke antrean review manual (`pending_human`).

### A. Mendapatkan Semua Laporan Lingkungan
Mengambil seluruh daftar laporan spasial untuk dirender pada peta interaktif dashboard maupun tabel laporan.
*   **Method & Path**: `GET /reports`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": "7a752b09-5a5f-4a37-b6e5-23091176b6d2",
        "reporter_id": "4b68db6e-219d-4e9b-b0b2-29ee1a67a84c",
        "image_url": "https://storage.googleapis.com/...",
        "description": "Tumpukan sampah plastik menyumbat saluran air.",
        "location": {
          "type": "Point",
          "coordinates": [106.8456, -6.2088]
        },
        "status": "pending_ai",
        "confidence_score": 0.0,
        "waste_type": null,
        "danger_level": null,
        "created_at": "2026-06-21T10:39:51.000Z",
        "updated_at": "2026-06-21T10:39:51.000Z",
        "profiles": {
          "username": "citizen_peduli",
          "full_name": "Budi Santoso",
          "avatar_url": "https://..."
        }
      }
    ]
    ```

### B. Mengubah Status & Detail Laporan (Review Laporan)
Digunakan untuk menyetujui, menolak, atau mengedit data klasifikasi sampah hasil analisis AI.
*   **Method & Path**: `PATCH /reports/:id`
*   **Request Body (JSON)**:
    ```json
    {
      "status": "approved", // 'approved' | 'rejected' | 'pending_human' | 'pending_ai'
      "waste_type": "Plastik", // opsional
      "danger_level": "medium", // 'low' | 'medium' | 'high' (opsional)
      "confidence_score": 0.95 // opsional
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "id": "7a752b09-5a5f-4a37-b6e5-23091176b6d2",
      "reporter_id": "4b68db6e-219d-4e9b-b0b2-29ee1a67a84c",
      "image_url": "https://storage.googleapis.com/...",
      "description": "Tumpukan sampah plastik menyumbat saluran air.",
      "location": "SRID=4326;POINT(106.8456 -6.2088)",
      "status": "approved",
      "confidence_score": 0.95,
      "waste_type": "Plastik",
      "danger_level": "medium",
      "created_at": "2026-06-21T10:39:51.000Z",
      "updated_at": "2026-06-21T10:45:00.000Z"
    }
    ```

### C. Menghapus Laporan Lingkungan
Digunakan untuk menghapus laporan yang dinilai melanggar etika atau mengandung spam yang tidak valid.
*   **Method & Path**: `DELETE /reports/:id`
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "message": "Laporan dengan ID uuid-string berhasil dihapus"
    }
    ```
