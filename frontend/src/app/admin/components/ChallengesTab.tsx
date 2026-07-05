"use client";

import React, { useState } from "react";
import { Plus, Trash2, Trophy, Calendar, Flame } from "lucide-react";

export interface Challenge {
  id: string;
  code: string;
  title: string;
  xp: number;
  points: number;
  created_at: string;
}

export interface OfficialEvent {
  id: string;
  title: string;
  description: string;
  points: number;
  created_at: string;
}

interface ChallengesTabProps {
  challenges: Challenge[];
  events: OfficialEvent[];
  handleAddChallenge: (code: string, title: string, xp: number, points: number) => Promise<void>;
  handleDeleteChallenge: (id: string) => Promise<void>;
  handleAddEvent: (title: string, description: string, points: number) => Promise<void>;
  handleDeleteEvent: (id: string) => Promise<void>;
  actionLoading: boolean;
  theme?: "light" | "dark";
  showToast?: (message: string, type: "success" | "error" | "info") => void;
}

export default function ChallengesTab({
  challenges,
  events,
  handleAddChallenge,
  handleDeleteChallenge,
  handleAddEvent,
  handleDeleteEvent,
  actionLoading,
  theme = "light",
  showToast
}: ChallengesTabProps) {
  // New Challenge Form States
  const [newChalCode, setNewChallengeCode] = useState("");
  const [newChalTitle, setNewChallengeTitle] = useState("");
  const [newChalXp, setNewChallengeXp] = useState(50);
  const [newChalPoints, setNewChallengePoints] = useState(10);
  const [isAddChallengeOpen, setIsAddChallengeOpen] = useState(false);

  // New Event Form States
  const [newEventTitle, setNewEventTitle] = useState("");
  const [newEventDesc, setNewEventDesc] = useState("");
  const [newEventPoints, setNewEventPoints] = useState(100);
  const [isAddEventOpen, setIsAddEventOpen] = useState(false);
  const isDark = theme === "dark";

  const onSubmitChallenge = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newChalCode || !newChalTitle) return;
    await handleAddChallenge(newChalCode, newChalTitle, newChalXp, newChalPoints);
    setNewChallengeCode("");
    setNewChallengeTitle("");
    setNewChallengeXp(50);
    setNewChallengePoints(10);
    setIsAddChallengeOpen(false);
  };

  const onSubmitEvent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newEventTitle || !newEventDesc) return;
    await handleAddEvent(newEventTitle, newEventDesc, newEventPoints);
    setNewEventTitle("");
    setNewEventDesc("");
    setNewEventPoints(100);
    setIsAddEventOpen(false);
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      {/* Tab Header */}
      <div>
        <h1 className={`text-2xl font-bold tracking-tight ${isDark ? "text-white" : "text-slate-900"}`}>
          Pusat Misi & Tantangan Gamifikasi
        </h1>
        <p className={`text-xs font-light mt-1.5 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
          Kelola tantangan harian (Daily Quests) dan Event resmi berhadiah untuk menstimulasi keaktifan warga kota.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        {/* LEFT COLUMN: DAILY QUESTS (CHALLENGES) */}
        <div className={`rounded-3xl p-6 border shadow-sm flex flex-col gap-6 ${
          isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
        }`}>
          <div className={`flex items-center justify-between border-b pb-4 select-none ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
            <div className="flex items-center gap-2.5">
              <div className={`h-8 w-8 rounded-lg flex items-center justify-center border ${
                isDark ? "bg-zinc-900 border-zinc-800 text-gold" : "bg-gold-50 border-gold-100 text-gold"
              }`}>
                <Flame className="h-4.5 w-4.5" />
              </div>
              <h2 className="text-base font-bold">Misi Harian (Daily Quests)</h2>
            </div>
            <button
              onClick={() => setIsAddChallengeOpen(!isAddChallengeOpen)}
              className={`flex items-center gap-1 rounded-xl px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer ${
                isDark ? "bg-zinc-800 hover:bg-zinc-700 text-white" : "bg-slate-900 text-white hover:bg-slate-850"
              }`}
            >
              <Plus className="h-3 w-3" />
              Tantangan Baru
            </button>
          </div>

          {/* Form Create Challenge */}
          {isAddChallengeOpen && (
            <form onSubmit={onSubmitChallenge} className={`border rounded-2xl p-4 flex flex-col gap-4 animate-fade-down ${
              isDark ? "bg-zinc-900/60 border-zinc-850" : "bg-slate-50 border-slate-200"
            }`}>
              <h3 className="text-xs font-bold select-none">Buat Tantangan Baru</h3>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-1">
                  <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Kode Unik (Slug)</label>
                  <input
                    type="text"
                    placeholder="Contoh: share_impact"
                    value={newChalCode}
                    onChange={(e) => setNewChallengeCode(e.target.value)}
                    className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                      isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                    }`}
                    required
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Nama Misi</label>
                  <input
                    type="text"
                    placeholder="Contoh: Bagikan Dampak"
                    value={newChalTitle}
                    onChange={(e) => setNewChallengeTitle(e.target.value)}
                    className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                      isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                    }`}
                    required
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-1">
                  <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>XP Hadiah</label>
                  <input
                    type="number"
                    value={newChalXp}
                    onChange={(e) => setNewChallengeXp(parseInt(e.target.value) || 0)}
                    className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                      isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                    }`}
                    min={0}
                    required
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Poin Hadiah</label>
                  <input
                    type="number"
                    value={newChalPoints}
                    onChange={(e) => setNewChallengePoints(parseInt(e.target.value) || 0)}
                    className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                      isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                    }`}
                    min={0}
                    required
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 mt-1">
                <button
                  type="button"
                  onClick={() => setIsAddChallengeOpen(false)}
                  className={`rounded-lg border px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer ${
                    isDark ? "bg-zinc-950 border-zinc-800 text-zinc-400 hover:bg-zinc-900" : "bg-white border-slate-200 text-slate-600 hover:bg-slate-50"
                  }`}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={actionLoading}
                  className={`rounded-lg text-white px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer disabled:opacity-50 shadow-sm ${
                    isDark ? "bg-zinc-800 hover:bg-zinc-700" : "bg-slate-900 hover:bg-slate-850"
                  }`}
                >
                  Simpan Tantangan
                </button>
              </div>
            </form>
          )}

          {/* List Challenges */}
          <div className="flex flex-col gap-3 max-h-[450px] overflow-y-auto pr-1">
            {challenges.length === 0 ? (
              <div className={`text-center py-10 text-xs italic ${isDark ? "text-zinc-600" : "text-slate-400"}`}>Belum ada tantangan harian terdaftar.</div>
            ) : (
              challenges.map((chal) => (
                <div key={chal.id} className={`flex items-center justify-between p-3.5 rounded-2xl border transition-all duration-300 ${
                  isDark ? "bg-zinc-900/40 border-zinc-800/80 hover:border-zinc-750" : "bg-white border-slate-150 hover:border-slate-250 hover:shadow-sm"
                }`}>
                  <div className="flex items-center gap-3">
                    <div className={`h-9 w-9 rounded-xl border flex items-center justify-center ${
                      isDark ? "bg-zinc-900 border-zinc-800 text-gold" : "bg-gold-50 border-gold-100 text-gold"
                    }`}>
                      <Trophy className="h-4 w-4" />
                    </div>
                    <div className="flex flex-col">
                      <span className={`text-xs font-bold ${isDark ? "text-slate-200" : "text-slate-850"}`}>{chal.title}</span>
                      <span className={`text-[10px] font-mono mt-0.5 ${isDark ? "text-zinc-550" : "text-slate-400"}`}>{chal.code}</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <span className={`text-xs font-bold block ${isDark ? "text-slate-200" : "text-slate-905"}`}>+{chal.xp} XP</span>
                      <span className="text-[10px] text-emerald-500 font-semibold block">+{chal.points} Pts</span>
                    </div>
                    <button
                      onClick={() => handleDeleteChallenge(chal.id)}
                      disabled={actionLoading}
                      className={`p-1.5 rounded-lg border transition-all cursor-pointer ${
                        isDark 
                          ? "border-zinc-850 text-zinc-500 hover:text-red-400 hover:bg-red-950/20" 
                          : "border-slate-200 text-slate-400 hover:text-red-650 hover:bg-red-50 hover:border-red-100"
                      }`}
                      title="Hapus Tantangan"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* RIGHT COLUMN: OFFICIAL EVENTS */}
        <div className={`rounded-3xl p-6 border shadow-sm flex flex-col gap-6 ${
          isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
        }`}>
          <div className={`flex items-center justify-between border-b pb-4 select-none ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
            <div className="flex items-center gap-2.5">
              <div className={`h-8 w-8 rounded-lg flex items-center justify-center border ${
                isDark ? "bg-zinc-900 border-zinc-800 text-emerald-500" : "bg-emerald-50 border-emerald-100 text-emerald"
              }`}>
                <Calendar className="h-4.5 w-4.5" />
              </div>
              <h2 className="text-base font-bold">Event Resmi Kota (Official Events)</h2>
            </div>
            <button
              onClick={() => setIsAddEventOpen(!isAddEventOpen)}
              className={`flex items-center gap-1 rounded-xl px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer ${
                isDark ? "bg-zinc-800 hover:bg-zinc-700 text-white" : "bg-slate-900 text-white hover:bg-slate-850"
              }`}
            >
              <Plus className="h-3 w-3" />
              Event Baru
            </button>
          </div>

          {/* Form Create Event */}
          {isAddEventOpen && (
            <form onSubmit={onSubmitEvent} className={`border rounded-2xl p-4 flex flex-col gap-4 animate-fade-down ${
              isDark ? "bg-zinc-900/60 border-zinc-850" : "bg-slate-50 border-slate-200"
            }`}>
              <h3 className="text-xs font-bold select-none">Buat Event Resmi Baru</h3>
              <div className="flex flex-col gap-1">
                <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Judul Event</label>
                <input
                  type="text"
                  placeholder="Contoh: Surabaya Bersih Merdeka 2026"
                  value={newEventTitle}
                  onChange={(e) => setNewEventTitle(e.target.value)}
                  className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                  }`}
                  required
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Deskripsi Lengkap Event</label>
                <textarea
                  placeholder="Contoh: Kerja bakti serentak di kelurahan masing-masing berhadiah poin lencana..."
                  value={newEventDesc}
                  onChange={(e) => setNewEventDesc(e.target.value)}
                  className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                  }`}
                  rows={2}
                  required
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className={`text-[10px] font-bold ${isDark ? "text-zinc-500" : "text-slate-500"}`}>Hadiah Poin</label>
                <input
                  type="number"
                  value={newEventPoints}
                  onChange={(e) => setNewEventPoints(parseInt(e.target.value) || 0)}
                  className={`border rounded-lg p-2 text-xs focus:outline-none transition-all ${
                    isDark ? "bg-zinc-950 border-zinc-800 text-white focus:border-zinc-700" : "bg-white border-slate-200 text-slate-850 focus:border-slate-350"
                  }`}
                  min={0}
                  required
                />
              </div>
              <div className="flex justify-end gap-2 mt-1">
                <button
                  type="button"
                  onClick={() => setIsAddEventOpen(false)}
                  className={`rounded-lg border px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer ${
                    isDark ? "bg-zinc-950 border-zinc-800 text-zinc-400 hover:bg-zinc-900" : "bg-white border-slate-200 text-slate-600 hover:bg-slate-50"
                  }`}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={actionLoading}
                  className={`rounded-lg text-white px-3 py-1.5 text-[11px] font-bold transition-all cursor-pointer disabled:opacity-50 shadow-sm ${
                    isDark ? "bg-zinc-800 hover:bg-zinc-700" : "bg-slate-900 hover:bg-slate-850"
                  }`}
                >
                  Publikasikan Event
                </button>
              </div>
            </form>
          )}

          {/* List Events */}
          <div className="flex flex-col gap-3 max-h-[450px] overflow-y-auto pr-1">
            {events.length === 0 ? (
              <div className={`text-center py-10 text-xs italic ${isDark ? "text-zinc-600" : "text-slate-400"}`}>Belum ada event resmi terdaftar.</div>
            ) : (
              events.map((ev) => (
                <div key={ev.id} className={`flex flex-col p-4 rounded-2xl border transition-all duration-300 gap-3 ${
                  isDark ? "bg-zinc-900/40 border-zinc-800/80 hover:border-zinc-750" : "bg-white border-slate-150 hover:border-slate-250 hover:shadow-sm"
                }`}>
                  <div className="flex items-start justify-between select-none">
                    <span className={`text-[9px] font-bold border px-2 py-0.5 rounded-full uppercase ${
                      isDark ? "bg-emerald-500/10 border-emerald-500/20 text-emerald-400" : "bg-emerald-50 border-emerald-100 text-emerald-700"
                    }`}>
                      Event Aktif
                    </span>
                    <button
                      onClick={() => handleDeleteEvent(ev.id)}
                      disabled={actionLoading}
                      className={`p-1 rounded transition-colors cursor-pointer ${
                        isDark ? "text-zinc-555 hover:text-red-400" : "text-slate-400 hover:text-red-650"
                      }`}
                      title="Hapus Event"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                  <div>
                    <h4 className={`text-xs font-bold ${isDark ? "text-slate-200" : "text-slate-850"}`}>{ev.title}</h4>
                    <p className={`text-[11px] leading-relaxed mt-1 ${isDark ? "text-zinc-400" : "text-slate-500"}`}>{ev.description}</p>
                  </div>
                  <div className={`flex items-center justify-between border-t pt-2.5 mt-1 select-none ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
                    <span className="text-[10px] font-medium">Hadiah: <strong className={isDark ? "text-slate-200" : "text-slate-850"}>+{ev.points} Pts</strong></span>
                    <span className={`text-[9px] ${isDark ? "text-zinc-500" : "text-slate-405"}`}>{new Date(ev.created_at).toLocaleDateString("id-ID")}</span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

      </div>
    </div>
  );
}
