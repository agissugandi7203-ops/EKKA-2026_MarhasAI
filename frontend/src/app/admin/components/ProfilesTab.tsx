"use client";

import React, { useState } from "react";
import {
  Search,
  Sliders,
  Award,
  Trash2,
  X,
  UserCheck,
  UserX,
  Plus,
  ShieldAlert,
  ShieldCheck,
  BadgeAlert,
  Sparkles
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
  actionLoading
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

  // Create badge form states
  const [newBadgeCode, setNewBadgeCode] = useState("");
  const [newBadgeTitle, setNewBadgeTitle] = useState("");
  const [newBadgeDesc, setNewBadgeDesc] = useState("");
  const [isCreateBadgeOpen, setIsCreateBadgeOpen] = useState(false);

  const triggerCustomConfirm = (
    title: string,
    message: string,
    confirmText: string,
    theme: "danger" | "warning",
    onConfirm: () => void
  ) => {
    setTypeVerify("");
    setConfirmModal({
      isOpen: true,
      title,
      message,
      confirmText,
      theme,
      onConfirm
    });
  };

  const executeConfirmAction = () => {
    if (!confirmModal) return;
    if (confirmModal.confirmText && typeVerify.toUpperCase() !== confirmModal.confirmText.toUpperCase()) {
      alert(`Harap ketik "${confirmModal.confirmText}" untuk memverifikasi.`);
      return;
    }
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
    <div className="flex flex-col gap-8 animate-fade-up">
      
      {/* Header section with search */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-navy-900">Manajemen Kontrol Warga Genesis.id</h1>
          <p className="text-xs text-navy-500 font-light mt-1.5">
            Kontrol absolut atas penangguhan warga pelanggar (Ban), pemberian/pencabutan lencana, dan penyesuaian gamifikasi.
          </p>
        </div>

        {/* Search citizens bar */}
        <div className="relative">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-navy-400" />
          <input
            type="text"
            placeholder="Cari warga/username..."
            value={profileSearch}
            onChange={(e) => setProfileSearch(e.target.value)}
            className="bg-white border border-navy-100 rounded-xl pl-9 pr-4 py-2 text-xs text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-navy-50/30 transition-colors w-52 shadow-sm"
          />
        </div>
      </div>

      {/* Profiles Data Table Container */}
      <div className="bg-white rounded-3xl border border-navy-100 overflow-hidden shadow-[0_4px_24px_rgba(10,22,40,0.02)]">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-left text-xs">
            <thead>
              <tr className="border-b border-navy-100 bg-navy-50 select-none font-bold text-navy-500 uppercase text-[10px] tracking-wider">
                <th className="p-4 pl-6">Profil Warga</th>
                <th className="p-4">Domisili</th>
                <th className="p-4">Level & XP</th>
                <th className="p-4">Streak</th>
                <th className="p-4">Lencana Diperoleh</th>
                <th className="p-4 pr-6 text-right font-bold">Otoritas Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-navy-100">
              {profiles
                .filter((p) => {
                  const text = (p.full_name || p.username || "").toLowerCase();
                  return text.includes(profileSearch.toLowerCase());
                })
                .map((prof) => {
                  const isBanned = bannedUserIds.includes(prof.id);
                  return (
                    <tr key={prof.id} className={`hover:bg-navy-50/30 transition-colors ${isBanned ? "bg-red-50/10" : ""}`}>
                      
                      {/* 1. Profile avatar & metadata */}
                      <td className="p-4 pl-6">
                        <div className="flex items-center gap-3">
                          <div className={`h-9 w-9 rounded-full flex items-center justify-center font-bold border shrink-0 ${
                            isBanned 
                              ? "bg-red-100 text-red-700 border-red-200" 
                              : "bg-navy-100 text-navy-800 border-navy-200"
                          }`}>
                            {prof.username.charAt(0).toUpperCase()}
                          </div>
                          <div className="flex flex-col">
                            <div className="flex items-center gap-2">
                              <span className="font-bold text-navy-900">{prof.full_name || prof.username}</span>
                              {isBanned && (
                                <span className="text-[8px] bg-red-600 text-white font-extrabold px-1.5 py-0.5 rounded shadow-[0_0_10px_rgba(220,38,38,0.2)] animate-pulse uppercase tracking-wider">
                                  BANNED
                                </span>
                              )}
                            </div>
                            <span className="text-[10px] text-navy-400 font-mono mt-0.5">ID: {prof.id}</span>
                          </div>
                        </div>
                      </td>

                      {/* 2. City & Province */}
                      <td className="p-4 text-navy-700 font-medium">
                        <div className="flex flex-col">
                          <span>{prof.city_or_district || "Anonim"}</span>
                          <span className="text-[10px] text-navy-400 font-normal mt-0.5">{prof.province || "Anonim"}</span>
                        </div>
                      </td>

                      {/* 3. Level & XP */}
                      <td className="p-4">
                        <div className="flex flex-col">
                          <span className="font-bold text-navy-900">Lvl {prof.level}</span>
                          <span className="text-[10px] text-navy-500 font-medium mt-0.5">{prof.xp} XP</span>
                        </div>
                      </td>

                      {/* 4. Active Streak */}
                      <td className="p-4 font-bold text-emerald">
                        🔥 {prof.current_streak} Hari
                      </td>

                      {/* 5. Badges list with interactive revoke button */}
                      <td className="p-4">
                        <div className="flex flex-wrap gap-1.5 max-w-sm">
                          {(prof.badges || []).map((b) => (
                            <span 
                              key={b.code} 
                              className="group flex items-center gap-1.5 text-[9px] font-bold bg-navy-50 text-navy-700 px-2.5 py-1 rounded-full border border-navy-100/50"
                            >
                              {b.title}
                              <button 
                                onClick={() => triggerCustomConfirm(
                                  "Cabut Lencana",
                                  `Apakah Anda yakin ingin mencabut lencana "${b.title}" dari warga ${prof.full_name || prof.username}?`,
                                  "CABUT",
                                  "warning",
                                  () => handleRevokeBadge(prof.id, b.code)
                                )}
                                className="text-navy-400 hover:text-red-500 transition-colors shrink-0 cursor-pointer text-xs leading-none font-bold"
                                title="Cabut Lencana"
                              >
                                &times;
                              </button>
                            </span>
                          ))}
                          {(prof.badges || []).length === 0 && (
                            <span className="text-[10px] text-navy-400 italic font-light">Belum mendapat lencana.</span>
                          )}
                        </div>
                      </td>

                      {/* 6. Action buttons */}
                      <td className="p-4 pr-6 text-right">
                        <div className="flex items-center justify-end gap-2">
                          
                          {/* Adjust gamified scores */}
                          <button
                            onClick={() => {
                              setSelectedProfile(prof);
                              setAdjustXp(prof.xp);
                              setAdjustLevel(prof.level);
                              setAdjustStreak(prof.current_streak);
                              setIsAdjustGamifyOpen(true);
                            }}
                            className="p-2 rounded-lg border border-navy-100 bg-white text-navy-600 hover:text-navy-900 hover:bg-navy-50 hover:border-navy-200 transition-colors cursor-pointer shadow-sm"
                            title="Koreksi Nilai Gamifikasi"
                          >
                            <Sliders className="h-3.5 w-3.5" />
                          </button>

                          {/* Award new badge */}
                          <button
                            onClick={() => {
                              setSelectedProfile(prof);
                              setBadgeToAward("");
                              setIsAwardBadgeOpen(true);
                            }}
                            className="p-2 rounded-lg border border-navy-100 bg-white text-gold hover:bg-gold-50 hover:border-gold-100 transition-colors cursor-pointer shadow-sm"
                            title="Sematkan Lencana Baru"
                          >
                            <Award className="h-3.5 w-3.5" />
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
                                ? "border-emerald bg-emerald-light/20 text-emerald hover:bg-emerald hover:text-white"
                                : "border-amber-200 bg-amber-50 text-amber-600 hover:bg-amber-600 hover:text-white hover:border-amber-600"
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
                            className="p-2 rounded-lg border border-burgundy-100 bg-white text-burgundy-500 hover:bg-burgundy-50 hover:border-burgundy-200 hover:text-burgundy-700 transition-colors cursor-pointer shadow-sm"
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
      <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-6">
        <div className="flex items-center justify-between border-b border-navy-50 pb-4">
          <div className="flex items-center gap-2.5">
            <div className="h-8 w-8 rounded-lg bg-gold-50 flex items-center justify-center text-gold border border-gold-100/50">
              <Award className="h-4.5 w-4.5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-navy-900">Katalog Lencana Prestasi Kota</h2>
              <p className="text-[10px] text-navy-400 font-light mt-0.5">Sematkan atau rilis jenis lencana ke sistem crowdsourcing.</p>
            </div>
          </div>

          <button
            onClick={() => setIsCreateBadgeOpen(!isCreateBadgeOpen)}
            className="flex items-center gap-1 bg-navy-900 text-white rounded-xl px-3.5 py-2 text-xs font-bold hover:bg-navy-850 transition-all cursor-pointer"
          >
            <Plus className="h-3.5 w-3.5" />
            Rilis Lencana Baru
          </button>
        </div>

        {/* Create Badge Form Collapse Drawer */}
        {isCreateBadgeOpen && (
          <form onSubmit={onCreateBadgeSubmit} className="bg-surface rounded-2xl p-5 border border-navy-100/50 grid grid-cols-1 md:grid-cols-3 gap-4 items-end animate-fade-down">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeCode" className="text-[11px] font-bold text-navy-500">Kode Lencana Unik (Sebab Relasi)</label>
              <input
                id="badgeCode"
                type="text"
                required
                placeholder="Contoh: green_pioneer"
                value={newBadgeCode}
                onChange={(e) => setNewBadgeCode(e.target.value)}
                className="w-full bg-white border border-navy-100 rounded-xl py-2 px-3.5 text-xs text-navy-900 placeholder-navy-300 focus:outline-none focus:border-navy-500 font-mono"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeTitle" className="text-[11px] font-bold text-navy-500">Nama Lencana Prestasi</label>
              <input
                id="badgeTitle"
                type="text"
                required
                placeholder="Contoh: Pelopor Hijau"
                value={newBadgeTitle}
                onChange={(e) => setNewBadgeTitle(e.target.value)}
                className="w-full bg-white border border-navy-100 rounded-xl py-2 px-3.5 text-xs text-navy-900 placeholder-navy-300 focus:outline-none focus:border-navy-500 font-bold"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="badgeDesc" className="text-[11px] font-bold text-navy-500">Deskripsi / Cara Mendapatkannya</label>
              <input
                id="badgeDesc"
                type="text"
                required
                placeholder="Menyelesaikan aksi penanganan B3..."
                value={newBadgeDesc}
                onChange={(e) => setNewBadgeDesc(e.target.value)}
                className="w-full bg-white border border-navy-100 rounded-xl py-2 px-3.5 text-xs text-navy-900 placeholder-navy-300 focus:outline-none focus:border-navy-500 font-light"
              />
            </div>
            <div className="md:col-span-3 flex justify-end gap-2.5 mt-2">
              <button
                type="button"
                onClick={() => setIsCreateBadgeOpen(false)}
                className="px-4 py-2 bg-navy-50 border border-navy-100 hover:bg-navy-100 text-xs font-bold text-navy-600 rounded-xl transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                type="submit"
                disabled={actionLoading}
                className="px-5 py-2 bg-navy-900 hover:bg-navy-850 text-white text-xs font-bold rounded-xl transition-all shadow-sm cursor-pointer"
              >
                Daftarkan ke Katalog
              </button>
            </div>
          </form>
        )}

        {/* Badge Cards List */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {badges.map((b) => (
            <div
              key={b.id}
              className="bg-surface rounded-2xl p-4.5 border border-navy-100/45 hover:border-navy-100 hover:shadow-sm transition-all flex items-start gap-4"
            >
              <div className="h-10 w-10 rounded-xl bg-gold-50/50 border border-gold-200/40 text-gold flex items-center justify-center shrink-0">
                <Sparkles className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                <div>
                  <div className="flex items-start justify-between gap-2">
                    <h4 className="text-xs font-bold text-navy-900 truncate">{b.title}</h4>
                    <button
                      onClick={() => triggerCustomConfirm(
                        "Hapus Lencana Katalog",
                        `⚠️ PERINGATAN: Menghapus lencana "${b.title}" dari katalog akan menghapus referensi bagi seluruh warga yang memilikinya!`,
                        "HAPUS",
                        "danger",
                        () => handleDeleteBadge(b.id)
                      )}
                      className="text-navy-400 hover:text-burgundy-900 p-0.5 cursor-pointer rounded hover:bg-navy-100 transition-all shrink-0"
                      title="Hapus dari Katalog"
                    >
                      <Trash2 className="h-3 w-3 text-burgundy-500" />
                    </button>
                  </div>
                  <span className="text-[9px] text-navy-400 font-mono tracking-wider font-bold uppercase mt-0.5 block">{b.code}</span>
                  <p className="text-[10px] text-navy-500 font-light leading-relaxed mt-2 line-clamp-2">{b.description}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* --- IN-UI CUSTOM CONFIRMATION MODAL (Glassmorphic) --- */}
      {confirmModal && confirmModal.isOpen && (
        <div className="fixed inset-0 bg-navy-950/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className="w-full max-w-sm bg-white/95 backdrop-blur-xl border border-navy-100 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center">
            
            {/* Header Icon Indicator */}
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center border animate-bounce shadow-sm bg-red-50 border-red-100 text-red-600">
              <ShieldAlert className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold text-navy-900 leading-tight">{confirmModal.title}</h3>
              <p className="text-xs text-navy-500 font-light leading-relaxed mt-2 whitespace-pre-line">
                {confirmModal.message}
              </p>
            </div>

            {/* Type verification prompt */}
            {confirmModal.confirmText && (
              <div className="flex flex-col gap-2 animate-fade-in">
                <label htmlFor="verifyInput" className="text-[10px] font-extrabold text-navy-400 uppercase tracking-wider">
                  Ketik <strong className="text-navy-900 font-black">"{confirmModal.confirmText}"</strong> untuk menyetujui
                </label>
                <input
                  id="verifyInput"
                  type="text"
                  placeholder="Ketik kata verifikasi..."
                  value={typeVerify}
                  onChange={(e) => setTypeVerify(e.target.value)}
                  className="w-full bg-surface border border-navy-100 rounded-xl py-2 px-3 text-center text-xs text-navy-900 font-black tracking-widest placeholder:text-navy-300 placeholder:font-light focus:outline-none focus:border-navy-500"
                />
              </div>
            )}

            {/* Actions button list */}
            <div className="flex items-center gap-3 pt-4 border-t border-navy-50 justify-end">
              <button
                onClick={() => setConfirmModal(null)}
                className="w-1/2 rounded-xl bg-navy-50 border border-navy-100 py-2.5 text-xs font-bold text-navy-600 hover:bg-navy-100 hover:text-navy-900 transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={executeConfirmAction}
                disabled={confirmModal.confirmText !== undefined && typeVerify.toUpperCase() !== confirmModal.confirmText.toUpperCase()}
                className={`w-1/2 rounded-xl py-2.5 text-xs font-bold text-white transition-all cursor-pointer shadow-sm disabled:opacity-30 disabled:cursor-not-allowed ${
                  confirmModal.theme === "danger" 
                    ? "bg-burgundy-500 hover:bg-burgundy-600" 
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
        <div className="fixed inset-0 bg-navy-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="w-full max-w-sm bg-white border border-navy-100 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
            
            <div className="border-b border-navy-50 pb-3 select-none">
              <h3 className="text-base font-bold text-navy-900">Koreksi Gamifikasi Warga</h3>
              <p className="text-[11px] text-navy-500 mt-1">Edit XP, Level, dan Streak untuk {selectedProfile.full_name || selectedProfile.username}.</p>
            </div>

            <div className="flex flex-col gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500 select-none">Experience Points (XP)</label>
                <input
                  type="number"
                  value={adjustXp}
                  onChange={(e) => setAdjustXp(parseInt(e.target.value) || 0)}
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-900 focus:outline-none focus:border-navy-300 transition-all"
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500 select-none">Level Warga</label>
                <input
                  type="number"
                  value={adjustLevel}
                  onChange={(e) => setAdjustLevel(parseInt(e.target.value) || 1)}
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-900 focus:outline-none focus:border-navy-300 transition-all"
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-[11px] font-bold text-navy-500 select-none">Current Daily Streak (Hari)</label>
                <input
                  type="number"
                  value={adjustStreak}
                  onChange={(e) => setAdjustStreak(parseInt(e.target.value) || 0)}
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-900 focus:outline-none focus:border-navy-300 transition-all"
                />
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-navy-50">
              <button
                onClick={() => setIsAdjustGamifyOpen(false)}
                className="rounded-xl bg-navy-50 text-navy-600 border border-navy-100 px-4 py-2.5 text-xs font-semibold hover:bg-navy-100 transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleAdjustGamification}
                disabled={actionLoading}
                className="rounded-xl bg-navy-900 text-white px-4 py-2.5 text-xs font-semibold hover:bg-navy-800 transition-all cursor-pointer shadow-sm"
              >
                Terapkan Koreksi
              </button>
            </div>

          </div>
        </div>
      )}

      {/* MODAL: AWARD NEW PRESTIGE BADGE */}
      {isAwardBadgeOpen && selectedProfile && (
        <div className="fixed inset-0 bg-navy-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="w-full max-w-sm bg-white border border-navy-100 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
            
            <div className="border-b border-navy-50 pb-3 select-none">
              <h3 className="text-base font-bold text-navy-900">Sematkan Lencana Baru</h3>
              <p className="text-[11px] text-navy-500 mt-1">Pilih lencana prestasi untuk disematkan pada {selectedProfile.full_name || selectedProfile.username}.</p>
            </div>

            <div className="flex flex-col gap-1.5">
              <label className="text-[11px] font-bold text-navy-500 select-none">Lencana Tersedia</label>
              <select
                value={badgeToAward}
                onChange={(e) => setBadgeToAward(e.target.value)}
                className="w-full bg-white border border-navy-100 rounded-xl py-2 px-3 text-xs text-navy-800 focus:outline-none cursor-pointer font-medium"
              >
                <option value="">-- Pilih Lencana --</option>
                {badges.map((b) => (
                  <option key={b.code} value={b.code}>
                    {b.title} - {b.description}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-navy-50">
              <button
                onClick={() => setIsAwardBadgeOpen(false)}
                className="rounded-xl bg-navy-50 text-navy-600 border border-navy-100 px-4 py-2.5 text-xs font-semibold hover:bg-navy-100 transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleAwardBadge}
                disabled={actionLoading || !badgeToAward}
                className="rounded-xl bg-gold text-white px-4 py-2.5 text-xs font-semibold hover:bg-gold/90 transition-all cursor-pointer shadow-sm"
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
