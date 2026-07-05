"use client";

import React, { useState } from "react";
import {
  Search,
  Award,
  Trash2,
  X,
  UserCheck,
  UserX,
  Plus,
  ShieldAlert,
  ShieldCheck,
  Sparkles,
  Sliders
} from "lucide-react";
import { UserProfile } from "./OverviewTab";

interface Badge {
  id: string;
  code: string;
  title: string;
  description: string;
  image_url?: string;
}

interface ProfilesTabProps {
  profiles: UserProfile[];
  badges: Badge[];
  bannedUserIds: string[];
  profileSearch: string;
  setProfileSearch: (search: string) => void;
  selectedProfile: UserProfile | null;
  setSelectedProfile: (profile: UserProfile | null) => void;
  isAdjustGamifyOpen: boolean;
  setIsAdjustGamifyOpen: (open: boolean) => void;
  adjustXp: number;
  showToast?: (message: string, type: "success" | "error" | "info") => void;
  setAdjustXp: (xp: number) => void;
  adjustLevel: number;
  setAdjustLevel: (level: number) => void;
  adjustStreak: number;
  setAdjustStreak: (streak: number) => void;
  handleAdjustGamification: () => void;
  isAwardBadgeOpen: boolean;
  setIsAwardBadgeOpen: (open: boolean) => void;
  badgeToAward: string;
  setBadgeToAward: (code: string) => void;
  handleAwardBadge: () => void;
  handleRevokeBadge: (profileId: string, badgeCode: string) => void;
  handleDeleteUserProfile: (profileId: string) => void;
  handleToggleBan: (profileId: string) => Promise<void>;
  handleCreateBadge: (code: string, title: string, description: string) => Promise<void>;
  handleDeleteBadge: (id: string) => Promise<void>;
  actionLoading: boolean;
  theme?: "light" | "dark";
}

