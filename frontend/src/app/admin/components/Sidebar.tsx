"use client";

import React, { useState } from "react";
import {
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
  X
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
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
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
  onToggleMode,
  isOpenMobile = false,
  onCloseMobile
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

  const handleTabClick = (tabId: AdminTab) => {
    setActiveTab(tabId);
    if (onCloseMobile) {
      onCloseMobile();
    }
  };

  return (
    <>
      {/* Mobile Backdrop Blur Overlay */}
      {isOpenMobile && (
        <div 
          onClick={onCloseMobile}
          className="fixed inset-0 bg-black/50 backdrop-blur-xs z-40 md:hidden transition-opacity duration-300 animate-fade-in"
        />
      )}

      {/* Sidebar Container */}
      <aside
        className={`fixed md:sticky top-0 md:top-4 z-50 md:z-20 shrink-0 flex flex-col justify-between select-none transition-all duration-300 md:duration-500 md:ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
          isOpenMobile ? "translate-x-0" : "-translate-x-full md:translate-x-0"
        } ${
          isCollapsed ? "md:w-[72px]" : "md:w-[260px]"
        } w-[260px] h-screen md:h-[calc(100vh-2rem)] md:my-4 md:ml-4 md:rounded-2xl border ${
          isDark
            ? "bg-black text-slate-100 border-zinc-900 shadow-[0_8px_30px_rgba(0,0,0,0.7)]"
            : "bg-white text-slate-800 border-slate-200/80 shadow-[0_8px_30px_rgba(0,0,0,0.03)]"
        }`}
      >
        {/* Collapse Toggle — visible only on desktop */}
        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className={`absolute top-7 -right-3 h-6 w-6 rounded-full items-center justify-center cursor-pointer z-30 transition-all duration-200 shadow-sm hover:scale-110 hidden md:flex ${
            isDark
              ? "bg-zinc-900 border border-zinc-800 text-slate-400 hover:text-white"
              : "bg-white border border-slate-200 text-slate-500 hover:text-slate-900 shadow-md"
          }`}
          aria-label={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          {isCollapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
        </button>

        {/* Mobile Close Button — visible only on mobile */}
        <button
          onClick={onCloseMobile}
          className={`absolute top-5 right-4 p-2 rounded-xl border md:hidden focus:outline-none ${
            isDark 
              ? "border-zinc-850 text-slate-400 hover:bg-zinc-900" 
              : "border-slate-100 text-slate-500 hover:bg-slate-50"
          }`}
          aria-label="Close sidebar"
        >
          <X className="h-4.5 w-4.5" />
        </button>

        {/* Top Section */}
        <div className={`flex flex-col gap-6 ${isCollapsed ? "md:px-3" : "px-4"} pt-5 overflow-y-auto flex-1 scrollbar-thin`}>

          {/* Brand */}
          <div className={`flex items-center gap-3 ${isCollapsed ? "md:justify-center" : ""} py-1 pr-8 md:pr-0`}>
            <div className="h-9 w-9 shrink-0 flex items-center justify-center">
              <img src="/logo.png" alt="Genesis Logo" className="h-7 w-auto object-contain" />
            </div>
            {(!isCollapsed || isOpenMobile) && (
              <div className="flex flex-col">
                <span className={`text-[13px] font-bold tracking-tight leading-none ${isDark ? "text-white" : "text-slate-900"}`}>Genesis</span>
                <span className={`text-[10px] font-medium mt-1 leading-none ${isDark ? "text-slate-500" : "text-slate-400"}`}>Admin Console</span>
              </div>
            )}
          </div>

          {/* Admin Profile */}
          <div className={`rounded-xl p-2.5 flex items-center gap-2.5 ${isCollapsed ? "md:justify-center" : ""} ${
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
            {(!isCollapsed || isOpenMobile) && (
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
                {(!isCollapsed || isOpenMobile) ? (
                  <span className={`text-[9px] font-semibold tracking-[0.12em] uppercase mb-1.5 ${
                    isDark ? "text-slate-600" : "text-slate-400"
                  } pl-3`}>
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
                        onClick={() => handleTabClick(item.id as AdminTab)}
                        className={`w-full flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer relative ${
                          (isCollapsed && !isOpenMobile) ? "justify-center px-0 py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
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
                        {isActive && (isCollapsed && !isOpenMobile) && (
                          <div className={`absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-4 rounded-r-full ${
                            isDark ? "bg-white" : "bg-slate-900"
                          }`} />
                        )}

                        <span className={`${isActive ? "text-white" : ""}`}>
                          {item.icon}
                        </span>
                        {(!isCollapsed || isOpenMobile) && (
                          <span className="truncate">{item.label}</span>
                        )}

                        {/* Notification badge */}
                        {item.badge !== undefined && (
                          (isCollapsed && !isOpenMobile) ? (
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

                      {/* Collapsed tooltip — desktop only */}
                      {isCollapsed && (
                        <div className={`absolute left-full top-1/2 -translate-y-1/2 ml-2 text-[11px] font-medium px-2.5 py-1.5 rounded-md shadow-lg opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-150 whitespace-nowrap z-50 hidden md:block ${
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
        <div className={`flex flex-col gap-2 ${isCollapsed ? "md:px-3" : "px-4"} pb-4 shrink-0`}>

          {/* Separator */}
          <div className={`${isDark ? "border-t border-white/[0.04]" : "border-t border-slate-100"} mb-1`} />

          {/* Theme Toggle */}
          {onToggleTheme && (
            <button
              onClick={onToggleTheme}
              className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
                (isCollapsed && !isOpenMobile) ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
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
                  {(!isCollapsed || isOpenMobile) && <span>Light Mode</span>}
                </>
              ) : (
                <>
                  <Moon className="h-[18px] w-[18px] shrink-0" />
                  {(!isCollapsed || isOpenMobile) && <span>Dark Mode</span>}
                </>
              )}
            </button>
          )}

          {/* Connection Mode Toggle */}
          {onToggleMode && (
            <button
              onClick={onToggleMode}
              className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
                (isCollapsed && !isOpenMobile) ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
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
                  {(!isCollapsed || isOpenMobile) && (
                    <span className="flex items-center gap-1.5">
                      <span>Live API</span>
                      <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                    </span>
                  )}
                </>
              ) : (
                <>
                  <WifiOff className="h-[18px] w-[18px] shrink-0 text-amber-400" />
                  {(!isCollapsed || isOpenMobile) && <span>Simulator</span>}
                </>
              )}
            </button>
          )}

          {/* Logout */}
          <button
            onClick={handleLogout}
            className={`flex items-center gap-2.5 text-[12px] font-medium rounded-lg transition-all duration-150 cursor-pointer ${
              (isCollapsed && !isOpenMobile) ? "justify-center py-2.5 mx-auto w-10 h-10" : "px-3 py-2"
            } ${
              isDark
                ? "text-slate-500 hover:text-red-400 hover:bg-red-500/[0.06]"
                : "text-slate-500 hover:text-red-600 hover:bg-red-50"
            }`}
          >
            <LogOut className="h-[18px] w-[18px] shrink-0" />
            {(!isCollapsed || isOpenMobile) && <span>Logout</span>}
          </button>
        </div>
      </aside>
    </>
  );
}
