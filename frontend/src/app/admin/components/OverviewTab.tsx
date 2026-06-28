"use client";

import React from "react";
import {
  RefreshCw,
  Clock,
  Sparkles,
  CheckCircle,
  UserCheck,
  ChevronRight,
  ChevronLeft
} from "lucide-react";

export interface UserProfile {
  id: string;
  username: string;
  full_name: string;
  province: string;
  city_or_district: string;
  role: string;
  xp: number;
  level: number;
  current_streak: number;
  points?: number;
  created_at: string;
  badges?: Array<{
    earned_at: string;
    code: string;
    title: string;
    description: string;
    image_url?: string;
  }>;
}

export interface TrashReport {
  id: string;
  reporter_id: string;
  image_url: string;
  description: string;
  status: "pending_ai" | "pending_human" | "approved" | "resolved" | "rejected";
  waste_type?: string;
  danger_level?: string;
  confidence_score?: number;
  location?: any;
  created_at: string;
  profiles?: {
    username: string;
    full_name: string;
    avatar_url?: string;
  };
  coordinates?: {
    latitude: number;
    longitude: number;
  };
}

interface OverviewTabProps {
  reports: TrashReport[];
  profiles: UserProfile[];
  fetchData: () => void;
  setActiveTab: (tab: "overview" | "reports" | "profiles" | "rag") => void;
  setSelectedReport: (report: TrashReport | null) => void;
  setSelectedProfile: (profile: UserProfile | null) => void;
}

