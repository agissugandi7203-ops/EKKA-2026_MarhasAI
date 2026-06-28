"use client";

import React, { useState } from "react";
import {
  Plus,
  X,
  FileText,
  Clock,
  Activity,
  Trash2,
  BookOpen,
  ShieldAlert,
  Sparkles,
  ArrowRight
} from "lucide-react";
import { RAGDocument } from "../page";

interface RagTabProps {
  ragDocs: RAGDocument[];
  isAddRagOpen: boolean;
  setIsAddRagOpen: (open: boolean) => void;
  ragTitle: string;
  setRagTitle: (title: string) => void;
  ragCategory: string;
  setRagCategory: (category: string) => void;
  ragContent: string;
  setRagContent: (content: string) => void;
  handleAddRagDoc: () => void;
  handleDeleteRagDoc: (id: string) => void;
}

export default function RagTab({
  ragDocs,
  isAddRagOpen,
  setIsAddRagOpen,
  ragTitle,
  setRagTitle,
  ragCategory,
  setRagCategory,
  ragContent,
  setRagContent,
  handleAddRagDoc,
  handleDeleteRagDoc
}: RagTabProps) {
  // Reading Drawer State
  const [readingDoc, setReadingDoc] = useState<RAGDocument | null>(null);

  // Local Custom Confirm Modal State
  const [deleteConfirmDoc, setDeleteConfirmDoc] = useState<RAGDocument | null>(null);
  const [verifyText, setVerifyText] = useState("");

  // Get Mock full content if doc.content is empty
  const getDocContent = (doc: RAGDocument) => {
    if (doc.content) return doc.content;

    // Default mock contents for the pre-seeded files
    if (doc.id === "rag-01") {
      return `UNDANG-UNDANG REPUBLIK INDONESIA NOMOR 18 TAHUN 2008
TENTANG PENGELOLAAN SAMPAH

DENGAN RAHMAT TUHAN YANG MAHA ESA
PRESIDEN REPUBLIK INDONESIA,

Menimbang:
a. bahwa pertambahan penduduk dan perubahan pola konsumsi masyarakat menimbulkan volume, jenis, dan karakteristik sampah yang semakin beragam;
b. bahwa pengelolaan sampah selama ini belum sesuai dengan metode dan teknik pengelolaan sampah yang berwawasan lingkungan sehingga menimbulkan dampak negatif terhadap kesehatan masyarakat dan lingkungan;
c. bahwa sampah telah menjadi permasalahan nasional sehingga pengelolaannya perlu dilakukan secara komprehensif dan terpadu dari hulu ke hilir agar memberikan manfaat secara ekonomi, sehat bagi masyarakat, dan aman bagi lingkungan, serta dapat mengubah perilaku masyarakat;
d. bahwa berdasarkan pertimbangan sebagaimana dimaksud dalam huruf a, huruf b, dan huruf c perlu membentuk Undang-Undang tentang Pengelolaan Sampah;

BAB I: KETENTUAN UMUM
Pasal 1:
Dalam Undang-Undang ini yang dimaksud dengan:
1. Sampah adalah sisa kegiatan sehari-hari manusia dan/atau proses alam yang berbentuk padat.
2. Pengelolaan sampah adalah kegiatan yang sistematis, menyeluruh, dan berkesinambungan yang meliputi pengurangan dan penanganan sampah.
3. Produsen adalah pelaku usaha yang memproduksi barang yang menggunakan kemasan, mendistribusikan barang yang menggunakan kemasan dan berasal dari impor, atau mengimpor barang yang menggunakan kemasan.

BAB V: TUGAS DAN WEWENANG PEMERINTAH DAN PEMERINTAH DAERAH
Pasal 9:
Pemerintah dan pemerintah daerah bertugas menjamin terselenggaranya pengelolaan sampah yang baik dan berwawasan lingkungan sesuai dengan ketentuan Undang-Undang ini.

Pasal 10:
Pemerintah Kabupaten/Kota berwenang untuk merumuskan dan menetapkan kebijakan serta strategi pengelolaan sampah kabupaten/kota berdasarkan kebijakan nasional dan kebijakan provinsi.`;
    }

    if (doc.id === "rag-02") {
      return `PERATURAN DAERAH KOTA SURABAYA
NOMOR 5 TAHUN 2014
TENTANG PENGELOLAAN SAMPAH DAN KEBERSIHAN DI KOTA SURABAYA

DENGAN RAHMAT TUHAN YANG MAHA ESA
WALIKOTA SURABAYA,

BAB III: HAK, KEWAJIBAN, DAN LARANGAN
Pasal 8:
Setiap orang berhak mendapatkan pelayanan pengelolaan sampah secara baik dan berwawasan lingkungan dari Pemerintah Daerah.

Pasal 9:
Setiap orang atau badan hukum wajib melakukan pengelolaan sampah rumah tangga dan sampah sejenis sampah rumah tangga dengan cara yang berwawasan lingkungan.

Pasal 10 (LARANGAN ABSOLUT):
Setiap orang dilarang:
a. Membuang sampah tidak pada tempat yang telah ditentukan dan disediakan oleh Pemerintah Daerah.
b. Membakar sampah di pekarangan, jalan, maupun tempat terbuka yang dapat menimbulkan polusi udara atau bahaya kebakaran.
c. Membuang sampah B3 (Bahan Berbahaya dan Beracun) ke saluran drainase umum, sungai, atau laut.

BAB VIII: SANKSI ADMINISTRATIF & DENDA
Pasal 34:
Setiap warga yang melanggar ketentuan larangan Pasal 10 huruf (a) dikenakan sanksi denda administratif sebesar maksimal Rp 750.000 (Tujuh Ratus Lima Puluh Ribu Rupiah) atau penahanan identitas kependudukan selama maksimal 30 hari kerja.`;
    }

    if (doc.id === "rag-03") {
      return `STANDARD OPERATING PROCEDURE (SOP)
PENANGANAN DAN KLASIFIKASI LIMBAH B3 RUMAH TANGGA
GENESIS.ID INTEGRATED CITIZEN HUB

1. PENDAHULUAN
Limbah Bahan Berbahaya dan Beracun (B3) rumah tangga memerlukan penanganan khusus yang terpisah dari sampah domestik anorganik/organik guna mencegah kontaminasi tanah, air tanah, dan bahaya keracunan pada ekosistem warga.

2. PROSEDUR KLASIFIKASI AI
- Sensor AI Genesis.id mendeteksi karakteristik limbah kimia, baterai bekas, wadah aerosol, pestisida, atau limbah medis.
- Akurasi visual (Confidence Score) wajib bernilai di atas 85% untuk penetapan auto-danger LEVEL "TINGGI".

3. PROSEDUR VALIDASI MANUAL ADMINISTRATOR (PORTAL OTORITAS)
- Administrator memeriksa kecocokan citra visual dengan laporan tertulis warga.
- Administrator wajib memberikan catatan feedback rute pengangkutan tanggap darurat.

4. LOGISTIK PENGANGKUTAN DAN EVALUASI
- Tim Satgas Kebersihan Kota dikirim dalam waktu < 4 jam setelah verifikasi approved.
- Penyemprotan area kontaminasi dengan bahan neutralizer jika terjadi kebocoran zat cair kimia berbahaya.`;
    }

    return "Konten dokumen teks baru sedang diproses oleh mesin pengindeksan vektor AI Genesis.id...";
  };

  const handleTriggerDelete = () => {
    if (!deleteConfirmDoc) return;
    if (verifyText.toUpperCase() !== "HAPUS") {
      alert('Harap ketik "HAPUS" untuk mengonfirmasi.');
      return;
    }
    handleDeleteRagDoc(deleteConfirmDoc.id);
    setDeleteConfirmDoc(null);
    setVerifyText("");
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up relative">
      
      {/* Header section with actions */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-navy-900">Basis Pengetahuan AI & Regulasi Sampah</h1>
          <p className="text-xs text-navy-500 font-light mt-1.5">
            Unggah file regulasi kota, SOP, dan aturan penanganan limbah daerah untuk melatih chatbot RAG AI warga.
          </p>
        </div>

        <button
          onClick={() => setIsAddRagOpen(true)}
          className="flex items-center gap-2 self-start bg-navy-900 text-white rounded-xl px-4 py-2.5 text-xs font-semibold hover:bg-navy-800 transition-all cursor-pointer shadow-md select-none"
        >
          <Plus className="h-4 w-4 shrink-0" />
          Latih Dokumen RAG Baru
        </button>
      </div>

      {/* RAG Documents Grid cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {ragDocs.map((doc) => (
          <div 
            key={doc.id} 
            className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.015)] hover:shadow-[0_8px_30px_rgba(10,22,40,0.035)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-5"
          >
            <div className="flex flex-col gap-2">
              <div className="flex items-center justify-between select-none">
                <span className="text-[9px] font-bold text-gold bg-gold-50 border border-gold-100 px-2.5 py-0.5 rounded-full uppercase tracking-wider">
                  {doc.category}
                </span>
                <div className="flex items-center gap-1.5">
                  <span className="text-[10px] text-navy-400 font-mono font-medium max-w-[80px] truncate" title={doc.id}>
                    {doc.id}
                  </span>
                  
                  {/* Delete button */}
                  <button
                    onClick={() => {
                      setVerifyText("");
                      setDeleteConfirmDoc(doc);
                    }}
                    className="p-1 rounded-md text-navy-400 hover:text-burgundy-500 hover:bg-burgundy-50 transition-colors cursor-pointer shrink-0"
                    title="Hapus Dokumen RAG"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>
              <h3 className="text-sm font-bold text-navy-900 leading-snug mt-2">{doc.title}</h3>
            </div>

            <div className="flex items-center justify-between border-t border-navy-50 pt-4">
              <div className="flex flex-col">
                <span className="text-[10px] text-navy-400 font-medium">Karakter Terindeks</span>
                <span className="text-xs font-bold font-mono text-navy-900 mt-0.5">
                  {(doc.charCount / 1000).toFixed(1)}k Chars
                </span>
              </div>

              {/* View Reading Drawer Button */}
              <button
                onClick={() => setReadingDoc(doc)}
                className="flex items-center gap-1.5 text-navy-900 hover:text-navy-600 font-bold text-[10px] uppercase cursor-pointer"
              >
                <BookOpen className="h-3.5 w-3.5" />
                Baca Konten
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* --- SLIDING RIGHT DRAWER OVERLAY (View Content Drawer) --- */}
      {readingDoc && (
        <div className="fixed inset-0 z-50 overflow-hidden select-none">
          {/* Backdrop blur */}
          <div
            onClick={() => setReadingDoc(null)}
            className="absolute inset-0 bg-navy-950/20 backdrop-blur-xs transition-opacity duration-300 animate-fade-in"
          />

          <div className="absolute inset-y-0 right-0 max-w-full flex pl-10">
            <div className="w-screen max-w-xl bg-white border-l border-navy-100 shadow-2xl flex flex-col h-full animate-slide-left relative">
              
              {/* Drawer Header */}
              <div className="p-6 md:p-8 border-b border-navy-50 flex items-center justify-between gap-4">
                <div className="flex flex-col">
                  <span className="text-[10px] font-bold text-gold uppercase tracking-wider">{readingDoc.category}</span>
                  <h3 className="text-lg font-bold text-navy-900 mt-1 leading-tight">{readingDoc.title}</h3>
                  <span className="text-[10px] text-navy-400 font-mono mt-1">ID Dokumen: {readingDoc.id}</span>
                </div>
                
                <button
                  onClick={() => setReadingDoc(null)}
                  className="h-9 w-9 rounded-full bg-navy-50 hover:bg-navy-100 text-navy-600 hover:text-navy-900 border border-navy-100 flex items-center justify-center cursor-pointer transition-colors"
                >
                  <X className="h-4.5 w-4.5" />
                </button>
              </div>

              {/* Drawer Content Body */}
              <div className="flex-1 overflow-y-auto p-6 md:p-8 bg-surface/30">
                <div className="bg-white border border-navy-100/60 rounded-2xl p-6 shadow-sm min-h-[300px]">
                  <p className="text-xs text-navy-700 font-light leading-relaxed whitespace-pre-wrap font-sans">
                    {getDocContent(readingDoc)}
                  </p>
                </div>
              </div>

              {/* Drawer Footer */}
              <div className="p-6 border-t border-navy-50 bg-white flex items-center justify-between">
                <span className="text-[10px] font-mono font-semibold text-navy-400">
                  Total Karakter: {readingDoc.charCount.toLocaleString("id-ID")}
                </span>
                <button
                  onClick={() => setReadingDoc(null)}
                  className="flex items-center gap-1.5 bg-navy-900 hover:bg-navy-850 text-white rounded-xl px-5 py-2.5 text-xs font-bold transition-all shadow-sm cursor-pointer"
                >
                  Tutup Dokumen
                  <ArrowRight className="h-3.5 w-3.5" />
                </button>
              </div>

            </div>
          </div>
        </div>
      )}

      {/* --- LOCAL CUSTOM CONFIRMATION MODAL --- */}
      {deleteConfirmDoc && (
        <div className="fixed inset-0 bg-navy-950/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className="w-full max-w-sm bg-white/95 backdrop-blur-xl border border-navy-100 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center select-none">
            
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center border bg-red-50 border-red-100 text-red-600 animate-bounce">
              <ShieldAlert className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold text-navy-900 leading-tight">Hapus Dokumen RAG Vektor</h3>
              <p className="text-xs text-navy-500 font-light leading-relaxed mt-2">
                Menghapus <strong className="text-navy-900 font-bold">"{deleteConfirmDoc.title}"</strong> akan melenyapkan bobot referensi pengetahuan Chatbot AI warga kota secara permanen!
              </p>
            </div>

            {/* Verification text field */}
            <div className="flex flex-col gap-2">
              <label htmlFor="ragVerify" className="text-[10px] font-extrabold text-navy-400 uppercase tracking-wider">
                Ketik <strong className="text-navy-900 font-black">"HAPUS"</strong> untuk mengonfirmasi
              </label>
              <input
                id="ragVerify"
                type="text"
                placeholder="Ketik kata HAPUS..."
                value={verifyText}
                onChange={(e) => setVerifyText(e.target.value)}
                className="w-full bg-surface border border-navy-100 rounded-xl py-2 px-3 text-center text-xs text-navy-900 font-black tracking-widest focus:outline-none focus:border-navy-500"
              />
            </div>

            {/* Actions */}
            <div className="flex items-center gap-3 pt-4 border-t border-navy-50 justify-end">
              <button
                onClick={() => {
                  setDeleteConfirmDoc(null);
                  setVerifyText("");
                }}
                className="w-1/2 rounded-xl bg-navy-50 border border-navy-100 py-2.5 text-xs font-bold text-navy-600 hover:bg-navy-100 transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleTriggerDelete}
                disabled={verifyText.toUpperCase() !== "HAPUS"}
                className="w-1/2 rounded-xl py-2.5 text-xs font-bold text-white bg-burgundy-500 hover:bg-burgundy-600 transition-all cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed"
              >
                Hapus Permanen
              </button>
            </div>

          </div>
        </div>
      )}

      {/* MODAL: TRAIN NEW VECTOR DOCUMENT */}
      {isAddRagOpen && (
        <div className="fixed inset-0 bg-navy-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fade-in">
          <div className="w-full max-w-lg bg-white border border-navy-100 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
            
            <div className="border-b border-navy-50 pb-3 select-none">
              <h3 className="text-base font-bold text-navy-900">Latih Dokumen Pengetahuan RAG</h3>
              <p className="text-[11px] text-navy-500 mt-1">Tambahkan dokumen teks regulasi atau SOP untuk memperkaya kecerdasan RAG Chatbot.</p>
            </div>

            <div className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500">Judul Dokumen</label>
                <input
                  type="text"
                  value={ragTitle}
                  onChange={(e) => setRagTitle(e.target.value)}
                  placeholder="e.g. UU Penanganan Sampah No 15"
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-900 focus:outline-none focus:border-navy-300 transition-all"
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500">Kategori Dokumen</label>
                <select
                  value={ragCategory}
                  onChange={(e) => setRagCategory(e.target.value)}
                  className="w-full bg-white border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-800 focus:outline-none cursor-pointer font-medium"
                >
                  <option value="Undang-Undang">Undang-Undang</option>
                  <option value="Peraturan Daerah">Peraturan Daerah</option>
                  <option value="SOP Penanganan">Standard Operating Procedure (SOP)</option>
                  <option value="Sanksi & Denda">Sanksi & Denda Lingkungan</option>
                </select>
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500">Isi Dokumen Teks Regulasi</label>
                <textarea
                  value={ragContent}
                  onChange={(e) => setRagContent(e.target.value)}
                  placeholder="Tempel dokumen lengkap atau salinan pasal regulasi di sini..."
                  rows={6}
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-2xl p-3.5 text-xs text-navy-900 focus:outline-none focus:border-navy-300 focus:bg-white transition-all shadow-inner"
                />
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-navy-50">
              <button
                onClick={() => setIsAddRagOpen(false)}
                className="rounded-xl bg-navy-50 text-navy-600 border border-navy-100 px-4 py-2.5 text-xs font-semibold hover:bg-navy-100 transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleAddRagDoc}
                disabled={!ragTitle || !ragContent}
                className="rounded-xl bg-navy-900 text-white px-4 py-2.5 text-xs font-semibold hover:bg-navy-800 transition-all cursor-pointer shadow-sm disabled:opacity-50"
              >
                Mulai Pelatihan AI RAG
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
