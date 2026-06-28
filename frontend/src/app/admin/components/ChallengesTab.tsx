"use client";

import React, { useState } from "react";
import { Plus, Trash2, Award, Sparkles, Calendar, Trophy, CheckCircle, Flame } from "lucide-react";

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
}

export default function ChallengesTab({
  challenges,
  events,
  handleAddChallenge,
  handleDeleteChallenge,
  handleAddEvent,
  handleDeleteEvent,
  actionLoading
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
    <div className="flex flex-col gap-8 animate-fade-up">
      {/* Tab Header */}
      <div>
        <h1 className="text-2xl font-semibold text-navy-900">Pusat Misi & Tantangan Gamifikasi</h1>
        <p className="text-xs text-navy-500 font-light mt-1.5">
          Kelola tantangan harian (Daily Quests) dan Event resmi berhadiah untuk menstimulasi keaktifan warga kota.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        {/* LEFT COLUMN: DAILY QUESTS (CHALLENGES) */}
        <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-6">
          <div className="flex items-center justify-between border-b border-navy-50 pb-4 select-none">
            <div className="flex items-center gap-2.5">
              <div className="h-8 w-8 rounded-lg bg-gold-50 flex items-center justify-center text-gold border border-gold-100/50">
                <Flame className="h-4.5 w-4.5" />
              </div>
              <h2 className="text-base font-bold text-navy-900">Misi Harian (Daily Quests)</h2>
            </div>
            <button
              onClick={() => setIsAddChallengeOpen(!isAddChallengeOpen)}
              className="flex items-center gap-1 bg-navy-900 text-white rounded-xl px-3 py-1.5 text-[11px] font-bold hover:bg-navy-850 transition-all cursor-pointer"
            >
              <Plus className="h-3 w-3" />
              Tantangan Baru
            </button>
          </div>

          {/* Form Create Challenge */}
          {isAddChallengeOpen && (
            <form onSubmit={onSubmitChallenge} className="bg-navy-50/50 border border-navy-100/80 rounded-2xl p-4 flex flex-col gap-4 animate-fade-down">
              <h3 className="text-xs font-bold text-navy-900 select-none">Buat Tantangan Baru</h3>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-1">
                  <label className="text-[10px] font-bold text-navy-500">Kode Unik (Slug)</label>
                  <input
                    type="text"
                    placeholder="e.g., share_impact"
                    value={newChalCode}
                    onChange={(e) => setNewChallengeCode(e.target.value)}
                    className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                    required
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-[10px] font-bold text-navy-500">Nama Misi</label>
                  <input
                    type="text"
                    placeholder="e.g., Bagikan Dampak Sosial"
                    value={newChalTitle}
                    onChange={(e) => setNewChallengeTitle(e.target.value)}
                    className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                    required
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-1">
                  <label className="text-[10px] font-bold text-navy-500">XP Hadiah</label>
                  <input
                    type="number"
                    value={newChalXp}
                    onChange={(e) => setNewChallengeXp(parseInt(e.target.value) || 0)}
                    className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                    min={0}
                    required
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-[10px] font-bold text-navy-500">Poin Hadiah</label>
                  <input
                    type="number"
                    value={newChalPoints}
                    onChange={(e) => setNewChallengePoints(parseInt(e.target.value) || 0)}
                    className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                    min={0}
                    required
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 mt-1">
                <button
                  type="button"
                  onClick={() => setIsAddChallengeOpen(false)}
                  className="rounded-lg bg-white border border-navy-100 px-3 py-1.5 text-[11px] font-bold text-navy-600 hover:bg-navy-50 cursor-pointer"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={actionLoading}
                  className="rounded-lg bg-navy-900 text-white px-3 py-1.5 text-[11px] font-bold hover:bg-navy-800 cursor-pointer disabled:opacity-50 shadow-sm"
                >
                  Simpan Tantangan
                </button>
              </div>
            </form>
          )}

          {/* List Challenges */}
          <div className="flex flex-col gap-3 max-h-[450px] overflow-y-auto pr-1">
            {challenges.length === 0 ? (
              <div className="text-center text-navy-400 py-10 text-xs italic">Belum ada tantangan harian terdaftar.</div>
            ) : (
              challenges.map((chal) => (
                <div key={chal.id} className="flex items-center justify-between p-3.5 rounded-2xl bg-white border border-navy-100/50 hover:border-navy-200 hover:shadow-sm transition-all duration-300">
                  <div className="flex items-center gap-3">
                    <div className="h-9 w-9 rounded-xl bg-gold-50 border border-gold-100/50 flex items-center justify-center text-gold">
                      <Trophy className="h-4 w-4" />
                    </div>
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-navy-900">{chal.title}</span>
                      <span className="text-[10px] text-navy-400 font-mono mt-0.5">{chal.code}</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <span className="text-xs font-bold text-navy-900 block">+{chal.xp} XP</span>
                      <span className="text-[10px] text-emerald font-semibold block">+{chal.points} Pts</span>
                    </div>
                    <button
                      onClick={() => handleDeleteChallenge(chal.id)}
                      disabled={actionLoading}
                      className="p-1.5 rounded-lg border border-navy-100 text-navy-400 hover:text-burgundy-500 hover:border-burgundy-100 hover:bg-burgundy-50 transition-all cursor-pointer"
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
        <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-6">
          <div className="flex items-center justify-between border-b border-navy-50 pb-4 select-none">
            <div className="flex items-center gap-2.5">
              <div className="h-8 w-8 rounded-lg bg-emerald-light/20 flex items-center justify-center text-emerald border border-emerald-light/40">
                <Calendar className="h-4.5 w-4.5" />
              </div>
              <h2 className="text-base font-bold text-navy-900">Event Resmi Kota (Official Events)</h2>
            </div>
            <button
              onClick={() => setIsAddEventOpen(!isAddEventOpen)}
              className="flex items-center gap-1 bg-navy-900 text-white rounded-xl px-3 py-1.5 text-[11px] font-bold hover:bg-navy-850 transition-all cursor-pointer"
            >
              <Plus className="h-3 w-3" />
              Event Baru
            </button>
          </div>

          {/* Form Create Event */}
          {isAddEventOpen && (
            <form onSubmit={onSubmitEvent} className="bg-navy-50/50 border border-navy-100/80 rounded-2xl p-4 flex flex-col gap-4 animate-fade-down">
              <h3 className="text-xs font-bold text-navy-900 select-none">Buat Event Resmi Baru</h3>
              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-navy-500">Judul Event</label>
                <input
                  type="text"
                  placeholder="e.g., Surabaya Bersih Merdeka 2026"
                  value={newEventTitle}
                  onChange={(e) => setNewEventTitle(e.target.value)}
                  className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                  required
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-navy-500">Deskripsi Lengkap Event</label>
                <textarea
                  placeholder="e.g., Kerja bakti serentak di kelurahan masing-masing berhadiah poin lencana..."
                  value={newEventDesc}
                  onChange={(e) => setNewEventDesc(e.target.value)}
                  className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                  rows={2}
                  required
                />
              </div>
              <div className="flex flex-col gap-1">
                <label className="text-[10px] font-bold text-navy-500">Hadiah Poin</label>
                <input
                  type="number"
                  value={newEventPoints}
                  onChange={(e) => setNewEventPoints(parseInt(e.target.value) || 0)}
                  className="bg-white border border-navy-100 rounded-lg p-2 text-xs focus:outline-none focus:border-navy-300"
                  min={0}
                  required
                />
              </div>
              <div className="flex justify-end gap-2 mt-1">
                <button
                  type="button"
                  onClick={() => setIsAddEventOpen(false)}
                  className="rounded-lg bg-white border border-navy-100 px-3 py-1.5 text-[11px] font-bold text-navy-600 hover:bg-navy-50 cursor-pointer"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={actionLoading}
                  className="rounded-lg bg-navy-900 text-white px-3 py-1.5 text-[11px] font-bold hover:bg-navy-800 cursor-pointer disabled:opacity-50 shadow-sm"
                >
                  Publikasikan Event
                </button>
              </div>
            </form>
          )}

          {/* List Events */}
          <div className="flex flex-col gap-3 max-h-[450px] overflow-y-auto pr-1">
            {events.length === 0 ? (
              <div className="text-center text-navy-400 py-10 text-xs italic">Belum ada event resmi terdaftar.</div>
            ) : (
              events.map((ev) => (
                <div key={ev.id} className="flex flex-col p-4 rounded-2xl bg-white border border-navy-100/50 hover:border-navy-200 hover:shadow-sm transition-all duration-300 gap-3">
                  <div className="flex items-start justify-between select-none">
                    <span className="text-[9px] font-bold text-emerald bg-emerald-light/20 px-2 py-0.5 rounded-full uppercase">
                      Event Aktif
                    </span>
                    <button
                      onClick={() => handleDeleteEvent(ev.id)}
                      disabled={actionLoading}
                      className="text-navy-400 hover:text-burgundy-500 transition-colors cursor-pointer"
                      title="Hapus Event"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-navy-900">{ev.title}</h4>
                    <p className="text-[11px] text-navy-500 leading-relaxed mt-1">{ev.description}</p>
                  </div>
                  <div className="flex items-center justify-between border-t border-navy-50 pt-2.5 mt-1 select-none">
                    <span className="text-[10px] text-navy-400 font-medium">Hadiah: <strong className="text-navy-900 font-bold">+{ev.points} Pts</strong></span>
                    <span className="text-[9px] text-navy-400">{new Date(ev.created_at).toLocaleDateString("id-ID")}</span>
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
