# Panduan Lengkap Migrasi RAG Ke Google Cloud (Gemini Enterprise Agent Platform)

> [!NOTE]
> **Update Teknologi (2026):** Google Cloud telah menyatukan Vertex AI Agent Builder dan layanan terkait ke dalam **Gemini Enterprise Agent Platform**. Meskipun nama menu di konsol berubah, seluruh arsitektur API dan integrasi SDK tetap kompatibel penuh tanpa memerlukan perubahan kode tambahan.

Dokumen ini memuat panduan langkah demi langkah untuk memindahkan basis pengetahuan (*knowledge base*) chatbot RAG Genesis.id dari Supabase (`pgvector`) ke **Google Cloud RAG (Gemini Enterprise Agent / Vertex AI Search)** untuk meningkatkan latensi dan akurasi pencarian hukum perda.

---

## 📅 Pembaruan Fitur RAG Google Cloud Terkini (2026)

Sebelum memulai migrasi, berikut adalah beberapa fitur baru di Google Cloud Console yang bisa Anda manfaatkan:
1. **Gemini Enterprise Agent Platform (Unified Console)**: Antarmuka baru yang menyatukan pembuatan Agent AI, RAG, dan dokumentasi alat dalam satu dashboard terpadu.
2. **Auto-Tuning Vector Search 2.0**: Indeks pencarian vektor untuk dokumen regulasi kini otomatis diatur oleh Google Cloud. Anda tidak perlu lagi mengonfigurasi dimensi dan metrik kemiripan indeks secara manual.
3. **Optimasi Biaya (VCPU Runtime)**: Google Cloud menurunkan biaya infrastruktur untuk container/konten pemrosesan data, sehingga RAG skala besar kini lebih ekonomis.

---

## 1. Persiapan di Google Cloud Console

