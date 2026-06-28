"use client";

import React, { useState } from "react";
import {
  ShieldCheck,
  Activity,
  MapPin,
  Users,
  FileText,
  LogOut,
  Trophy,
  Bell,
  ClipboardList,
  ChevronLeft,
  ChevronRight,
  Menu
} from "lucide-react";

export type AdminTab = "overview" | "reports" | "profiles" | "rag" | "challenges" | "broadcast" | "audit";

interface SidebarProps {
  adminName: string;
  adminEmail: string;
  activeTab: AdminTab;
  setActiveTab: (tab: AdminTab) => void;
  isLive: boolean;
  pendingHumanCount: number;
  handleLogout: () => void;
  theme?: "light" | "dark";
}

export default function Sidebar({
  adminName,
  adminEmail,
  activeTab,
  setActiveTab,
  isLive,
  pendingHumanCount,
  handleLogout,
  theme = "light"
}: SidebarProps) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const isDark = theme === "dark";

  // Grouped Menu Structure
  const menuGroups = [
    {
      title: "DASBOR & KONTROL",
      items: [
        { id: "overview", label: "Ringkasan Analitik", icon: <Activity className="h-4 w-4 shrink-0" /> },
        {
          id: "reports",
          label: "Laporan Spasial",
          icon: <MapPin className="h-4 w-4 shrink-0" />,
          badge: pendingHumanCount > 0 ? pendingHumanCount : undefined
        },
        { id: "profiles", label: "Kontrol Warga", icon: <Users className="h-4 w-4 shrink-0" /> }
      ]
    },
    {
      title: "SIARAN & GAMIFIKASI",
      items: [
        { id: "challenges", label: "Pusat Tantangan", icon: <Trophy className="h-4 w-4 shrink-0" /> },
        { id: "broadcast", label: "Pusat Siaran", icon: <Bell className="h-4 w-4 shrink-0" /> }
      ]
    },
    {
      title: "AI & KEAMANAN",
      items: [
        { id: "rag", label: "Basis Pengetahuan AI", icon: <FileText className="h-4 w-4 shrink-0" /> },
        { id: "audit", label: "Log Audit Sistem", icon: <ClipboardList className="h-4 w-4 shrink-0" /> }
      ]
    }
  ];

  return (
    <aside
      className={`shrink-0 border-r flex flex-col justify-between p-4 z-20 transition-all duration-300 relative ${
        isCollapsed ? "w-20" : "w-64"
      } h-screen ${
        isDark
          ? "bg-[#0b0a1a]/95 border-[#1a1835] text-slate-100 shadow-[4px_0_30px_rgba(0,0,0,0.3)]"
          : "bg-white/80 border-navy-100/80 text-navy-900 shadow-[4px_0_24px_rgba(0,0,0,0.01)]"
      } backdrop-blur-xl`}
    >
      {/* Collapse/Expand Toggle Button */}
      <button
        onClick={() => setIsCollapsed(!isCollapsed)}
        className={`absolute top-5 -right-3 h-6 w-6 rounded-full border text-white flex items-center justify-center cursor-pointer shadow-md hover:scale-105 transition-all hidden md:flex ${
          isDark ? "bg-[#8b5cf6] border-[#a78bfa] hover:bg-[#7c3aed]" : "bg-navy-900 border-navy-850 hover:bg-navy-800"
        }`}
      >
        {isCollapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
      </button>

      <div className="flex flex-col gap-6 overflow-y-auto max-h-[calc(100vh-140px)] pr-1 scrollbar-thin">
        {/* Brand Logo & Info */}
        <div className="flex items-center gap-3 pl-1 select-none py-2">
          <div className={`h-10 w-10 shrink-0 rounded-xl flex items-center justify-center border shadow-sm ${
            isDark ? "bg-[#14122d] border-[#2c2663]" : "bg-navy-50 border-navy-100"
          }`}>
            <ShieldCheck className={`h-5.5 w-5.5 ${isDark ? "text-[#a78bfa]" : "text-navy-900"}`} />
          </div>
          {!isCollapsed && (
            <div className="flex flex-col animate-fade-in">
              <span className={`text-base font-semibold tracking-tight leading-none ${isDark ? "text-white" : "text-navy-900"}`}>Genesis.id</span>
              <span className="text-[10px] uppercase font-bold text-gold tracking-wider mt-1.5 leading-none">Otoritas Admin</span>
            </div>
          )}
        </div>

        {/* Admin Profile Widget */}
        <div className={`rounded-2xl p-3 border select-none flex items-center gap-3 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)] ${isCollapsed ? "justify-center" : ""} ${
          isDark ? "border-[#1e1a44] bg-[#121028]/80" : "border-navy-100/60 bg-navy-50/50"
        }`}>
          <div className="relative shrink-0">
            <div className={`h-10 w-10 rounded-full flex items-center justify-center font-bold shadow-sm text-sm ${
              isDark ? "bg-[#25215c] text-white border border-[#3e388d]" : "bg-navy-900 text-white border border-navy-800"
            }`}>
              {adminName.charAt(0).toUpperCase()}
            </div>
            <div className="absolute bottom-0 right-0 h-3 w-3 rounded-full bg-emerald border-2 border-white flex items-center justify-center shadow-sm">
              <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />
            </div>
          </div>
          {!isCollapsed && (
            <div className="flex flex-col min-w-0 animate-fade-in">
              <span className={`text-xs font-bold truncate leading-tight ${isDark ? "text-slate-100" : "text-navy-900"}`}>{adminName}</span>
              <span className={`text-[10px] truncate leading-none mt-1 ${isDark ? "text-slate-400" : "text-navy-500/85"}`}>{adminEmail}</span>
            </div>
          )}
        </div>

        {/* Grouped Tab Navigation Links */}
        <nav className="flex flex-col gap-5">
          {menuGroups.map((group, groupIdx) => (
            <div key={groupIdx} className="flex flex-col gap-1.5">
              {!isCollapsed ? (
                <span className={`text-[9px] font-bold tracking-widest pl-3 uppercase select-none ${
                  isDark ? "text-slate-500" : "text-navy-400"
                }`}>
                  {group.title}
                </span>
              ) : (
                <div className={`border-t my-1 mx-2 ${isDark ? "border-[#1e1a44]/50" : "border-navy-100/40"}`} />
              )}

              {group.items.map((item) => {
                const isActive = activeTab === item.id;
                return (
                  <div key={item.id} className="relative group">
                    <button
                      onClick={() => setActiveTab(item.id as AdminTab)}
                      className={`w-full flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-200 cursor-pointer ${
                        isActive
                          ? isDark
                            ? "bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-[0_4px_15px_rgba(139,92,246,0.35)] font-bold scale-[1.01]"
                            : "bg-navy-900 text-white shadow-[0_4px_12px_rgba(5,12,24,0.1)] font-bold scale-[1.01]"
                          : isDark
                            ? "text-slate-400 hover:text-white hover:bg-[#1a173c]/60"
                            : "text-navy-600 hover:text-navy-900 hover:bg-navy-50/70"
                      } ${isCollapsed ? "justify-center px-0" : ""}`}
                    >
                      <span className={`${isActive ? "text-white" : isDark ? "text-slate-400 group-hover:text-slate-200" : "text-navy-500"}`}>
                        {item.icon}
                      </span>
                      {!isCollapsed && (
                        <span className="truncate">{item.label}</span>
                      )}

                      {/* Badge (Pending Count, etc) */}
                      {item.badge !== undefined && (
                        isCollapsed ? (
                          <span className="absolute top-2 right-2 h-2 w-2 bg-burgundy-500 rounded-full animate-ping" />
                        ) : (
                          <span className="ml-auto bg-burgundy-500 text-white text-[9px] font-bold px-2 py-0.5 rounded-full animate-bounce">
                            {item.badge}
                          </span>
                        )
                      )}
                    </button>

                    {/* Collapsed Hover Tooltip */}
                    {isCollapsed && (
                      <div className={`absolute left-16 top-1/2 -translate-y-1/2 text-[10px] font-bold px-2.5 py-1.5 rounded-lg shadow-lg border opacity-0 group-hover:opacity-100 pointer-events-none transition-all duration-200 whitespace-nowrap z-50 translate-x-2 group-hover:translate-x-0 ${
                        isDark ? "bg-[#14122d] text-white border-[#27235a]" : "bg-navy-950 text-white border-navy-800"
                      }`}>
                        {item.label}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          ))}
        </nav>
      </div>

      {/* Footer Actions inside Sidebar */}
      <div className="flex flex-col gap-4 mt-4 shrink-0">
        {/* Mode Status Indicator */}
        <div className={`flex items-center gap-1.5 px-2 select-none ${isCollapsed ? "justify-center" : ""}`}>
          <span className={`h-2 w-2 rounded-full shrink-0 ${isLive ? "bg-emerald" : "bg-gold"} animate-pulse`} />
          {!isCollapsed && (
            <span className={`text-[10px] font-medium truncate animate-fade-in ${isDark ? "text-slate-400" : "text-navy-500"}`}>
              Mode: <strong className={isDark ? "text-slate-200" : "text-navy-900"}>{isLive ? "Live API" : "Simulasi"}</strong>
            </span>
          )}
        </div>

        <button
          onClick={handleLogout}
          className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl border transition-all duration-200 cursor-pointer ${
            isCollapsed ? "justify-center px-0" : ""
          } ${
            isDark
              ? "border-[#211e47] text-slate-400 hover:text-red-400 hover:bg-red-950/15 hover:border-red-900/30"
              : "border-navy-100 text-navy-600 hover:text-burgundy-900 hover:bg-burgundy-50/70 hover:border-burgundy-200"
          }`}
        >
          <LogOut className="h-4 w-4 text-burgundy-500 shrink-0" />
          {!isCollapsed && <span className="animate-fade-in">Logout Otoritas</span>}
        </button>
      </div>
    </aside>
  );
}
