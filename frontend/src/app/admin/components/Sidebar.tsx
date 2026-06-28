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
  Sun,
  Moon,
  Wifi,
  WifiOff,
  Dot
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
  onToggleTheme?: () => void;
  onToggleMode?: () => void;
}

export default function Sidebar({
  adminName,
  adminEmail,
  activeTab,
  setActiveTab,
  isLive,
  pendingHumanCount,
  handleLogout,
  theme = "light",
  onToggleTheme,
  onToggleMode
}: SidebarProps) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const isDark = theme === "dark";

  const menuGroups = [
    {
      title: "OVERVIEW",
      items: [
        { id: "overview", label: "Ringkasan Analitik", icon: <Activity className="h-[18px] w-[18px] shrink-0" /> },
        {
          id: "reports",
          label: "Laporan Spasial",
          icon: <MapPin className="h-[18px] w-[18px] shrink-0" />,
          badge: pendingHumanCount > 0 ? pendingHumanCount : undefined
        },
        { id: "profiles", label: "Kontrol Warga", icon: <Users className="h-[18px] w-[18px] shrink-0" /> }
      ]
    },
    {
      title: "ENGAGE",
      items: [
        { id: "challenges", label: "Pusat Tantangan", icon: <Trophy className="h-[18px] w-[18px] shrink-0" /> },
        { id: "broadcast", label: "Pusat Siaran", icon: <Bell className="h-[18px] w-[18px] shrink-0" /> }
      ]
    },
    {
      title: "SYSTEM",
      items: [
        { id: "rag", label: "Knowledge Base AI", icon: <FileText className="h-[18px] w-[18px] shrink-0" /> },
        { id: "audit", label: "Audit Trail", icon: <ClipboardList className="h-[18px] w-[18px] shrink-0" /> }
      ]
    }
  ];

  return (
    <aside
      className={`shrink-0 flex flex-col justify-between z-20 transition-all duration-500 ease-[cubic-bezier(0.34,1.56,0.64,1)] relative select-none ${
        isCollapsed ? "w-[72px]" : "w-[260px]"
      } h-screen md:h-[calc(100vh-2rem)] md:my-4 md:ml-4 md:rounded-2xl border ${
        isDark
          ? "bg-black text-slate-100 border-zinc-900 shadow-[0_8px_30px_rgb(0,0,0,0.5)]"
          : "bg-white text-slate-800 border-slate-200/80 shadow-[0_8px_30px_rgb(0,0,0,0.04)]"
      }`}
    >
      {/* Collapse Toggle — pill on the edge */}
      <button
        onClick={() => setIsCollapsed(!isCollapsed)}
        className={`absolute top-7 -right-3 h-6 w-6 rounded-full flex items-center justify-center cursor-pointer z-30 transition-all duration-200 shadow-sm hover:scale-110 ${
          isDark
            ? "bg-zinc-900 border border-zinc-800 text-slate-400 hover:text-white"
            : "bg-white border border-slate-200 text-slate-500 hover:text-slate-900 shadow-md"
        }`}
        aria-label={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
      >
        {isCollapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
      </button>

      {/* Top Section */}
      <div className={`flex flex-col gap-6 ${isCollapsed ? "px-3" : "px-4"} pt-5 overflow-y-auto flex-1 scrollbar-thin`}>

        {/* Brand */}
        <div className={`flex items-center gap-3 ${isCollapsed ? "justify-center" : ""} py-1`}>
          <div className={`h-9 w-9 shrink-0 rounded-lg flex items-center justify-center ${
            isDark ? "bg-zinc-800" : "bg-slate-900"
          }`}>
            <ShieldCheck className={`h-[18px] w-[18px] ${isDark ? "text-white" : "text-white"}`} />
          </div>
          {!isCollapsed && (
            <div className="flex flex-col">
              <span className={`text-[13px] font-semibold tracking-tight leading-none ${isDark ? "text-white" : "text-slate-900"}`}>Genesis.id</span>
              <span className={`text-[10px] font-medium mt-1 leading-none ${isDark ? "text-slate-500" : "text-slate-400"}`}>Admin Console</span>
            </div>
          )}
        </div>

        {/* Admin Profile */}
        <div className={`rounded-xl p-2.5 flex items-center gap-2.5 ${isCollapsed ? "justify-center" : ""} ${
          isDark ? "bg-zinc-900/50 border border-zinc-800/40" : "bg-slate-50"
        }`}>
          <div className="relative shrink-0">
            <div className={`h-8 w-8 rounded-lg flex items-center justify-center text-xs font-semibold ${
              isDark ? "bg-zinc-800 text-white" : "bg-slate-900 text-white"
            }`}>
              {adminName.charAt(0).toUpperCase()}
            </div>
            <div className={`absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full border-2 ${
              isDark ? "border-black" : "border-white"
            } ${isLive ? "bg-emerald-500" : "bg-amber-400"}`} />
          </div>
          {!isCollapsed && (
            <div className="flex flex-col min-w-0">
              <span className={`text-[11px] font-semibold truncate leading-tight ${isDark ? "text-slate-200" : "text-slate-800"}`}>{adminName}</span>
              <span className={`text-[10px] truncate leading-none mt-0.5 ${isDark ? "text-slate-500" : "text-slate-400"}`}>{adminEmail}</span>
            </div>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex flex-col gap-5">
          {menuGroups.map((group, groupIdx) => (
            <div key={groupIdx} className="flex flex-col gap-0.5">
              {!isCollapsed ? (
                <span className={`text-[9px] font-semibold tracking-[0.12em] uppercase mb-1.5 ${
                  isCollapsed ? "hidden" : "block"
                } ${isDark ? "text-slate-600" : "text-slate-400"} ${isCollapsed ? "" : "pl-3"}`}>
                  {group.title}
                </span>
              ) : (
                groupIdx > 0 && (
                  <div className={`my-2 mx-2 ${isDark ? "border-t border-white/[0.04]" : "border-t border-slate-100"}`} />
                )
              )}

              {group.items.map((item) => {
                const isActive = activeTab === item.id;
                return (
                  <div key={item.id} className="relative group">
                    <button
                      onClick={() => setActiveTab(item.id as AdminTab)}
                      className={`w-full flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer relative ${
                        isCollapsed ? "justify-center px-0 py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
                      } ${
                        isActive
                          ? isDark
                            ? "bg-zinc-800 text-white"
                            : "bg-slate-900 text-white"
                          : isDark
                            ? "text-slate-500 hover:text-slate-200 hover:bg-white/[0.04]"
                            : "text-slate-500 hover:text-slate-800 hover:bg-slate-50"
                      }`}
                    >
                      {/* Active indicator bar */}
                      {isActive && !isCollapsed && (
                        <div className={`absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-4 rounded-r-full ${
                          isDark ? "bg-white" : "bg-slate-900"
                        }`} />
                      )}

                      <span className={`${isActive ? (isDark ? "text-white" : "text-white") : ""}`}>
                        {item.icon}
                      </span>
                      {!isCollapsed && (
                        <span className="truncate">{item.label}</span>
                      )}

                      {/* Notification badge */}
                      {item.badge !== undefined && (
                        isCollapsed ? (
                          <span className="absolute top-1 right-1 h-2 w-2 bg-red-500 rounded-full" />
                        ) : (
                          <span className={`ml-auto text-[10px] font-semibold px-1.5 py-0.5 rounded-md ${
                            isDark
                              ? "bg-red-500/15 text-red-400"
                              : isActive
                                ? "bg-white/20 text-white"
                                : "bg-red-50 text-red-600"
                          }`}>
                            {item.badge}
                          </span>
                        )
                      )}
                    </button>

                    {/* Collapsed tooltip */}
                    {isCollapsed && (
                      <div className={`absolute left-full top-1/2 -translate-y-1/2 ml-2 text-[11px] font-medium px-2.5 py-1.5 rounded-md shadow-lg opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-150 whitespace-nowrap z-50 ${
                        isDark ? "bg-zinc-900 text-slate-200 shadow-black/30 border border-zinc-800" : "bg-slate-800 text-white shadow-slate-200/50"
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

      {/* Bottom Section — Controls */}
      <div className={`flex flex-col gap-2 ${isCollapsed ? "px-3" : "px-4"} pb-4 shrink-0`}>

        {/* Separator */}
        <div className={`${isDark ? "border-t border-white/[0.04]" : "border-t border-slate-100"} mb-1`} />

        {/* Theme Toggle */}
        {onToggleTheme && (
          <button
            onClick={onToggleTheme}
            className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
              isCollapsed ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
            } ${
              isDark
                ? "text-slate-500 hover:text-amber-300 hover:bg-amber-500/[0.06]"
                : "text-slate-500 hover:text-slate-900 hover:bg-slate-100"
            }`}
            aria-label="Toggle theme"
          >
            {isDark ? (
              <>
                <Sun className="h-[18px] w-[18px] shrink-0" />
                {!isCollapsed && <span>Light Mode</span>}
              </>
            ) : (
              <>
                <Moon className="h-[18px] w-[18px] shrink-0" />
                {!isCollapsed && <span>Dark Mode</span>}
              </>
            )}
          </button>
        )}

        {/* Connection Mode Toggle */}
        {onToggleMode && (
          <button
            onClick={onToggleMode}
            className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
              isCollapsed ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
            } ${
              isDark
                ? "text-slate-500 hover:text-slate-200 hover:bg-white/[0.04]"
                : "text-slate-500 hover:text-slate-800 hover:bg-slate-50"
            }`}
            aria-label="Toggle connection mode"
          >
            {isLive ? (
              <>
                <Wifi className="h-[18px] w-[18px] shrink-0 text-emerald-500" />
                {!isCollapsed && (
                  <span className="flex items-center gap-1.5">
                    <span>Live API</span>
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  </span>
                )}
              </>
            ) : (
              <>
                <WifiOff className="h-[18px] w-[18px] shrink-0 text-amber-400" />
                {!isCollapsed && <span>Simulator</span>}
              </>
            )}
          </button>
        )}

        {/* Logout */}
        <button
          onClick={handleLogout}
          className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
            isCollapsed ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
          } ${
            isDark
              ? "text-slate-500 hover:text-red-400 hover:bg-red-500/[0.06]"
              : "text-slate-500 hover:text-red-600 hover:bg-red-50"
          }`}
        >
          <LogOut className="h-[18px] w-[18px] shrink-0" />
          {!isCollapsed && <span>Logout</span>}
        </button>
      </div>
    </aside>
  );
}
