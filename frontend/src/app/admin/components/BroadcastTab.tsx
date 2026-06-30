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
  theme?: "light" | "dark";
}

export default function BroadcastTab({
  broadcastLogs,
  handleSendBroadcast,
  actionLoading,
  theme = "light"
}: BroadcastTabProps) {
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [category, setCategory] = useState<"info" | "alert" | "event" | "quest">("info");
  const [targetType, setTarget] = useState<"all" | "user">("all");
  const [specificUserId, setSpecificUserId] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const isDark = theme === "dark";

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
        return <AlertTriangle className="h-4 w-4 text-rose-500" />;
      case "event":
        return <Calendar className="h-4 w-4 text-blue-500" />;
      case "quest":
        return <Award className="h-4 w-4 text-amber-500" />;
      default:
        return <Info className="h-4 w-4 text-slate-500" />;
    }
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      {/* Header */}
      <div>
        <h1 className={`text-2xl font-bold tracking-tight ${isDark ? "text-white" : "text-slate-900"}`}>
          Pusat Siaran Notifikasi (Broadcast Center)
        </h1>
        <p className={`text-xs font-light mt-1.5 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
          Kirim pengumuman penting, peringatan darurat, info event kota, atau info tantangan langsung ke aplikasi Flutter warga.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Formulir Pengiriman */}
        <div className={`lg:col-span-5 rounded-3xl p-6 border shadow-sm ${
          isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
        }`}>
          <div className={`flex items-center gap-2.5 border-b pb-4 mb-6 ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
            <div className={`h-8 w-8 rounded-lg flex items-center justify-center border ${
              isDark ? "bg-zinc-900 border-zinc-800 text-slate-300" : "bg-slate-50 border-slate-200 text-slate-700"
            }`}>
              <Bell className="h-4.5 w-4.5" />
            </div>
            <h2 className="text-base font-bold">Kirim Notifikasi Baru</h2>
          </div>

          <form onSubmit={onSubmit} className="flex flex-col gap-5">
            {successMsg && (
              <div className="p-3.5 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex items-center gap-2.5 text-emerald-500 text-xs font-medium animate-fade-in">
                <CheckCircle className="h-4 w-4 shrink-0" />
                <span>{successMsg}</span>
              </div>
            )}

            {/* Target Penerima */}
            <div>
              <label className={`block text-[11px] font-bold uppercase tracking-wider mb-2 ${isDark ? "text-zinc-400" : "text-slate-550"}`}>Target Penerima</label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setTarget("all")}
                  className={`flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border text-xs font-semibold transition-all cursor-pointer ${
                    targetType === "all"
                      ? isDark 
                        ? "bg-zinc-850 text-white border-zinc-800 shadow-sm"
                        : "bg-slate-900 text-white border-slate-900 shadow-sm"
                      : isDark
                        ? "bg-zinc-900/40 text-zinc-400 border-zinc-850 hover:bg-zinc-900/80"
                        : "bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100/50"
                  }`}
                >
                  <Users className="h-3.5 w-3.5" />
                  Semua Warga (Global)
                </button>
                <button
                  type="button"
                  onClick={() => setTarget("user")}
                  className={`flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border text-xs font-semibold transition-all cursor-pointer ${
                    targetType === "user"
                      ? isDark 
                        ? "bg-zinc-850 text-white border-zinc-800 shadow-sm"
                        : "bg-slate-900 text-white border-slate-900 shadow-sm"
                      : isDark
                        ? "bg-zinc-900/40 text-zinc-400 border-zinc-855 hover:bg-zinc-900/80"
                        : "bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100/50"
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
                <label htmlFor="userId" className={`block text-[11px] font-bold uppercase tracking-wider mb-1.5 ${isDark ? "text-zinc-450" : "text-slate-500"}`}>ID Profil Warga</label>
                <input
                  id="userId"
                  type="text"
                  required
                  placeholder="Contoh: usr-01 atau UUID Supabase"
                  value={specificUserId}
                  onChange={(e) => setSpecificUserId(e.target.value)}
                  className={`w-full border rounded-2xl px-4 py-2.5 text-xs focus:outline-none transition-all font-mono ${
                    isDark 
                      ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700" 
                      : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350"
                  }`}
                />
              </div>
            )}

            {/* Kategori Notifikasi */}
            <div>
              <label htmlFor="category" className={`block text-[11px] font-bold uppercase tracking-wider mb-1.5 ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Kategori Pesan</label>
              <select
                id="category"
                value={category}
                onChange={(e) => setCategory(e.target.value as any)}
                className={`w-full border rounded-2xl px-4 py-2.5 text-xs focus:outline-none transition-all cursor-pointer font-medium appearance-none ${
                  isDark
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700"
                    : "bg-slate-50 border-slate-200 text-slate-800 focus:border-slate-350"
                }`}
              >
                <option value="info">📢 Informasi & Pengumuman</option>
                <option value="alert">⚠️ Peringatan Darurat / Kritis</option>
                <option value="event">📅 Event Resmi Kota</option>
                <option value="quest">🏆 Misi Gamifikasi</option>
              </select>
            </div>

            {/* Judul Notifikasi */}
            <div>
              <label htmlFor="title" className={`block text-[11px] font-bold uppercase tracking-wider mb-1.5 ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Judul Siaran</label>
              <input
                id="title"
                type="text"
                required
                placeholder="Tulis judul pemberitahuan..."
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className={`w-full border rounded-2xl px-4 py-2.5 text-xs focus:outline-none transition-all font-semibold ${
                  isDark 
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700" 
                    : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>

            {/* Isi Pesan */}
            <div>
              <label htmlFor="message" className={`block text-[11px] font-bold uppercase tracking-wider mb-1.5 ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Isi Pesan Notifikasi</label>
              <textarea
                id="message"
                required
                rows={5}
                placeholder="Tulis deskripsi atau instruksi lengkap notifikasi..."
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                className={`w-full border rounded-2xl px-4 py-2.5 text-xs focus:outline-none transition-all font-light resize-none leading-relaxed ${
                  isDark 
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700" 
                    : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>

            {/* Kirim Button */}
            <button
              type="submit"
              disabled={actionLoading}
              className={`mt-2 w-full flex items-center justify-center gap-2 rounded-2xl py-3 text-xs font-bold transition-all hover:scale-[1.01] active:scale-[0.99] cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed text-white ${
                isDark ? "bg-zinc-800 hover:bg-zinc-700" : "bg-slate-900 hover:bg-slate-850"
              }`}
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
        <div className={`lg:col-span-7 rounded-3xl p-6 border shadow-sm flex flex-col gap-4 min-h-[500px] ${
          isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
        }`}>
          <div className={`flex items-center justify-between border-b pb-4 ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
            <h2 className="text-base font-bold">Riwayat Pengiriman Siaran</h2>
            <span className={`text-[10px] px-2.5 py-1 rounded-full font-bold uppercase tracking-wider ${
              isDark ? "bg-zinc-900 text-zinc-400 border border-zinc-800" : "bg-slate-50 text-slate-655 border border-slate-150"
            }`}>
              {broadcastLogs.length} Terkirim
            </span>
          </div>

          <div className="flex-1 overflow-y-auto max-h-[550px] pr-1 flex flex-col gap-3.5">
            {broadcastLogs.length === 0 ? (
              <div className="flex-1 flex flex-col items-center justify-center text-center p-8">
                <div className={`h-12 w-12 rounded-2xl flex items-center justify-center border mb-3 ${
                  isDark ? "bg-zinc-900 border-zinc-800 text-zinc-550" : "bg-slate-50 border-slate-150 text-slate-350"
                }`}>
                  <Bell className="h-5 w-5" />
                </div>
                <p className="text-xs font-bold">Belum Ada Notifikasi Terkirim</p>
                <p className={`text-[11px] font-light mt-1 max-w-[280px] ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
                  Pemberitahuan yang dikirim oleh administrator akan tercatat di panel riwayat ini secara kronologis.
                </p>
              </div>
            ) : (
              broadcastLogs.map((log) => (
                <div
                  key={log.id}
                  className={`rounded-2xl p-4 border flex flex-col gap-3 transition-all ${
                    isDark 
                      ? "bg-zinc-900/40 border-zinc-800/60 hover:border-zinc-750" 
                      : "bg-slate-50 border-slate-150 hover:border-slate-200 hover:shadow-sm"
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <div className={`p-1.5 rounded-lg border ${isDark ? "bg-zinc-950 border-zinc-850" : "bg-white border-slate-200"}`}>
                        {getCategoryIcon(log.category)}
                      </div>
                      <div>
                        <h4 className="text-xs font-bold line-clamp-1">{log.title}</h4>
                        <span className={`text-[10px] font-light ${isDark ? "text-zinc-500" : "text-slate-400"}`}>
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
                        ? isDark 
                          ? "bg-zinc-950 border border-zinc-850 text-zinc-400" 
                          : "bg-slate-100 text-slate-655 border border-slate-200"
                        : isDark
                          ? "bg-amber-500/10 text-amber-400 border border-amber-500/20 font-mono"
                          : "bg-amber-50 text-amber-700 border border-amber-200 font-mono"
                    }`}>
                      {log.target === "all" ? "GLOBAL" : `Target: ${log.target}`}
                    </span>
                  </div>

                  <p className={`text-[11px] font-light leading-relaxed pl-1 whitespace-pre-line ${isDark ? "text-zinc-400" : "text-slate-600"}`}>
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
