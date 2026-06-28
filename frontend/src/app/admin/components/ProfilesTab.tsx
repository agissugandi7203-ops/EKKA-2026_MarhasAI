"use client";

import React, { useState } from "react";
import {
  Search,
  Sliders,
  Award,
  Trash2,
  X,
  UserCheck
} from "lucide-react";
import { UserProfile, TrashReport } from "./OverviewTab";

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
  actionLoading: boolean;
}

export default function ProfilesTab({
  profiles,
  badges,
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
  actionLoading
}: ProfilesTabProps) {
  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      
      {/* Header section with search */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-navy-900">Manajemen Kontrol Warga Genesis.id</h1>
          <p className="text-xs text-navy-500 font-light mt-1.5">
            Kontrol absolut atas lencana, pencabutan akun ilegal, dan penyesuaian nilai gamifikasi (XP, level, streak) warga.
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
                <th className="p-4 pr-6 text-right">Otoritas Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-navy-100">
              {profiles
                .filter((p) => {
                  const text = (p.full_name || p.username || "").toLowerCase();
                  return text.includes(profileSearch.toLowerCase());
                })
                .map((prof) => (
                  <tr key={prof.id} className="hover:bg-navy-50/30 transition-colors">
                    
                    {/* 1. Profile avatar & metadata */}
                    <td className="p-4 pl-6">
                      <div className="flex items-center gap-3">
                        <div className="h-9 w-9 rounded-full bg-navy-100 flex items-center justify-center font-bold text-navy-800 border border-navy-200 shrink-0">
                          {prof.username.charAt(0).toUpperCase()}
                        </div>
                        <div className="flex flex-col">
                          <span className="font-bold text-navy-900">{prof.full_name || prof.username}</span>
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
                            className="group flex items-center gap-1.5 text-[9px] font-bold bg-navy-50 text-navy-700 px-2.5 py-1 rounded-full border border-navy-100"
                          >
                            {b.title}
                            <button 
                              onClick={() => handleRevokeBadge(prof.id, b.code)}
                              className="text-navy-400 hover:text-burgundy-500 transition-colors shrink-0 cursor-pointer text-xs leading-none font-bold"
                              title="Cabut Lencana"
                            >
                              &times;
                            </button>
                          </span>
                        ))}
                        {(prof.badges || []).length === 0 && (
                          <span className="text-[10px] text-navy-400 italic">Belum mendapat lencana.</span>
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

                        {/* Absolute deletion */}
                        <button
                          onClick={() => handleDeleteUserProfile(prof.id)}
                          className="p-2 rounded-lg border border-burgundy-100 bg-white text-burgundy-500 hover:bg-burgundy-50 hover:border-burgundy-200 hover:text-burgundy-700 transition-colors cursor-pointer shadow-sm"
                          title="Hapus Akun User Permanen"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>

                      </div>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

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