### A. Aktifkan API yang Diperlukan
1. Buka [Google Cloud Console](https://console.cloud.google.com).
2. Cari dan aktifkan API berikut:
   * **Vertex AI Agent Builder API** (dikenal juga sebagai *Discovery Engine API*).
   * **Cloud Storage API**.

### B. Buat Cloud Storage (GCS) Bucket
1. Buka menu **Cloud Storage** -> **Buckets**.
2. Klik **Create**.
3. Beri nama bucket yang unik, misalnya: `genesis-knowledge-bucket`.
4. Pilih lokasi region **Singapura (`asia-southeast1`)** agar dekat dengan backend Anda.
5. Biarkan pengaturan lainnya default, lalu klik **Create**.
6. Unggah dokumen perda Anda (format `.pdf`, `.txt`, `.docx`, atau `.html`) ke dalam bucket ini.

### C. Konfigurasi Data Store di Gemini Enterprise Agent Platform
1. Cari menu **Agent Builder** atau **Gemini Enterprise Agent Platform** di Google Cloud Console.
2. Klik menu **Data Stores** di sebelah kiri, lalu klik **Create Data Store**.
3. Pilih opsi **Cloud Storage** sebagai sumber data.
4. Di bagian path, masukkan alamat bucket Anda: `gs://genesis-knowledge-bucket/*`.
5. Pilih tipe data: **Unstructured documents** (PDF, HTML, TXT), lalu klik **Continue**.
6. Masukkan nama Data Store Anda, misalnya: `genesis-perda-store`.
7. Setelah dibuat, salin **Data Store ID** yang tertera di tabel (berupa string unik).

---

## 2. Pembaruan Variabel Lingkungan (Environment Variables)

Tambahkan variabel baru di file `.env` lokal Anda dan di tab **Variables & Secrets** Google Cloud Run backend Anda:

```env
VERTEX_AI_DATASTORE_ID=NAMA_DATA_STORE_ID_ANDA
```

---

## 3. Modifikasi Kode Program NestJS

### A. Modifikasi `src/openrouter/openrouter.service.ts`
Daftarkan Data Store Google Cloud sebagai salah satu *Grounding Tool* di dalam metode `getChatCompletion` dan `getChatCompletionStream`.

Cari bagian instansiasi `toolsList` dan ubah menjadi:

```typescript
const toolsList: any[] = [];
if (webSearch) {
  toolsList.push({ googleSearch: {} });
} else {
  // Ambil Data Store ID dari environment
  const datastoreId = this.configService.get<string>('VERTEX_AI_DATASTORE_ID');
  const projectId = this.configService.get<string>('GCS_PROJECT_ID') || 'arief-fajar';
  
  if (datastoreId) {
    // Daftarkan Vertex AI Search sebagai RAG otomatis
    toolsList.push({
      vertexAiSearch: {
        datastore: `projects/${projectId}/locations/global/collections/default_collection/dataStores/${datastoreId}`
      }
    });
  }

  // Tetap masukkan function declarations lokal Anda
  toolsList.push({
    functionDeclarations: [
      {
        name: 'getGamificationStats',
        description: 'Mengambil data profil gamifikasi...',
        parameters: { type: 'OBJECT', properties: {} }
      },
      ...
    ]
  });
}
```

### B. Penyederhanaan `src/chat/chat.service.ts`
Karena Google Cloud menangani proses pencarian dokumen secara internal, Anda dapat menghapus logika pencarian vektor manual ke database Supabase.

Ubah baris pemrosesan chat di `processChat` dan `processChatStream` menjadi:

```typescript
// SEBELUMNYA:
// const contextText = shouldSearchDB ? await this.retrieveContext(sanitizedMessage) : '';

// SESUDAHNYA (Cukup kosongkan contextText):
const contextText = '';

const messages = this.buildMultimodalMessages(
  sanitizedMessage,
  contextText, // Tetap kirim string kosong
  dto,
  userProfile,
);
```

*(Catatan: Anda sekarang dapat menghapus method `retrieveContext` di dalam `chat.service.ts` untuk membersihkan kode).*

---

## 4. Skrip Otomatisasi Upload Dokumen ke GCS

Anda dapat membuat skrip otomatisasi di folder `backend/scripts/upload-knowledge-to-gcs.ts` untuk mengunggah seluruh dokumen regulasi di folder lokal Anda ke Cloud Storage secara instan.

### Contoh Implementasi Skrip:

```typescript
import { Storage } from '@google-cloud/storage';
import * as fs from 'fs';
import * as path from 'path';

// Inisialisasi GCS menggunakan Key File dari .env
const storage = new Storage({
  projectId: process.env.GCS_PROJECT_ID,
  keyFilename: process.env.GCS_KEY_FILE_PATH,
});

const BUCKET_NAME = process.env.GCS_BUCKET_NAME || 'genesis-knowledge-bucket';
const SOURCE_DIR = path.resolve(process.cwd(), '../docs'); // Folder docs lokal

async function uploadFiles() {
  console.log(`Mengunggah berkas dari ${SOURCE_DIR} ke bucket ${BUCKET_NAME}...`);
  const files = fs.readdirSync(SOURCE_DIR);

  for (const file of files) {
    const filePath = path.join(SOURCE_DIR, file);
    const stat = fs.statSync(filePath);

    // Hanya unggah file PDF, TXT, dan HTML
    if (stat.isFile() && /\.(pdf|txt|html|docx)$/i.test(file)) {
      console.log(`👉 Mengunggah ${file}...`);
      await storage.bucket(BUCKET_NAME).upload(filePath, {
        destination: `regulasi/${file}`,
      });
      console.log(`   └─ ✅ Sukses`);
    }
  }
  console.log('🎉 Semua berkas berhasil diunggah!');
}

uploadFiles().catch(console.error);
```

Menjalankan skrip ini akan menyalin berkas lokal Anda ke Cloud Storage Singapura, yang kemudian akan langsung disinkronkan ke AI dalam waktu kurang dari 5 menit.