export default function OverviewTab({
  reports,
  profiles,
  fetchData,
  setActiveTab,
  setSelectedReport,
  setSelectedProfile
}: OverviewTabProps) {
  // Counters
  const pendingHumanCount = reports.filter((r) => r.status === "pending_human").length;
  const pendingAiCount = reports.filter((r) => r.status === "pending_ai").length;
  const approvedCount = reports.filter((r) => r.status === "approved").length;
  const resolvedCount = reports.filter((r) => r.status === "resolved").length;

  return (
    <div className="flex flex-col gap-8 animate-fade-up">
      
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-normal text-navy-900 tracking-tight">Selamat Datang Kembali, Administrator.</h1>
          <p className="text-xs text-navy-500 font-light mt-1.5">
            Semua sistem vital beroperasi lancar. Berikut laporan status aktivitas crowdsourcing terpadu Genesis.id.
          </p>
        </div>
        
        <button 
          onClick={fetchData}
          className="flex items-center gap-2 self-start bg-white border border-navy-100 rounded-xl px-4 py-2.5 text-xs font-semibold text-navy-700 hover:text-navy-900 hover:bg-navy-50 hover:border-navy-200 transition-all shadow-sm cursor-pointer select-none"
        >
          <RefreshCw className="h-3.5 w-3.5" />
          Segarkan Portal
        </button>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        
        {/* Card 1 */}
        <div className="bg-white rounded-2xl p-5 border border-navy-100 shadow-[0_4px_20px_rgba(10,22,40,0.015)] hover:shadow-[0_8px_30px_rgba(10,22,40,0.03)] hover:scale-[1.01] transition-all duration-300">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-navy-500 uppercase tracking-wider">Menunggu Validasi Manusia</span>
            <div className="h-8 w-8 rounded-lg bg-burgundy-50 flex items-center justify-center text-burgundy-500 border border-burgundy-100/50">
              <Clock className="h-4 w-4" />
            </div>
          </div>
          <div className="text-3xl font-bold text-navy-900 mt-4">{pendingHumanCount}</div>
          <div className="text-[10px] text-navy-400 mt-1.5 leading-normal">Laporan warga terklasifikasi AI butuh peninjauan manual</div>
        </div>

        {/* Card 2 */}
        <div className="bg-white rounded-2xl p-5 border border-navy-100 shadow-[0_4px_20px_rgba(10,22,40,0.015)] hover:shadow-[0_8px_30px_rgba(10,22,40,0.03)] hover:scale-[1.01] transition-all duration-300">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-navy-500 uppercase tracking-wider">Menunggu Analisis AI</span>
            <div className="h-8 w-8 rounded-lg bg-gold-50 flex items-center justify-center text-gold border border-gold-100/50">
              <Sparkles className="h-4 w-4" />
            </div>
          </div>
          <div className="text-3xl font-bold text-navy-900 mt-4">{pendingAiCount}</div>
          <div className="text-[10px] text-navy-400 mt-1.5 leading-normal">Antrean background task vision-AI classifier</div>
        </div>

        {/* Card 3 */}
        <div className="bg-white rounded-2xl p-5 border border-navy-100 shadow-[0_4px_20px_rgba(10,22,40,0.015)] hover:shadow-[0_8px_30px_rgba(10,22,40,0.03)] hover:scale-[1.01] transition-all duration-300">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-navy-500 uppercase tracking-wider">Laporan Aktif</span>
            <div className="h-8 w-8 rounded-lg bg-emerald-light/30 flex items-center justify-center text-emerald border border-emerald-light/60">
              <CheckCircle className="h-4 w-4" />
            </div>
          </div>
          <div className="text-3xl font-bold text-navy-900 mt-4">{approvedCount}</div>
          <div className="text-[10px] text-navy-400 mt-1.5 leading-normal">Telah disetujui & siap ditangani petugas kebersihan</div>
        </div>

        {/* Card 4 */}
        <div className="bg-white rounded-2xl p-5 border border-navy-100 shadow-[0_4px_20px_rgba(10,22,40,0.015)] hover:shadow-[0_8px_30px_rgba(10,22,40,0.03)] hover:scale-[1.01] transition-all duration-300">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-navy-500 uppercase tracking-wider">Selesai Ditangani</span>
            <div className="h-8 w-8 rounded-lg bg-navy-50 flex items-center justify-center text-navy-600 border border-navy-100">
              <UserCheck className="h-4 w-4" />
            </div>
          </div>
          <div className="text-3xl font-bold text-navy-900 mt-4">{resolvedCount}</div>
          <div className="text-[10px] text-navy-400 mt-1.5 leading-normal">Tumpukan sampah warga dilaporkan tuntas dibersihkan</div>
        </div>

      </div>

      {/* Core Features Overview: Split Columns */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        {/* Quick Report Activity */}
        <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-4">
          <div className="flex items-center justify-between border-b border-navy-50 pb-4">
            <h2 className="text-lg font-semibold text-navy-900">Laporan Spasial Terkini</h2>
            <button 
              onClick={() => setActiveTab("reports")} 
              className="text-xs text-navy-500 hover:text-navy-900 flex items-center gap-1 font-semibold transition-colors cursor-pointer"
            >
              Lihat Semua
              <ChevronRight className="h-3 w-3" />
            </button>
          </div>

          <div className="flex flex-col gap-4">
            {reports.slice(0, 3).map((rep) => (
              <div 
                key={rep.id} 
                onClick={() => { setSelectedReport(rep); setActiveTab("reports"); }}
                className="group flex gap-4 p-3.5 rounded-2xl bg-white border border-navy-100/50 hover:bg-navy-50/50 hover:border-navy-200 transition-all duration-300 cursor-pointer shadow-sm hover:shadow-md"
              >
                <img 
                  src={rep.image_url} 
                  alt={rep.waste_type || "Trash"} 
                  className="h-14 w-14 rounded-xl object-cover border border-navy-100 shrink-0 shadow-sm" 
                />
                <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-bold text-navy-900 truncate">{rep.waste_type || "Tumpukan Sampah"}</span>
                    <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full uppercase shrink-0 ${
                      rep.status === "pending_human" ? "bg-burgundy-50 text-burgundy-500 border border-burgundy-100" :
                      rep.status === "pending_ai" ? "bg-gold-50 text-gold border border-gold-100" :
                      rep.status === "approved" ? "bg-emerald-light/40 text-emerald border border-emerald-light" :
                      "bg-navy-50 text-navy-500 border border-navy-100"
                    }`}>
                      {rep.status}
                    </span>
                  </div>
                  <p className="text-[11px] text-navy-500 truncate mt-1 leading-normal">{rep.description}</p>
                  <span className="text-[9px] text-navy-400 font-medium mt-1">
                    {new Date(rep.created_at).toLocaleString("id-ID")}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Users List */}
        <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-4">
          <div className="flex items-center justify-between border-b border-navy-50 pb-4">
            <h2 className="text-lg font-semibold text-navy-900">Warga dengan XP Tertinggi</h2>
            <button 
              onClick={() => setActiveTab("profiles")} 
              className="text-xs text-navy-500 hover:text-navy-900 flex items-center gap-1 font-semibold transition-colors cursor-pointer"
            >
              Lihat Semua
              <ChevronRight className="h-3 w-3" />
            </button>
          </div>

          <div className="flex flex-col gap-4">
            {profiles.slice().sort((a, b) => b.xp - a.xp).slice(0, 3).map((prof) => (
              <div 
                key={prof.id}
                onClick={() => { setSelectedProfile(prof); setActiveTab("profiles"); }}
                className="flex items-center justify-between p-3.5 rounded-2xl bg-white border border-navy-100/50 hover:bg-navy-50/50 hover:border-navy-200 transition-all duration-300 cursor-pointer shadow-sm hover:shadow-md"
              >
                <div className="flex items-center gap-3">
                  <div className="h-9 w-9 rounded-full bg-navy-100 flex items-center justify-center font-bold text-navy-900 border border-navy-200 shrink-0">
                    {prof.username.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex flex-col">
                    <span className="text-xs font-bold text-navy-900">{prof.full_name || prof.username}</span>
                    <span className="text-[10px] text-navy-400 font-medium">{prof.city_or_district}</span>
                  </div>
                </div>

                <div className="flex items-center gap-4 text-right">
                  <div className="flex flex-col">
                    <span className="text-xs font-bold text-navy-900 leading-none">{prof.xp} XP</span>
                    <span className="text-[9px] text-gold font-bold mt-1 leading-none">Level {prof.level}</span>
                  </div>
                  <div className="flex items-center gap-1 text-emerald bg-emerald-light/40 px-2 py-1.5 rounded-lg border border-emerald-light shrink-0 select-none">
                    <span className="text-[10px] font-bold">🔥 {prof.current_streak} Hari</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>

    </div>
  );
}
