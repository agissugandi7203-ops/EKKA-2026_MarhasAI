# Panduan SEO & Konfigurasi Google Search Console

Dokumen ini berisi informasi mengenai arsitektur SEO, DNS records, dan konfigurasi Google Search Console untuk portal **GenesisHub**.

---

## 1. Pemetaan Domain Produksi

Sistem menggunakan domain terpisah untuk memisahkan lalu lintas data pengguna (Flutter/API) dan portal admin/landing page (Next.js):

*   **Domain Frontend (Next.js)**: `https://genesisHub.web.id`
*   **Domain Backend (NestJS)**: `https://genesisHub.my.id`

---

## 2. Berkas SEO & Metadata Terpasang

Telah dikonfigurasi 5 berkas SEO penting di folder [frontend/public/](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public) untuk memaksimalkan indeksasi Google:

1.  **[sitemap.xml](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/sitemap.xml)**: Peta situs berisi daftar URL aktif agar mesin pencari dapat mengindeks seluruh halaman.
2.  **[robots.txt](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/robots.txt)**: Mengatur aturan perayapan (crawling) bagi bot Google dan mengarahkan mereka ke file sitemap.
3.  **[googlee4a64ab1a21f7c0d.html](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/googlee4a64ab1a21f7c0d.html)**: File verifikasi kepemilikan Google Search Console (GSC) berbasis HTML.
4.  **[manifest.json](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/manifest.json)**: Manifest aplikasi web (PWA) untuk optimasi snippet seluler dan performa mobile.
5.  **[schema-org.json](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/schema-org.json)**: Berkas referensi data terstruktur (JSON-LD Organization) untuk melatih bot Google memahami tipe organisasi entitas kita.

> [!NOTE]
> Struktur metadata modern dan JSON-LD Organization Schema juga telah ditanam secara langsung ke dalam [layout.tsx](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/src/app/layout.tsx) Next.js untuk rendering dinamis sisi server (SSR).

---

## 3. Panduan Konfigurasi DNS

Anda perlu masuk ke panel DNS manager domain Anda (seperti Cloudflare, Rumahweb, Niagahoster, Domainesia, dsb.) dan menambahkan baris record berikut:

### A. Untuk Frontend (`genesisHub.web.id`)
Jika dideploy menggunakan Google Cloud Run Domain Mapping / Cloud Load Balancing:

| Tipe | Nama | Target/Nilai | TTL | Fungsi |
| :--- | :--- | :--- | :--- | :--- |
| **CNAME** | `@` / `genesisHub.web.id` | Target domain dari Cloud Run (misal: `ghs.googlehosted.com.`) | Auto / 3600 | Mengarahkan domain utama ke frontend Cloud Run |
| **CNAME** | `www` | `genesisHub.web.id` | Auto / 3600 | Alias subdomain www ke domain utama |

*(Catatan: Beberapa provider DNS mewajibkan record **A** langsung menggunakan IP Anycast Google Cloud Run jika DNS Anda tidak mendukung CNAME flattening pada root domain. Periksa IP yang diberikan oleh menu Google Cloud Run -> Custom Domains).*

### B. Untuk Backend (`genesisHub.my.id`)
Mengarahkan API request dari Flutter & Frontend ke NestJS Backend:

| Tipe | Nama | Target/Nilai | TTL | Fungsi |
| :--- | :--- | :--- | :--- | :--- |
| **CNAME** | `@` / `genesisHub.my.id` | Target domain dari Cloud Run Backend (misal: `ghs.googlehosted.com.`) | Auto / 3600 | Mengarahkan domain backend ke NestJS Cloud Run |

---

## 4. Langkah-Langkah Verifikasi Google Search Console

Untuk mendaftarkan situs Anda ke Google Search Console:

1.  Buka [Google Search Console](https://search.google.com/search-console).
2.  Klik **Add Property** (Tambah Properti).
3.  Pilih metode **URL Prefix** (Awalan URL) dan masukkan `https://genesisHub.web.id`.
4.  Pilih opsi verifikasi **HTML File** (File HTML).
5.  Karena Anda sudah memiliki berkas [googlee4a64ab1a21f7c0d.html](file:///d:/PROJECT%20ARIEF/LKS%20Dikdasmen/frontend/public/googlee4a64ab1a21f7c0d.html) di server Anda, setelah build dideploy, Anda hanya perlu mengklik **Verify** (Verifikasi).
6.  *Metode Alternatif (Opsional)*: Pilih verifikasi lewat **Domain/DNS Record**, lalu salin nilai kode TXT yang diberikan oleh Google, lalu tambahkan baris record berikut ke DNS Manager Anda:
    *   **Tipe**: `TXT`
    *   **Nama/Host**: `@`
    *   **Nilai**: `google-site-verification=KODE_DARI_GOOGLE_SEARCH_CONSOLE`
7.  Setelah terverifikasi, buka menu **Sitemaps** di panel kiri Google Search Console, kemudian masukkan `sitemap.xml` di kolom kirim sitemap baru lalu tekan **Submit**.

---

## 5. Pengecekan SEO Secara Mandiri
Pastikan setelah deploying berjalan, Anda menguji kualitas SEO menggunakan Lighthouse atau PageSpeed Insights:
*   Akses halaman untuk memastikan tag `<title>` dan `<meta name="description">` ter-render di HTML mentah.
*   Cek validitas structured data menggunakan [Schema Markup Validator](https://validator.schema.org/).
