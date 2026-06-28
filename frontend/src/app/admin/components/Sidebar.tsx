"use client";

import React from "react";
import {
  ShieldCheck,
  Activity,
  MapPin,
  Users,
  FileText,
  LogOut
} from "lucide-react";

interface SidebarProps {
  adminName: string;
  adminEmail: string;
  activeTab: "overview" | "reports" | "profiles" | "rag";
  setActiveTab: (tab: "overview" | "reports" | "profiles" | "rag") => void;
  isLive: boolean;
  pendingHumanCount: number;
  handleLogout: () => void;
}

export default function Sidebar({
  adminName,
  adminEmail,
  activeTab,
  setActiveTab,
  isLive,
  pendingHumanCount,
  handleLogout
}: SidebarProps) {
  return (
    <aside className="w-full md:w-64 shrink-0 border-r border-navy-100/80 bg-white/70 backdrop-blur-xl flex flex-col justify-between p-6 z-20 shadow-[4px_0_24px_rgba(0,0,0,0.01)]">
      <div className="flex flex-col gap-8">
        
        {/* Brand Logo & Info */}
        <div className="flex items-center gap-3 select-none">
          <div className="h-10 w-10 rounded-xl bg-navy-50 flex items-center justify-center border border-navy-100 shadow-sm">
            <ShieldCheck className="h-5.5 w-5.5 text-navy-900" />
          </div>
          <div className="flex flex-col">
            <span className="text-base font-semibold tracking-tight text-navy-900 leading-none">Genesis.id</span>
            <span className="text-[10px] uppercase font-bold text-gold tracking-wider mt-1.5 leading-none">Otoritas Admin</span>
          </div>
        </div>

        {/* Admin Profile Widget */}
        <div className="rounded-2xl p-4 border border-navy-100/60 bg-navy-50/50 select-none flex items-center gap-3 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)]">
          <div className="relative">
            <div className="h-10 w-10 rounded-full bg-navy-900 flex items-center justify-center font-bold text-white border border-navy-800 shadow-sm">
              {adminName.charAt(0).toUpperCase()}
            </div>
            <div className="absolute bottom-0 right-0 h-3 w-3 rounded-full bg-emerald border-2 border-white flex items-center justify-center shadow-sm">
              <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />
            </div>
          </div>
          <div className="flex flex-col min-w-0">
            <span className="text-xs font-bold text-navy-900 truncate leading-tight">{adminName}</span>
            <span className="text-[10px] text-navy-500/80 truncate leading-none mt-1">{adminEmail}</span>
          </div>
        </div>

        {/* Tab Navigation Links */}
        <nav className="flex flex-col gap-1.5">
          <button
            onClick={() => setActiveTab("overview")}
            className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-200 cursor-pointer ${
              activeTab === "overview"
                ? "bg-navy-900 text-white shadow-[0_4px_12px_rgba(5,12,24,0.1)] font-bold scale-[1.01]"
                : "text-navy-600 hover:text-navy-900 hover:bg-navy-50/70"
            }`}
          >
            <Activity className="h-4 w-4 shrink-0" />
            Dasbor Ringkasan
          </button>
          <button
            onClick={() => setActiveTab("reports")}
            className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-200 cursor-pointer ${
              activeTab === "reports"
                ? "bg-navy-900 text-white shadow-[0_4px_12px_rgba(5,12,24,0.1)] font-bold scale-[1.01]"
                : "text-navy-600 hover:text-navy-900 hover:bg-navy-50/70"
            }`}
          >
            <MapPin className="h-4 w-4 shrink-0" />
            Laporan Spasial
            {pendingHumanCount > 0 && (
              <span className="ml-auto bg-burgundy-500 text-white text-[9px] font-bold px-2 py-0.5 rounded-full animate-bounce">
                {pendingHumanCount}
              </span>
            )}
          </button>
          <button
            onClick={() => setActiveTab("profiles")}
            className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-200 cursor-pointer ${
              activeTab === "profiles"
                ? "bg-navy-900 text-white shadow-[0_4px_12px_rgba(5,12,24,0.1)] font-bold scale-[1.01]"
                : "text-navy-600 hover:text-navy-900 hover:bg-navy-50/70"
            }`}
          >
            <Users className="h-4 w-4 shrink-0" />
            Kontrol Warga
          </button>
          <button
            onClick={() => setActiveTab("rag")}
            className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-200 cursor-pointer ${
              activeTab === "rag"
                ? "bg-navy-900 text-white shadow-[0_4px_12px_rgba(5,12,24,0.1)] font-bold scale-[1.01]"
                : "text-navy-600 hover:text-navy-900 hover:bg-navy-50/70"
            }`}
          >
            <FileText className="h-4 w-4 shrink-0" />
            Basis Pengetahuan AI
          </button>
        </nav>
      </div>

      {/* Footer Actions inside Sidebar */}
      <div className="flex flex-col gap-4 mt-8">
        {/* Mode Status Indicator */}
        <div className="flex items-center gap-1.5 px-2 select-none">
          <span className={`h-2 w-2 rounded-full ${isLive ? "bg-emerald" : "bg-gold"} animate-pulse`} />
          <span className="text-[10px] text-navy-500 font-medium">
            Mode: <strong className="text-navy-900">{isLive ? "Live NestJS API" : "Simulasi Emulator"}</strong>
          </span>
        </div>

        <button
          onClick={handleLogout}
          className="flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl border border-navy-100 text-navy-600 hover:text-burgundy-900 hover:bg-burgundy-50 hover:border-burgundy-200 transition-all duration-200 cursor-pointer"
        >
          <LogOut className="h-4 w-4 text-burgundy-500" />
          Logout Otoritas
        </button>
      </div>
    </aside>
  );
}