export default function ProfilesTab({
  profiles,
  badges,
  bannedUserIds,
  profileSearch,
  setProfileSearch,
  selectedProfile,
  setSelectedProfile,
  isAdjustGamifyOpen,
  setIsAdjustGamifyOpen,
  adjustXp,
  setAdjustXp,
  adjustLevel,
  setAdjustLevel,
  adjustStreak,
  setAdjustStreak,
  handleAdjustGamification,
  isAwardBadgeOpen,
  setIsAwardBadgeOpen,
  badgeToAward,
  setBadgeToAward,
  handleAwardBadge,
  handleRevokeBadge,
  handleDeleteUserProfile,
  handleToggleBan,
  handleCreateBadge,
  handleDeleteBadge,
  actionLoading,
  theme = "light",
  showToast
}: ProfilesTabProps) {
  // In-UI Custom Confirm Modal State
  const [confirmModal, setConfirmModal] = useState<{
    isOpen: boolean;
    title: string;
    message: string;
    confirmText: string; // text required to type
    theme: "danger" | "warning";
    onConfirm: () => void;
  } | null>(null);

  const [typeVerify, setTypeVerify] = useState("");
  const [validationError, setValidationError] = useState("");

  // Create badge form states
  const [newBadgeCode, setNewBadgeCode] = useState("");
  const [newBadgeTitle, setNewBadgeTitle] = useState("");
  const [newBadgeDesc, setNewBadgeDesc] = useState("");
  const [isCreateBadgeOpen, setIsCreateBadgeOpen] = useState(false);
  const isDark = theme === "dark";

  const triggerCustomConfirm = (
    title: string,
    message: string,
    confirmText: string,
    modalTheme: "danger" | "warning",
    onConfirm: () => void
  ) => {
    setTypeVerify("");
    setValidationError("");
    setConfirmModal({
      isOpen: true,
      title,
      message,
      confirmText,
      theme: modalTheme,
      onConfirm
    });
  };

  const executeConfirmAction = () => {
    if (!confirmModal) return;
    if (confirmModal.confirmText && typeVerify.toUpperCase() !== confirmModal.confirmText.toUpperCase()) {
      setValidationError(`Kata verifikasi tidak cocok! Harap ketik "${confirmModal.confirmText}".`);
      return;
    }
    setValidationError("");
    confirmModal.onConfirm();
    setConfirmModal(null);
  };

  const onCreateBadgeSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newBadgeCode || !newBadgeTitle || !newBadgeDesc) return;
    await handleCreateBadge(newBadgeCode, newBadgeTitle, newBadgeDesc);
    setNewBadgeCode("");
    setNewBadgeTitle("");
    setNewBadgeDesc("");
    setIsCreateBadgeOpen(false);
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      
      {/* Header section with search */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className={`text-2xl font-bold tracking-tight ${isDark ? "text-white" : "text-slate-900"}`}>
            Manajemen Kontrol Warga Genesis.id
          </h1>
          <p className={`text-xs font-light mt-1.5 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
            Kontrol absolut atas penangguhan warga pelanggar (Ban), pemberian/pencabutan lencana, dan penyesuaian gamifikasi.
          </p>
        </div>

        {/* Search citizens bar */}
        <div className="relative">
          <Search className={`absolute left-3.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 ${isDark ? "text-slate-500" : "text-slate-400"}`} />
          <input
            type="text"
            placeholder="Cari warga/username..."
            value={profileSearch}
            onChange={(e) => setProfileSearch(e.target.value)}
            className={`border rounded-xl pl-9 pr-4 py-2 text-xs focus:outline-none transition-colors w-52 shadow-sm ${
              isDark 
                ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700 placeholder:text-zinc-500" 
                : "bg-white border-slate-200 text-slate-800 focus:border-slate-350 focus:bg-slate-50/50"
            }`}
          />
        </div>
      </div>

      {/* Profiles Data Table Container */}
      <div className={`rounded-3xl border overflow-hidden shadow-sm ${
        isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
      }`}>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-left text-xs">
            <thead>
              <tr className={`border-b select-none font-bold uppercase text-[10px] tracking-wider ${
                isDark ? "bg-zinc-900/40 border-zinc-900 text-zinc-450" : "bg-slate-50 border-slate-150 text-slate-500"
              }`}>
                <th className="p-4 pl-6">Profil Warga</th>
                <th className="p-4">Domisili</th>
                <th className="p-4">Level & XP</th>
                <th className="p-4">Streak</th>
                <th className="p-4">Lencana Diperoleh</th>
                <th className="p-4 pr-6 text-right font-bold">Otoritas Aksi</th>
              </tr>
            </thead>
            <tbody className={`divide-y ${isDark ? "divide-zinc-900" : "divide-slate-100"}`}>
              {profiles
                .filter((p) => {
                  const text = (p.full_name || p.username || "").toLowerCase();
                  return text.includes(profileSearch.toLowerCase());
                })
                .map((prof) => {
                  const isBanned = bannedUserIds.includes(prof.id);
                  return (
                    <tr key={prof.id} className={`transition-colors ${
                      isBanned 
                        ? isDark ? "bg-red-950/10 hover:bg-red-950/20" : "bg-red-50/30 hover:bg-red-50/50"
                        : isDark ? "hover:bg-zinc-900/40" : "hover:bg-slate-50/50"
                    }`}>
                      
                      {/* 1. Profile avatar & metadata */}
                      <td className="p-4 pl-6">
                        <div className="flex items-center gap-3">
                          <div className={`h-9 w-9 rounded-full flex items-center justify-center font-bold border shrink-0 ${
                            isBanned 
                              ? "bg-red-950/30 text-red-400 border-red-900/40" 
                              : isDark 
                                ? "bg-zinc-800 text-zinc-300 border-zinc-700/60" 
                                : "bg-slate-100 text-slate-800 border-slate-200"
                          }`}>
                            {prof.username.charAt(0).toUpperCase()}
                          </div>
                          <div className="flex flex-col">
                            <div className="flex items-center gap-2">
                              <span className="font-bold">{prof.full_name || prof.username}</span>
                              {isBanned && (
                                <span className="text-[8px] bg-red-600 text-white font-extrabold px-1.5 py-0.5 rounded shadow-sm animate-pulse uppercase tracking-wider">
                                  BANNED
                                </span>
                              )}
                            </div>
                            <span className={`text-[10px] font-mono mt-0.5 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>ID: {prof.id}</span>
                          </div>
                        </div>
                      </td>

                      {/* 2. City & Province */}
                      <td className={`p-4 font-medium ${isDark ? "text-zinc-300" : "text-slate-650"}`}>
                        <div className="flex flex-col">
                          <span>{prof.city_or_district || "Anonim"}</span>
                          <span className={`text-[10px] font-normal ${isDark ? "text-zinc-500" : "text-slate-400"}`}>{prof.province || "N/A"}</span>
                        </div>
                      </td>

                      {/* 3. Level & XP Progress Indicator */}
                      <td className="p-4">
                        <div className="flex flex-col gap-1.5 max-w-[130px]">
                          <div className="flex items-center justify-between text-[10px] font-semibold">
                            <span className={isDark ? "text-zinc-400" : "text-slate-500"}>Level {prof.level || 1}</span>
                            <span className="font-mono">{prof.xp || 0} XP</span>
                          </div>
                          {/* Progress Bar */}
                          <div className={`h-1.5 w-full rounded-full overflow-hidden ${isDark ? "bg-zinc-900" : "bg-slate-100"}`}>
                            <div 
                              className="h-full bg-emerald-500 rounded-full" 
                              style={{ width: `${Math.min(((prof.xp || 0) % 100), 100)}%` }} 
                            />
                          </div>
                        </div>
                      </td>

                      {/* 4. Streaks */}
                      <td className="p-4">
                        <div className="flex items-center gap-1">
                          <span className="font-extrabold text-amber-500">{prof.current_streak || 0}</span>
                          <span className={`text-[10px] ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Hari</span>
                        </div>
                      </td>

                      {/* 5. Awarded Badges List */}
                      <td className="p-4">
                        <div className="flex flex-wrap items-center gap-1.5 max-w-[240px]">
                          {(prof.badges || []).length === 0 ? (
                            <span className={`text-[10px] font-medium italic ${isDark ? "text-zinc-650" : "text-slate-400"}`}>Belum ada lencana</span>
                          ) : (
                            (prof.badges || []).map((b) => (
                              <span 
                                key={b.code}
                                className={`group relative inline-flex items-center gap-1 border px-2 py-0.5 rounded-full text-[9px] font-bold select-none cursor-help transition-all ${
                                  isDark 
                                    ? "bg-zinc-900 border-zinc-800 text-zinc-300 hover:bg-zinc-850" 
                                    : "bg-slate-50 border-slate-200 text-slate-655 hover:bg-slate-100"
                                }`}
                              >
                                <Award className="h-2.5 w-2.5 text-amber-500" />
                                {b.title}
                                
                                {/* Action Revoke Button inside hover badge */}
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    triggerCustomConfirm(
                                      "Copot Lencana Warga",
                                      `Apakah Anda yakin ingin mencopot lencana "${b.title}" dari warga ${prof.full_name || prof.username}?`,
                                      "COPOT",
                                      "warning",
                                      () => handleRevokeBadge(prof.id, b.code)
                                    );
                                  }}
                                  className="ml-0.5 h-3.5 w-3.5 rounded-full flex items-center justify-center text-red-500 hover:bg-red-550/20 cursor-pointer"
                                  title="Copot Lencana"
                                >
                                  <X className="h-2.5 w-2.5" />
                                </button>
                              </span>
                            ))
                          )}
                        </div>
                      </td>

                      {/* 6. Administrative Actions */}
                      <td className="p-4 pr-6 text-right">
                        <div className="flex items-center gap-1.5 justify-end">
                          
                          {/* Award Badge Button */}
                          <button
                            onClick={() => {
                              setSelectedProfile(prof);
                              setIsAwardBadgeOpen(true);
                            }}
                            className={`p-2 rounded-lg border transition-colors cursor-pointer shadow-sm ${
                              isDark 
                                ? "border-zinc-800 bg-zinc-900 text-zinc-350 hover:bg-zinc-800" 
                                : "border-slate-200 bg-white text-slate-600 hover:bg-slate-50"
                            }`}
                            title="Sematkan Lencana Prestasi"
                          >
                            <Award className="h-3.5 w-3.5" />
                          </button>

                          {/* Adjust Gamify (XP, Lvl) Button */}
                          <button
                            onClick={() => {
                              setSelectedProfile(prof);
                              setAdjustXp(prof.xp || 0);
                              setAdjustLevel(prof.level || 1);
                              setAdjustStreak(prof.current_streak || 0);
                              setIsAdjustGamifyOpen(true);
                            }}
                            className={`p-2 rounded-lg border transition-colors cursor-pointer shadow-sm ${
                              isDark 
                                ? "border-zinc-800 bg-zinc-900 text-zinc-350 hover:bg-zinc-800" 
                                : "border-slate-200 bg-white text-slate-600 hover:bg-slate-50"
                            }`}
                            title="Koreksi Nilai Gamifikasi"
                          >
                            <Sliders className="h-3.5 w-3.5" />
                          </button>

                          {/* Suspensi (Ban) User Toggle */}
                          <button
                            onClick={() => triggerCustomConfirm(
                              isBanned ? "Lepas Suspensi Akun" : "Suspensikan Warga",
                              isBanned 
                                ? `Lepas pemblokiran untuk akun warga ${prof.full_name || prof.username} agar dapat beraktivitas kembali?`
                                : `⚠️ PERINGATAN CRITICAL: Memblokir warga ${prof.full_name || prof.username} akan menjeda seluruh partisipasi pelaporan, klaim hadiah, dan aktivitas crowdsourcing miliknya.`,
                              isBanned ? "LEPAS" : "SUSPENSI",
                              isBanned ? "warning" : "danger",
                              () => handleToggleBan(prof.id)
                            )}
                            className={`p-2 rounded-lg border transition-colors cursor-pointer shadow-sm ${
                              isBanned
                                ? "border-emerald-600 bg-emerald-500/10 text-emerald-500 hover:bg-emerald-650/20"
                                : isDark
                                  ? "border-amber-900/50 bg-amber-950/15 text-amber-500 hover:bg-amber-900/30"
                                  : "border-amber-200 bg-amber-50 text-amber-600 hover:bg-amber-600 hover:text-white"
                            }`}
                            title={isBanned ? "Lepas Suspensi Akun" : "Suspensikan Akun Warga"}
                          >
                            {isBanned ? <UserCheck className="h-3.5 w-3.5" /> : <UserX className="h-3.5 w-3.5" />}
                          </button>

                          {/* Absolute deletion */}
                          <button
                            onClick={() => triggerCustomConfirm(
                              "Hapus Akun Pengguna Absolut",
                              `⚠️ PERINGATAN FATAL: Menghapus profil warga ${prof.full_name || prof.username} bersifat permanen & melenyapkan seluruh auth beserta database miliknya secara tuntas!`,
                              "HAPUS",
                              "danger",
                              () => handleDeleteUserProfile(prof.id)
                            )}
                            className={`p-2 rounded-lg border transition-colors cursor-pointer shadow-sm ${
                              isDark 
                                ? "border-red-950 bg-red-950/20 text-red-400 hover:bg-red-900/30" 
                                : "border-red-100 bg-white text-red-500 hover:bg-red-50 hover:border-red-200"
                            }`}
                            title="Hapus Akun User Permanen"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </button>

                        </div>
                      </td>
                    </tr>
                  );
                })}
            </tbody>
          </table>
        </div>
      </div>

      {/* --- BADGE CATALOG CRUD MANAGER --- */}
      <div className={`rounded-3xl p-6 border shadow-sm flex flex-col gap-6 ${
        isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
      }`}>
        <div className={`flex items-center justify-between border-b pb-4 ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
          <div className="flex items-center gap-2.5">
            <div className={`h-8 w-8 rounded-lg flex items-center justify-center border ${
              isDark ? "bg-zinc-900 border-zinc-800 text-gold" : "bg-gold-50 border-gold-100 text-gold"
            }`}>
              <Award className="h-4.5 w-4.5" />
            </div>
            <div>
              <h2 className="text-base font-bold">Katalog Lencana Prestasi Kota</h2>
              <p className={`text-[10px] font-light mt-0.5 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Sematkan atau rilis jenis lencana ke sistem crowdsourcing.</p>
            </div>
          </div>

          <button
            onClick={() => setIsCreateBadgeOpen(!isCreateBadgeOpen)}
            className={`flex items-center gap-1 rounded-xl px-3.5 py-2 text-xs font-bold transition-all cursor-pointer ${
              isDark ? "bg-zinc-800 hover:bg-zinc-700 text-white" : "bg-slate-900 text-white hover:bg-slate-850"
            }`}
          >
            <Plus className="h-3.5 w-3.5" />
            Rilis Lencana Baru
          </button>
        </div>

        {/* Create Badge Form Collapse Drawer */}
        {isCreateBadgeOpen && (
          <form onSubmit={onCreateBadgeSubmit} className={`rounded-2xl p-5 border grid grid-cols-1 md:grid-cols-3 gap-4 items-end animate-fade-down ${
            isDark ? "bg-zinc-900 border-zinc-800" : "bg-slate-50 border-slate-150"
          }`}>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeCode" className={`text-[11px] font-bold ${isDark ? "text-zinc-400" : "text-slate-500"}`}>Kode Lencana Unik (Sebab Relasi)</label>
              <input
                id="badgeCode"
                type="text"
                required
                placeholder="Contoh: green_pioneer"
                value={newBadgeCode}
                onChange={(e) => setNewBadgeCode(e.target.value)}
                className={`w-full border rounded-xl py-2 px-3.5 text-xs focus:outline-none transition-all font-mono ${
                  isDark ? "bg-zinc-950 border-zinc-850 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeTitle" className={`text-[11px] font-bold ${isDark ? "text-zinc-400" : "text-slate-500"}`}>Nama Lencana Prestasi</label>
              <input
                id="badgeTitle"
                type="text"
                required
                placeholder="Contoh: Pelopor Hijau"
                value={newBadgeTitle}
                onChange={(e) => setNewBadgeTitle(e.target.value)}
                className={`w-full border rounded-xl py-2 px-3.5 text-xs focus:outline-none transition-all font-bold ${
                  isDark ? "bg-zinc-950 border-zinc-850 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeDesc" className={`text-[11px] font-bold ${isDark ? "text-zinc-400" : "text-slate-500"}`}>Deskripsi / Cara Mendapatkannya</label>
              <input
                id="badgeDesc"
                type="text"
                required
                placeholder="Menyelesaikan aksi penanganan B3..."
                value={newBadgeDesc}
                onChange={(e) => setNewBadgeDesc(e.target.value)}
                className={`w-full border rounded-xl py-2 px-3.5 text-xs focus:outline-none transition-all font-light ${
                  isDark ? "bg-zinc-950 border-zinc-850 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-900 focus:border-slate-350"
                }`}
              />
            </div>
            <div className="md:col-span-3 flex justify-end gap-2.5 mt-2">
              <button
                type="button"
                onClick={() => setIsCreateBadgeOpen(false)}
                className={`px-4 py-2 border text-xs font-bold rounded-xl transition-all cursor-pointer ${
                  isDark ? "bg-zinc-950 border-zinc-850 text-zinc-400 hover:bg-zinc-800" : "bg-slate-100 border-slate-200 hover:bg-slate-200 text-slate-600"
                }`}
              >
                Batal
              </button>
              <button
                type="submit"
                disabled={actionLoading}
                className={`px-5 py-2 text-xs font-bold rounded-xl transition-all shadow-sm cursor-pointer text-white ${
                  isDark ? "bg-zinc-800 hover:bg-zinc-700" : "bg-slate-900 hover:bg-slate-850"
                }`}
              >
                Daftarkan ke Katalog
              </button>
            </div>
          </form>
        )}

        {/* Badge Cards List */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {badges.map((b) => {
            return (
              <div
                key={b.id}
                className={`rounded-2xl p-4.5 border transition-all flex items-start gap-4 ${
                  isDark ? "bg-zinc-900/40 border-zinc-800/80 hover:border-zinc-750" : "bg-slate-50 border-slate-150 hover:border-slate-200 hover:shadow-sm"
                }`}
              >
                <div className={`h-10 w-10 rounded-xl border flex items-center justify-center shrink-0 ${
                  isDark ? "bg-zinc-900 border-zinc-800 text-gold" : "bg-gold-50/50 border-gold-200/40 text-gold"
                }`}>
                  <Sparkles className="h-5 w-5" />
                </div>
                <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                  <div>
                    <div className="flex items-start justify-between gap-2">
                      <h4 className={`text-xs font-bold truncate ${isDark ? "text-slate-100" : "text-slate-800"}`}>{b.title}</h4>
                      <button
                        onClick={() => triggerCustomConfirm(
                          "Hapus Lencana Katalog",
                          `⚠️ PERINGATAN: Menghapus lencana "${b.title}" dari katalog akan menghapus referensi bagi seluruh warga yang memilikinya!`,
                          "HAPUS",
                          "danger",
                          () => handleDeleteBadge(b.id)
                        )}
                        className={`p-1.5 rounded-lg cursor-pointer transition-all shrink-0 ${
                          isDark ? "text-red-400 hover:bg-red-950/20" : "text-red-500 hover:bg-red-50"
                        }`}
                        title="Hapus dari Katalog"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                    <span className={`text-[9px] font-mono tracking-wider font-bold uppercase mt-0.5 block ${isDark ? "text-zinc-500" : "text-slate-400"}`}>{b.code}</span>
                    <p className={`text-[10px] font-light leading-relaxed mt-2 line-clamp-2 ${isDark ? "text-zinc-400" : "text-slate-500"}`}>{b.description}</p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* --- IN-UI CUSTOM CONFIRMATION MODAL (Glassmorphic) --- */}
      {confirmModal && confirmModal.isOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className={`w-full max-w-sm border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center max-h-[90vh] overflow-y-auto ${
            isDark ? "bg-zinc-950 border-zinc-800 text-white" : "bg-white/95 text-slate-800 border-slate-200"
          }`}>
            
            {/* Header Icon Indicator */}
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center border animate-bounce shadow-sm bg-red-50 border-red-100 text-red-655">
              <ShieldAlert className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">{confirmModal.title}</h3>
              <p className={`text-xs font-light leading-relaxed mt-2 whitespace-pre-line ${isDark ? "text-zinc-400" : "text-slate-500"}`}>
                {confirmModal.message}
              </p>
            </div>

            {/* Type verification prompt */}
            {confirmModal.confirmText && (
              <div className="flex flex-col gap-2 animate-fade-in">
                <label htmlFor="verifyInput" className={`text-[10px] font-extrabold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-450"}`}>
                  Ketik <strong className={isDark ? "text-slate-100" : "text-slate-900"}>"{confirmModal.confirmText}"</strong> untuk menyetujui
                </label>
                <input
                  id="verifyInput"
                  type="text"
                  placeholder="Ketik kata verifikasi..."
                  value={typeVerify}
                  onChange={(e) => setTypeVerify(e.target.value)}
                  className={`w-full border rounded-xl py-2 px-3 text-center text-xs font-black tracking-widest focus:outline-none transition-all ${
                    isDark 
                      ? "bg-zinc-900 border-zinc-850 text-white focus:border-zinc-700" 
                      : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350"
                  }`}
                />
                {validationError && (
                  <p className="text-[10px] font-bold text-red-500 animate-fade-in mt-1 select-none text-center">
                    {validationError}
                  </p>
                )}
              </div>
            )}

            {/* Actions button list */}
            <div className={`flex flex-col-reverse sm:flex-row items-center gap-3 pt-4 border-t w-full ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <button
                onClick={() => setConfirmModal(null)}
                className={`w-full sm:w-1/2 rounded-xl border py-2.5 text-xs font-bold transition-all cursor-pointer ${
                  isDark 
                    ? "bg-zinc-900 border-zinc-850 text-zinc-400 hover:bg-zinc-800" 
                    : "bg-slate-100 border-slate-200 text-slate-600 hover:bg-slate-200 hover:text-slate-900"
                }`}
              >
                Batal
              </button>
              <button
                onClick={executeConfirmAction}
                disabled={confirmModal.confirmText !== undefined && typeVerify.toUpperCase() !== confirmModal.confirmText.toUpperCase()}
                className={`w-full sm:w-1/2 rounded-xl py-2.5 text-xs font-bold text-white transition-all cursor-pointer shadow-sm disabled:opacity-30 disabled:cursor-not-allowed ${
                  confirmModal.theme === "danger" 
                    ? "bg-red-600 hover:bg-red-700" 
                    : "bg-amber-600 hover:bg-amber-700"
                }`}
              >
                Eksekusi Mutlak
              </button>
            </div>

          </div>
        </div>
      )}

      {/* MODAL: EDIT GAMIFICATION VALUES */}
      {isAdjustGamifyOpen && selectedProfile && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className={`w-full max-w-sm border rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 max-h-[90vh] overflow-y-auto ${
            isDark ? "bg-zinc-950 border-zinc-800 text-white" : "bg-white border-slate-200 text-slate-850"
          }`}>
            
            <div className={`border-b pb-3 select-none ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <h3 className="text-base font-bold">Koreksi Gamifikasi Warga</h3>
              <p className={`text-[11px] mt-1 ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Edit XP, Level, dan Streak untuk {selectedProfile.full_name || selectedProfile.username}.</p>
            </div>

            <div className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className={`text-[11px] font-bold select-none ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Experience Points (XP)</label>
                <input
                  type="number"
                  value={adjustXp}
                  onChange={(e) => setAdjustXp(parseInt(e.target.value) || 0)}
                  className={`w-full border rounded-xl py-2 px-3 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-900 border-zinc-850 text-white focus:border-zinc-700" : "bg-slate-50/50 border-slate-200 text-slate-900 focus:border-slate-350"
                  }`}
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <label className={`text-[11px] font-bold select-none ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Level Warga</label>
                <input
                  type="number"
                  value={adjustLevel}
                  onChange={(e) => setAdjustLevel(parseInt(e.target.value) || 1)}
                  className={`w-full border rounded-xl py-2 px-3 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-900 border-zinc-850 text-white focus:border-zinc-700" : "bg-slate-50/50 border-slate-200 text-slate-900 focus:border-slate-350"
                  }`}
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <label className={`text-[11px] font-bold select-none ${isDark ? "text-zinc-450" : "text-slate-500"}`}>Current Daily Streak (Hari)</label>
                <input
                  type="number"
                  value={adjustStreak}
                  onChange={(e) => setAdjustStreak(parseInt(e.target.value) || 0)}
                  className={`w-full border rounded-xl py-2 px-3 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-900 border-zinc-850 text-white focus:border-zinc-700" : "bg-slate-50/50 border-slate-200 text-slate-900 focus:border-slate-350"
                  }`}
                />
              </div>
            </div>

            <div className={`flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-end gap-2.5 pt-4 border-t w-full ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <button
                onClick={() => setIsAdjustGamifyOpen(false)}
                className={`w-full sm:w-auto rounded-xl px-4 py-2.5 text-xs font-semibold border transition-all cursor-pointer ${
                  isDark ? "bg-zinc-900 border-zinc-850 text-zinc-400 hover:bg-zinc-800" : "bg-slate-100 border-slate-200 hover:bg-slate-200 text-slate-655"
                }`}
              >
                Batal
              </button>
              <button
                onClick={handleAdjustGamification}
                disabled={actionLoading}
                className={`w-full sm:w-auto rounded-xl px-4 py-2.5 text-xs font-semibold transition-all shadow-sm cursor-pointer text-white ${
                  isDark ? "bg-zinc-800 hover:bg-zinc-700" : "bg-slate-900 hover:bg-slate-850"
                }`}
              >
                Terapkan Koreksi
              </button>
            </div>

          </div>
        </div>
      )}

      {/* MODAL: AWARD NEW PRESTIGE BADGE */}
      {isAwardBadgeOpen && selectedProfile && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className={`w-full max-w-sm border rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 max-h-[90vh] overflow-y-auto ${
            isDark ? "bg-zinc-950 border-zinc-800 text-white" : "bg-white border-slate-200 text-slate-850"
          }`}>
            
            <div className={`border-b pb-3 select-none ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <h3 className="text-base font-bold">Sematkan Lencana Baru</h3>
              <p className={`text-[11px] mt-1 ${isDark ? "text-zinc-500" : "text-slate-550"}`}>Pilih lencana prestasi untuk disematkan pada {selectedProfile.full_name || selectedProfile.username}.</p>
            </div>

            <div className="flex flex-col gap-1.5">
              <label className={`text-[11px] font-bold select-none ${isDark ? "text-zinc-450" : "text-slate-550"}`}>Lencana Tersedia</label>
              <select
                value={badgeToAward}
                onChange={(e) => setBadgeToAward(e.target.value)}
                className={`w-full border rounded-xl py-2 px-3 text-xs focus:outline-none transition-all cursor-pointer font-medium ${
                  isDark ? "bg-zinc-900 border-zinc-850 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-800 focus:border-slate-350"
                }`}
              >
                <option value="">-- Pilih Lencana --</option>
                {badges.map((b) => (
                  <option key={b.code} value={b.code}>
                    {b.title} - {b.description}
                  </option>
                ))}
              </select>
            </div>

            <div className={`flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-end gap-2.5 pt-4 border-t w-full ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
              <button
                onClick={() => setIsAwardBadgeOpen(false)}
                className={`w-full sm:w-auto rounded-xl px-4 py-2.5 text-xs font-semibold border transition-all cursor-pointer ${
                  isDark ? "bg-zinc-900 border-zinc-850 text-zinc-400 hover:bg-zinc-800" : "bg-slate-100 border-slate-200 hover:bg-slate-200 text-slate-655"
                }`}
              >
                Batal
              </button>
              <button
                onClick={handleAwardBadge}
                disabled={actionLoading || !badgeToAward}
                className="w-full sm:w-auto rounded-xl bg-amber-500 hover:bg-amber-600 text-white px-4 py-2.5 text-xs font-semibold transition-all cursor-pointer shadow-sm"
              >
                Sematkan Lencana
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
