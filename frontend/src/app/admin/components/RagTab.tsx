"use client";

import React, { useState } from "react";
import {
  Plus,
  X,
  FileText,
  Clock,
  Trash2,
  BookOpen,
  ShieldAlert,
  Sparkles,
  ArrowRight,
  Brain,
  Database,
  Upload,
  ChevronRight
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
  theme?: "light" | "dark";
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
  handleDeleteRagDoc,
  theme = "light"
}: RagTabProps) {
  const [readingDoc, setReadingDoc] = useState<RAGDocument | null>(null);
  const [deleteConfirmDoc, setDeleteConfirmDoc] = useState<RAGDocument | null>(null);
  const [verifyText, setVerifyText] = useState("");
  const isDark = theme === "dark";

  const getDocContent = (doc: RAGDocument) => {
    if (doc.content) return doc.content;

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

  const getCategoryColor = (category: string) => {
    const map: Record<string, { bg: string; text: string; border: string }> = {
      "Regulasi Nasional": {
        bg: isDark ? "bg-blue-500/10" : "bg-blue-50",
        text: isDark ? "text-blue-400" : "text-blue-700",
        border: isDark ? "border-blue-500/20" : "border-blue-200"
      },
      "Peraturan Daerah": {
        bg: isDark ? "bg-indigo-500/10" : "bg-indigo-50",
        text: isDark ? "text-indigo-400" : "text-indigo-700",
        border: isDark ? "border-indigo-500/20" : "border-indigo-200"
      },
      "SOP Internal": {
        bg: isDark ? "bg-amber-500/10" : "bg-amber-50",
        text: isDark ? "text-amber-400" : "text-amber-700",
        border: isDark ? "border-amber-500/20" : "border-amber-200"
      }
    };
    return map[category] ?? {
      bg: isDark ? "bg-zinc-800" : "bg-slate-50",
      text: isDark ? "text-zinc-400" : "text-slate-600",
      border: isDark ? "border-zinc-700" : "border-slate-200"
    };
  };

  const totalChars = ragDocs.reduce((sum, d) => sum + d.charCount, 0);

  return (
    <div className="flex flex-col gap-10 animate-fade-up relative">

      {/* ── HEADER ─────────────────────────────────────────────── */}
      <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-3">
            <div className={`h-10 w-10 rounded-2xl flex items-center justify-center ${isDark ? "bg-indigo-500/10 text-indigo-400 border border-indigo-500/20" : "bg-indigo-50 text-indigo-600 border border-indigo-100"}`}>
              <Brain className="h-5 w-5" />
            </div>
            <div>
              <h1 className={`text-2xl font-bold tracking-tight leading-none ${isDark ? "text-white" : "text-slate-900"}`}>
                Basis Pengetahuan AI
              </h1>
              <p className={`text-xs mt-1 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
                Regulasi & dokumen yang melatih chatbot RAG warga
              </p>
            </div>
          </div>
        </div>

        <button
          onClick={() => setIsAddRagOpen(true)}
          className={`flex items-center gap-2 self-start lg:self-auto rounded-xl px-5 py-2.5 text-xs font-semibold transition-all cursor-pointer shadow-sm hover:scale-[1.01] active:scale-[0.99] ${
            isDark
              ? "bg-indigo-600 hover:bg-indigo-500 text-white"
              : "bg-slate-900 text-white hover:bg-slate-700"
          }`}
        >
          <Upload className="h-3.5 w-3.5 shrink-0" />
          Unggah Dokumen RAG
        </button>
      </div>

      {/* ── STAT STRIP ─────────────────────────────────────────── */}
      <div className={`grid grid-cols-3 gap-4 rounded-2xl p-5 border ${isDark ? "bg-zinc-900 border-zinc-800" : "bg-slate-50 border-slate-200"}`}>
        {[
          { label: "Total Dokumen", value: ragDocs.length.toString(), icon: <Database className="h-4 w-4" /> },
          { label: "Total Karakter", value: `${(totalChars / 1000).toFixed(1)}k`, icon: <FileText className="h-4 w-4" /> },
          { label: "Model RAG", value: "Vector DB", icon: <Sparkles className="h-4 w-4" /> }
        ].map((s) => (
          <div key={s.label} className="flex flex-col gap-1.5">
            <div className={`flex items-center gap-1.5 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
              {s.icon}
              <span className="text-[10px] font-semibold uppercase tracking-wider">{s.label}</span>
            </div>
            <span className={`text-lg font-bold font-mono ${isDark ? "text-white" : "text-slate-900"}`}>
              {s.value}
            </span>
          </div>
        ))}
      </div>

      {/* ── DOCUMENT CARDS ─────────────────────────────────────── */}
      <div className="flex flex-col gap-3">
        {ragDocs.map((doc) => {
          const cat = getCategoryColor(doc.category);
          return (
            <div
              key={doc.id}
              className={`rounded-2xl p-5 border transition-all duration-300 hover:shadow-md ${
                isDark
                  ? "bg-zinc-900 border-zinc-800 text-white"
                  : "bg-white border-slate-200 text-slate-800"
              }`}
            >
              {/* Row: icon + title + category + actions */}
              <div className="flex items-start gap-4">
                {/* File icon */}
                <div className={`mt-0.5 h-9 w-9 rounded-xl flex items-center justify-center shrink-0 border ${isDark ? "bg-zinc-800 border-zinc-700 text-zinc-300" : "bg-slate-50 border-slate-200 text-slate-500"}`}>
                  <FileText className="h-4 w-4" />
                </div>

                {/* Main content */}
                <div className="flex-1 min-w-0 flex flex-col gap-1.5">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className={`text-[9px] font-bold px-2.5 py-0.5 rounded-full uppercase tracking-wider border ${cat.bg} ${cat.text} ${cat.border}`}>
                      {doc.category}
                    </span>
                    <span className={`text-[10px] font-mono ${isDark ? "text-zinc-600" : "text-slate-300"}`}>
                      #{doc.id}
                    </span>
                  </div>
                  <h3 className={`text-sm font-semibold leading-snug ${isDark ? "text-slate-100" : "text-slate-800"}`}>
                    {doc.title}
                  </h3>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-1 shrink-0">
                  <button
                    onClick={() => setReadingDoc(doc)}
                    className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[10px] font-bold uppercase tracking-wider border cursor-pointer transition-all ${
                      isDark
                        ? "bg-zinc-800 border-zinc-700 text-zinc-300 hover:bg-zinc-700 hover:text-white"
                        : "bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100 hover:text-slate-900"
                    }`}
                  >
                    <BookOpen className="h-3 w-3" />
                    Baca
                  </button>
                  <button
                    onClick={() => { setVerifyText(""); setDeleteConfirmDoc(doc); }}
                    className={`p-1.5 rounded-lg transition-colors cursor-pointer shrink-0 ${
                      isDark
                        ? "text-zinc-600 hover:text-red-400 hover:bg-red-950/20"
                        : "text-slate-300 hover:text-red-600 hover:bg-red-50"
                    }`}
                    title="Hapus Dokumen RAG"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>

              {/* Footer: metadata */}
              <div className={`mt-4 pt-3.5 border-t flex items-center gap-4 ${isDark ? "border-zinc-800" : "border-slate-100"}`}>
                <div className="flex items-center gap-1.5">
                  <FileText className={`h-3 w-3 ${isDark ? "text-zinc-600" : "text-slate-300"}`} />
                  <span className={`text-[10px] font-mono font-semibold ${isDark ? "text-zinc-400" : "text-slate-500"}`}>
                    {(doc.charCount / 1000).toFixed(1)}k chars terindeks
                  </span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Clock className={`h-3 w-3 ${isDark ? "text-zinc-600" : "text-slate-300"}`} />
                  <span className={`text-[10px] ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                    {doc.createdAt}
                  </span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* ── ADD DOCUMENT PANEL (slide-down) ────────────────────── */}
      {isAddRagOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fade-in">
          <div className={`w-full max-w-lg border rounded-3xl shadow-2xl flex flex-col gap-0 overflow-hidden ${
            isDark ? "bg-zinc-950 border-zinc-800 text-white" : "bg-white border-slate-200 text-slate-800"
          }`}>
            {/* Modal header */}
            <div className={`flex items-center justify-between px-6 py-5 border-b ${isDark ? "border-zinc-800" : "border-slate-100"}`}>
              <div className="flex items-center gap-3">
                <div className={`h-8 w-8 rounded-xl flex items-center justify-center ${isDark ? "bg-indigo-500/10 text-indigo-400" : "bg-indigo-50 text-indigo-600"}`}>
                  <Brain className="h-4 w-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold">Latih Dokumen RAG Baru</h3>
                  <p className={`text-[10px] ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Tambahkan ke basis pengetahuan vektor AI</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddRagOpen(false)}
                className={`h-8 w-8 rounded-full flex items-center justify-center cursor-pointer border transition-all ${
                  isDark ? "bg-zinc-900 border-zinc-800 text-zinc-400 hover:text-white" : "bg-slate-50 border-slate-200 text-slate-400 hover:text-slate-800"
                }`}
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </div>

            {/* Form body */}
            <div className="flex flex-col gap-5 px-6 py-6">
              {/* Title */}
              <div className="flex flex-col gap-1.5">
                <label className={`text-[10px] font-extrabold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                  Judul Dokumen
                </label>
                <input
                  type="text"
                  placeholder="Contoh: UU No. 18 Tahun 2008 Pengelolaan Sampah"
                  value={ragTitle}
                  onChange={(e) => setRagTitle(e.target.value)}
                  className={`w-full border rounded-xl py-2.5 px-3.5 text-xs focus:outline-none transition-all ${
                    isDark
                      ? "bg-zinc-900 border-zinc-800 text-white placeholder:text-zinc-600 focus:border-indigo-500"
                      : "bg-slate-50 border-slate-200 text-slate-900 placeholder:text-slate-400 focus:border-slate-400"
                  }`}
                />
              </div>

              {/* Category */}
              <div className="flex flex-col gap-1.5">
                <label className={`text-[10px] font-extrabold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                  Kategori
                </label>
                <select
                  value={ragCategory}
                  onChange={(e) => setRagCategory(e.target.value)}
                  className={`w-full border rounded-xl py-2.5 px-3.5 text-xs focus:outline-none transition-all cursor-pointer ${
                    isDark
                      ? "bg-zinc-900 border-zinc-800 text-white focus:border-indigo-500"
                      : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-400"
                  }`}
                >
                  <option value="Regulasi Nasional">Regulasi Nasional</option>
                  <option value="Peraturan Daerah">Peraturan Daerah</option>
                  <option value="SOP Internal">SOP Internal</option>
                  <option value="Lainnya">Lainnya</option>
                </select>
              </div>

              {/* Content */}
              <div className="flex flex-col gap-1.5">
                <label className={`text-[10px] font-extrabold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                  Konten Dokumen
                </label>
                <textarea
                  placeholder="Tempelkan teks peraturan, SOP, atau panduan yang akan diindeks ke vector database RAG..."
                  value={ragContent}
                  onChange={(e) => setRagContent(e.target.value)}
                  rows={7}
                  className={`w-full border rounded-xl py-2.5 px-3.5 text-xs resize-none focus:outline-none transition-all font-mono leading-relaxed ${
                    isDark
                      ? "bg-zinc-900 border-zinc-800 text-slate-200 placeholder:text-zinc-600 focus:border-indigo-500"
                      : "bg-slate-50 border-slate-200 text-slate-800 placeholder:text-slate-400 focus:border-slate-400"
                  }`}
                />
                {ragContent && (
                  <span className={`text-[10px] font-mono ${isDark ? "text-zinc-600" : "text-slate-400"}`}>
                    {ragContent.length.toLocaleString("id-ID")} karakter
                  </span>
                )}
              </div>
            </div>

            {/* Footer actions */}
            <div className={`flex items-center justify-end gap-3 px-6 py-4 border-t ${isDark ? "border-zinc-800" : "border-slate-100"}`}>
              <button
                onClick={() => setIsAddRagOpen(false)}
                className={`rounded-xl px-4 py-2 text-xs font-semibold cursor-pointer border transition-all ${
                  isDark ? "bg-zinc-900 border-zinc-800 text-zinc-400 hover:text-white" : "bg-slate-50 border-slate-200 text-slate-500 hover:text-slate-800"
                }`}
              >
                Batal
              </button>
              <button
                onClick={handleAddRagDoc}
                disabled={!ragTitle || !ragContent}
                className="flex items-center gap-2 rounded-xl px-5 py-2 text-xs font-bold text-white bg-slate-900 hover:bg-slate-700 transition-all cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed shadow-sm"
              >
                <Brain className="h-3.5 w-3.5" />
                Indeks ke RAG
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── READING DRAWER ─────────────────────────────────────── */}
      {readingDoc && (
        <div className="fixed inset-0 z-50 overflow-hidden select-none">
          <div
            onClick={() => setReadingDoc(null)}
            className="absolute inset-0 bg-black/40 backdrop-blur-xs transition-opacity duration-300 animate-fade-in"
          />

          <div className="absolute inset-y-0 right-0 max-w-full flex pl-10">
            <div className={`w-screen max-w-xl border-l shadow-2xl flex flex-col h-full animate-slide-left relative ${
              isDark ? "bg-[#09090b] border-zinc-900 text-white" : "bg-white border-slate-200 text-slate-800"
            }`}>

              {/* Drawer Header */}
              <div className={`p-6 md:p-8 border-b flex items-start justify-between gap-4 ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
                <div className="flex flex-col gap-1.5">
                  <span className={`text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full border w-fit ${getCategoryColor(readingDoc.category).bg} ${getCategoryColor(readingDoc.category).text} ${getCategoryColor(readingDoc.category).border}`}>
                    {readingDoc.category}
                  </span>
                  <h3 className="text-base font-bold leading-snug mt-1">{readingDoc.title}</h3>
                  <span className={`text-[10px] font-mono ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                    ID: {readingDoc.id} &bull; {(readingDoc.charCount / 1000).toFixed(1)}k chars
                  </span>
                </div>

                <button
                  onClick={() => setReadingDoc(null)}
                  className={`h-9 w-9 rounded-full flex items-center justify-center cursor-pointer transition-all border shrink-0 ${
                    isDark
                      ? "bg-zinc-900 border-zinc-800 text-slate-300 hover:text-white"
                      : "bg-slate-50 border-slate-200 text-slate-500 hover:text-slate-900"
                  }`}
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              {/* Drawer Content */}
              <div className={`flex-1 overflow-y-auto p-6 md:p-8 ${isDark ? "bg-black" : "bg-slate-50/50"}`}>
                <div className={`border rounded-2xl p-6 shadow-sm min-h-[300px] ${
                  isDark ? "bg-zinc-950 border-zinc-900 text-slate-200" : "bg-white border-slate-100 text-slate-700"
                }`}>
                  <p className="text-xs leading-relaxed whitespace-pre-wrap font-mono">
                    {getDocContent(readingDoc)}
                  </p>
                </div>
              </div>

              {/* Drawer Footer */}
              <div className={`p-6 border-t flex items-center justify-between ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
                <span className={`text-[10px] font-mono font-semibold ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                  {readingDoc.charCount.toLocaleString("id-ID")} karakter terindeks
                </span>
                <button
                  onClick={() => setReadingDoc(null)}
                  className={`flex items-center gap-1.5 rounded-xl px-5 py-2.5 text-xs font-bold transition-all shadow-sm cursor-pointer ${
                    isDark
                      ? "bg-zinc-800 hover:bg-zinc-700 text-white"
                      : "bg-slate-900 hover:bg-slate-700 text-white"
                  }`}
                >
                  Tutup
                  <ArrowRight className="h-3.5 w-3.5" />
                </button>
              </div>

            </div>
          </div>
        </div>
      )}

      {/* ── DELETE CONFIRM MODAL ───────────────────────────────── */}
      {deleteConfirmDoc && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className={`w-full max-w-sm border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center select-none ${
            isDark ? "bg-zinc-950 border-zinc-800 text-white" : "bg-white border-slate-200 text-slate-800"
          }`}>

            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center border bg-red-50 border-red-100 text-red-600 animate-bounce">
              <ShieldAlert className="h-5 w-5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">Hapus Dokumen RAG</h3>
              <p className={`text-xs leading-relaxed mt-2 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
                Menghapus <strong className="text-red-500 font-bold">&ldquo;{deleteConfirmDoc.title}&rdquo;</strong> akan menghilangkan bobot referensi pengetahuan chatbot AI secara permanen.
              </p>
            </div>

            <div className="flex flex-col gap-2 text-left">
              <label htmlFor="ragVerify" className={`text-[10px] font-extrabold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                Ketik <strong className={isDark ? "text-slate-200" : "text-slate-800"}>&quot;HAPUS&quot;</strong> untuk konfirmasi
              </label>
              <input
                id="ragVerify"
                type="text"
                placeholder="Ketik HAPUS..."
                value={verifyText}
                onChange={(e) => setVerifyText(e.target.value)}
                className={`w-full border rounded-xl py-2 px-3 text-center text-xs font-black tracking-widest focus:outline-none transition-all ${
                  isDark
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700"
                    : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>

            <div className={`flex items-center gap-3 pt-2 border-t justify-end ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <button
                onClick={() => { setDeleteConfirmDoc(null); setVerifyText(""); }}
                className={`flex-1 rounded-xl py-2.5 text-xs font-bold transition-all border cursor-pointer ${
                  isDark
                    ? "bg-zinc-900 border-zinc-800 text-zinc-400 hover:bg-zinc-850"
                    : "bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100"
                }`}
              >
                Batal
              </button>
              <button
                onClick={handleTriggerDelete}
                disabled={verifyText.toUpperCase() !== "HAPUS"}
                className="flex-1 rounded-xl py-2.5 text-xs font-bold text-white bg-red-600 hover:bg-red-700 transition-all cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed"
              >
                Hapus Permanen
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
