"use client";

import React from "react";
import {
  Plus,
  X,
  FileText,
  Clock,
  Activity,
  Trash2
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
  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      
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
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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
                    {doc.id.length > 8 ? `${doc.id.substring(0, 8)}...` : doc.id}
                  </span>
                  <button
                    onClick={() => handleDeleteRagDoc(doc.id)}
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
              <span className="text-[10px] text-navy-400 font-semibold">{doc.createdAt}</span>
            </div>
          </div>
        ))}
      </div>

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
