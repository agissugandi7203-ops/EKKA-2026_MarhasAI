"use client";

import React, { useState } from "react";
import { Send, Users, User, Bell, AlertTriangle, Calendar, Info, Award, CheckCircle } from "lucide-react";

export interface BroadcastLog {
  id: string;
  title: string;
  message: string;
  category: "info" | "alert" | "event" | "quest";
  target: "all" | string; // 'all' or specific profile id
  created_at: string;
}

interface BroadcastTabProps {
  broadcastLogs: BroadcastLog[];
  handleSendBroadcast: (title: string, message: string, category: "info" | "alert" | "event" | "quest", target: "all" | string) => Promise<void>;
  actionLoading: boolean;
}

export default function BroadcastTab({
  broadcastLogs,
  handleSendBroadcast,
  actionLoading
}: BroadcastTabProps) {
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [category, setCategory] = useState<"info" | "alert" | "event" | "quest">("info");
  const [targetType, setTarget] = useState<"all" | "user">("all");
  const [specificUserId, setSpecificUserId] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !message) return;
    
    const finalTarget = targetType === "all" ? "all" : specificUserId;
    if (targetType === "user" && !specificUserId) {
      alert("Silakan masukkan ID Profil Spesifik.");
      return;
    }

    await handleSendBroadcast(title, message, category, finalTarget);
    
    setTitle("");
    setMessage("");
    setSpecificUserId("");
    setSuccessMsg("Siaran notifikasi berhasil dikirim dan dicatat!");
    setTimeout(() => setSuccessMsg(""), 4000);
  };

  const getCategoryIcon = (cat: string) => {
    switch (cat) {
      case "alert":
        return <AlertTriangle className="h-4 w-4 text-coral" />;
      case "event":
        return <Calendar className="h-4 w-4 text-blue" />;
      case "quest":
        return <Award className="h-4 w-4 text-gold" />;
      default:
        return <Info className="h-4 w-4 text-navy-500" />;
    }
  };

  return (
    <div className="flex flex-col gap-8 animate-fade-up">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-navy-900">Pusat Siaran Notifikasi (Broadcast Center)</h1>
        <p className="text-xs text-navy-500 font-light mt-1.5">
          Kirim pengumuman penting, peringatan darurat, info event kota, atau info tantangan langsung ke aplikasi Flutter warga.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Formulir Pengiriman */}
        <div className="lg:col-span-5 bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)]">
          <div className="flex items-center gap-2.5 border-b border-navy-50 pb-4 mb-6">
            <div className="h-8 w-8 rounded-lg bg-navy-50 flex items-center justify-center text-navy-900">
              <Bell className="h-4.5 w-4.5" />
            </div>
            <h2 className="text-base font-bold text-navy-900">Kirim Notifikasi Baru</h2>
          </div>

          <form onSubmit={onSubmit} className="flex flex-col gap-5">
            {successMsg && (
              <div className="p-3 bg-green-50 border border-green-200/50 rounded-2xl flex items-center gap-2 text-green-700 text-xs font-medium animate-fade-in">
                <CheckCircle className="h-4 w-4 shrink-0" />
                <span>{successMsg}</span>
              </div>
            )}

            {/* Target Penerima */}
            <div>
              <label className="block text-[11px] font-bold text-navy-500 uppercase tracking-wider mb-2">Target Penerima</label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setTarget("all")}
                  className={`flex items-center justify-center gap-2 px-4 py-2.5 rounded-2xl border text-xs font-semibold transition-all cursor-pointer ${
                    targetType === "all"
                      ? "bg-navy-900 text-white border-navy-900 shadow-sm"
                      : "bg-surface text-navy-600 border-navy-100 hover:bg-navy-50/50"
                  }`}
                >
                  <Users className="h-3.5 w-3.5" />
                  Semua Warga (Global)
                </button>
                <button
                  type="button"
                  onClick={() => setTarget("user")}
                  className={`flex items-center justify-center gap-2 px-4 py-2.5 rounded-2xl border text-xs font-semibold transition-all cursor-pointer ${
                    targetType === "user"
                      ? "bg-navy-900 text-white border-navy-900 shadow-sm"
                      : "bg-surface text-navy-600 border-navy-100 hover:bg-navy-50/50"
                  }`}
                >
                  <User className="h-3.5 w-3.5" />
                  Spesifik Warga
                </button>
              </div>
            </div>

            {/* Input ID Spesifik */}
            {targetType === "user" && (
              <div className="animate-fade-down">
                <label htmlFor="userId" className="block text-[11px] font-bold text-navy-500 uppercase tracking-wider mb-1.5">ID Profil Warga</label>
                <input
                  id="userId"
                  type="text"
                  required
                  placeholder="Contoh: usr-01 atau UUID Supabase"
                  value={specificUserId}
                  onChange={(e) => setSpecificUserId(e.target.value)}
                  className="w-full bg-surface border border-navy-100 rounded-2xl px-4 py-2.5 text-xs text-navy-900 placeholder:text-navy-300 focus:outline-none focus:border-navy-500 focus:ring-1 focus:ring-navy-500 transition-all font-mono"
                />
              </div>
            )}

            {/* Kategori Notifikasi */}
            <div>
              <label htmlFor="category" className="block text-[11px] font-bold text-navy-500 uppercase tracking-wider mb-1.5">Kategori Pesan</label>
              <select
                id="category"
                value={category}
                onChange={(e) => setCategory(e.target.value as any)}
                className="w-full bg-surface border border-navy-100 rounded-2xl px-4 py-2.5 text-xs text-navy-900 focus:outline-none focus:border-navy-500 transition-all cursor-pointer font-medium"
              >
                <option value="info">📢 Informasi & Pengumuman</option>
                <option value="alert">⚠️ Peringatan Darurat / Kritis</option>
                <option value="event">📅 Event Resmi Kota</option>
                <option value="quest">🏆 Misi Gamifikasi</option>
              </select>
            </div>

            {/* Judul Notifikasi */}
            <div>
              <label htmlFor="title" className="block text-[11px] font-bold text-navy-500 uppercase tracking-wider mb-1.5">Judul Siaran</label>
              <input
                id="title"
                type="text"
                required
                placeholder="Tulis judul pemberitahuan..."
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full bg-surface border border-navy-100 rounded-2xl px-4 py-2.5 text-xs text-navy-900 placeholder:text-navy-300 focus:outline-none focus:border-navy-500 focus:ring-1 focus:ring-navy-500 transition-all font-semibold"
              />
            </div>

            {/* Isi Pesan */}
            <div>
              <label htmlFor="message" className="block text-[11px] font-bold text-navy-500 uppercase tracking-wider mb-1.5">Isi Pesan Notifikasi</label>
              <textarea
                id="message"
                required
                rows={5}
                placeholder="Tulis deskripsi atau instruksi lengkap notifikasi..."
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                className="w-full bg-surface border border-navy-100 rounded-2xl px-4 py-2.5 text-xs text-navy-900 placeholder:text-navy-300 focus:outline-none focus:border-navy-500 focus:ring-1 focus:ring-navy-500 transition-all font-light resize-none leading-relaxed"
              />
            </div>

            {/* Kirim Button */}
            <button
              type="submit"
              disabled={actionLoading}
              className="mt-2 w-full flex items-center justify-center gap-2 bg-navy-900 hover:bg-navy-850 text-white rounded-2xl py-3 text-xs font-bold transition-all hover:scale-[1.01] active:scale-[0.99] cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {actionLoading ? (
                <div className="h-4 w-4 rounded-full border-2 border-white/20 border-t-white animate-spin" />
              ) : (
                <>
                  <Send className="h-4 w-4" />
                  Kirim Notifikasi Real-Time
                </>
              )}
            </button>
          </form>
        </div>

        {/* Riwayat Pengiriman */}
        <div className="lg:col-span-7 bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-4 min-h-[500px]">
          <div className="flex items-center justify-between border-b border-navy-50 pb-4">
            <h2 className="text-base font-bold text-navy-900">Riwayat Pengiriman Siaran</h2>
            <span className="text-[10px] bg-navy-50 text-navy-600 px-2.5 py-1 rounded-full font-bold uppercase tracking-wider">
              {broadcastLogs.length} Terkirim
            </span>
          </div>

          <div className="flex-1 overflow-y-auto max-h-[550px] pr-1 flex flex-col gap-3.5">
            {broadcastLogs.length === 0 ? (
              <div className="flex-1 flex flex-col items-center justify-center text-center p-8">
                <div className="h-12 w-12 rounded-2xl bg-surface flex items-center justify-center text-navy-300 border border-navy-100/50 mb-3">
                  <Bell className="h-5 w-5" />
                </div>
                <p className="text-xs font-bold text-navy-800">Belum Ada Notifikasi Terkirim</p>
                <p className="text-[11px] text-navy-400 font-light mt-1 max-w-[280px]">
                  Pemberitahuan yang dikirim oleh administrator akan tercatat di panel riwayat ini secara kronologis.
                </p>
              </div>
            ) : (
              broadcastLogs.map((log) => (
                <div
                  key={log.id}
                  className="bg-surface rounded-2xl p-4 border border-navy-100/30 flex flex-col gap-3 hover:border-navy-100 hover:shadow-sm transition-all"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <div className="p-1.5 rounded-lg bg-white border border-navy-100/45">
                        {getCategoryIcon(log.category)}
                      </div>
                      <div>
                        <h4 className="text-xs font-bold text-navy-900 line-clamp-1">{log.title}</h4>
                        <span className="text-[10px] text-navy-400 font-light">
                          {new Date(log.created_at).toLocaleString("id-ID", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                          })}
                        </span>
                      </div>
                    </div>

                    <span className={`text-[9px] font-bold px-2 py-0.5 rounded-md ${
                      log.target === "all"
                        ? "bg-navy-50 text-navy-600 border border-navy-100/50"
                        : "bg-gold-50 text-gold border border-gold-100/50 font-mono"
                    }`}>
                      {log.target === "all" ? "GLOBAL" : `Target: ${log.target}`}
                    </span>
                  </div>

                  <p className="text-[11px] text-navy-600 font-light leading-relaxed pl-1 whitespace-pre-line">
                    {log.message}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
