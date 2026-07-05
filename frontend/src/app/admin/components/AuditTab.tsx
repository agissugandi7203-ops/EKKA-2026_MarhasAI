"use client";

import React, { useState } from "react";
import { ShieldCheck, Search, Download, Trash2, Calendar, Clipboard, Filter } from "lucide-react";

export interface AuditLog {
  id: string;
  adminName: string;
  actionType: string;
  detail: string;
  timestamp: string;
}

interface AuditTabProps {
  auditLogs: AuditLog[];
  handleClearAuditLogs: () => Promise<void>;
  theme?: "light" | "dark";
  showToast?: (message: string, type: "success" | "error" | "info") => void;
}

export default function AuditTab({
  auditLogs,
  handleClearAuditLogs,
  theme = "light",
  showToast
}: AuditTabProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState("all");
  const [isClearConfirmOpen, setIsClearConfirmOpen] = useState(false);
  const isDark = theme === "dark";

  // Filter logs
  const filteredLogs = auditLogs.filter((log) => {
    const matchesSearch =
      log.adminName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.actionType.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.detail.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesFilter = filterType === "all" || log.actionType.toLowerCase() === filterType.toLowerCase();

    return matchesSearch && matchesFilter;
  });

  // Action types list for dropdown
  const uniqueActions = Array.from(new Set(auditLogs.map((log) => log.actionType)));

  // Export to TXT
  const handleExportText = () => {
    if (filteredLogs.length === 0) {
      showToast?.("Tidak ada log audit untuk diekspor.", "error");
      return;
    }

    let output = "========================================================\n";
    output += "          GENESIS.ID ADMINISTRATOR AUDIT TRAIL LOG      \n";
    output += `          Dibuat pada: ${new Date().toLocaleString("id-ID")}\n`;
    output += "========================================================\n\n";

    filteredLogs.forEach((log, index) => {
      output += `[LOG #${index + 1}]\n`;
      output += `ID Log      : ${log.id}\n`;
      output += `Admin       : ${log.adminName}\n`;
      output += `Aksi        : ${log.actionType}\n`;
      output += `Detail      : ${log.detail}\n`;
      output += `Waktu       : ${new Date(log.timestamp).toLocaleString("id-ID")}\n`;
      output += "--------------------------------------------------------\n";
    });

    const blob = new Blob([output], { type: "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `genesis_audit_log_${new Date().toISOString().split("T")[0]}.txt`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up">
      {/* Header */}
      <div>
        <h1 className={`text-2xl font-bold tracking-tight ${isDark ? "text-white" : "text-slate-900"}`}>
          Log Audit Administratif
        </h1>
        <p className={`text-xs font-light mt-1.5 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
          Pantau riwayat operasi sensitif yang dilakukan oleh seluruh administrator Genesis.id secara transparan dan aman.
        </p>
      </div>

      {/* Main Table Panel */}
      <div className={`rounded-3xl p-6 border shadow-sm flex flex-col gap-6 ${
        isDark ? "bg-zinc-950 border-zinc-900 text-white" : "bg-white border-slate-100 text-slate-800"
      }`}>
        
        {/* Controls Bar */}
        <div className="flex flex-col lg:flex-row items-center justify-between gap-4">
          <div className="flex flex-col md:flex-row items-center gap-3 w-full lg:w-auto">
            
            {/* Search Input */}
            <div className="relative w-full md:w-80">
              <span className={`absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none ${isDark ? "text-slate-500" : "text-slate-400"}`}>
                <Search className="h-4 w-4" />
              </span>
              <input
                type="text"
                placeholder="Cari admin, tindakan, detail log..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className={`w-full border rounded-2xl pl-11 pr-4 py-2.5 text-xs focus:outline-none transition-all font-light ${
                  isDark 
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700 placeholder:text-zinc-500" 
                    : "bg-slate-50 border-slate-200 text-slate-900 focus:border-slate-350 placeholder:text-slate-400"
                }`}
              />
            </div>

            {/* Filter Dropdown */}
            <div className="relative w-full md:w-52">
              <span className={`absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none ${isDark ? "text-slate-500" : "text-slate-400"}`}>
                <Filter className="h-4 w-4" />
              </span>
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className={`w-full border rounded-2xl pl-11 pr-4 py-2.5 text-xs focus:outline-none transition-all cursor-pointer font-medium ${
                  isDark
                    ? "bg-zinc-900 border-zinc-800 text-white focus:border-zinc-700"
                    : "bg-slate-50 border-slate-200 text-slate-800 focus:border-slate-350"
                }`}
              >
                <option value="all">Semua Tindakan</option>
                {uniqueActions.map((action) => (
                  <option key={action} value={action}>
                    {action}
                  </option>
                ))}
              </select>
            </div>

          </div>

          {/* Action Buttons */}
          <div className="flex items-center gap-3 w-full lg:w-auto justify-end">
            <button
              onClick={handleExportText}
              className={`flex items-center gap-2 rounded-2xl px-5 py-2.5 text-xs font-bold transition-all shadow-sm cursor-pointer hover:scale-[1.01] active:scale-[0.99] ${
                isDark 
                  ? "bg-zinc-800 hover:bg-zinc-700 text-white" 
                  : "bg-slate-900 hover:bg-slate-850 text-white"
              }`}
            >
              <Download className="h-4 w-4" />
              Unduh Log (.txt)
            </button>
            
            {auditLogs.length > 0 && (
              <button
                onClick={() => {
                  setIsClearConfirmOpen(true);
                }}
                className={`flex items-center gap-2 rounded-2xl px-5 py-2.5 text-xs font-bold transition-all cursor-pointer ${
                  isDark
                    ? "bg-red-950/20 hover:bg-red-900/20 border border-red-900/30 text-red-400"
                    : "border border-red-100 bg-red-50 text-red-700 hover:bg-red-100"
                }`}
              >
                <Trash2 className="h-4 w-4" />
                Bersihkan Log
              </button>
            )}
          </div>
        </div>

        {/* Audit Log Table */}
        <div className={`overflow-x-auto border rounded-2xl ${isDark ? "border-zinc-900" : "border-slate-100"}`}>
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className={`border-b select-none ${isDark ? "bg-zinc-900/40 border-zinc-900" : "bg-slate-50/60 border-slate-150"}`}>
                <th className={`p-4 text-[10px] font-bold uppercase tracking-wider w-16 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>No</th>
                <th className={`p-4 text-[10px] font-bold uppercase tracking-wider w-40 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Waktu</th>
                <th className={`p-4 text-[10px] font-bold uppercase tracking-wider w-44 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Admin</th>
                <th className={`p-4 text-[10px] font-bold uppercase tracking-wider w-48 ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Tindakan</th>
                <th className={`p-4 text-[10px] font-bold uppercase tracking-wider ${isDark ? "text-zinc-500" : "text-slate-400"}`}>Detail Aktivitas</th>
              </tr>
            </thead>
            <tbody className={`divide-y ${isDark ? "divide-zinc-900" : "divide-slate-100"}`}>
              {filteredLogs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center text-center">
                      <div className={`h-10 w-10 rounded-2xl flex items-center justify-center border mb-3 ${
                        isDark ? "bg-zinc-900 border-zinc-800 text-zinc-650" : "bg-slate-50 border-slate-150 text-slate-300"
                      }`}>
                        <ShieldCheck className="h-5 w-5" />
                      </div>
                      <p className={`text-xs font-bold ${isDark ? "text-slate-300" : "text-slate-800"}`}>Tidak Ada Log Terdeteksi</p>
                      <p className={`text-[11px] font-light mt-1 ${isDark ? "text-slate-500" : "text-slate-400"}`}>
                        Pencatatan aktivitas administrator kosong atau kata kunci pencarian Anda tidak cocok.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredLogs.map((log, idx) => (
                  <tr key={log.id} className={`transition-colors ${isDark ? "hover:bg-zinc-900/40" : "hover:bg-slate-50/50"}`}>
                    <td className={`p-4 text-xs font-bold font-mono ${isDark ? "text-zinc-600" : "text-slate-400"}`}>{idx + 1}</td>
                    <td className="p-4 text-xs">
                      <div className="flex items-center gap-1.5">
                        <Calendar className={`h-3.5 w-3.5 ${isDark ? "text-zinc-550" : "text-slate-400"}`} />
                        <span className={isDark ? "text-slate-300" : "text-slate-650"}>
                          {new Date(log.timestamp).toLocaleDateString("id-ID", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric"
                          })}
                        </span>
                        <span className={`text-[10px] font-mono ${isDark ? "text-zinc-600" : "text-slate-400"}`}>
                          {new Date(log.timestamp).toLocaleTimeString("id-ID", {
                            hour: "2-digit",
                            minute: "2-digit",
                            second: "2-digit"
                          })}
                        </span>
                      </div>
                    </td>
                    <td className="p-4 text-xs font-bold">{log.adminName}</td>
                    <td className="p-4">
                      <span className={`inline-flex items-center gap-1 border px-2.5 py-1 rounded-lg text-[10px] font-bold ${
                        isDark 
                          ? "bg-zinc-900 border-zinc-800/40 text-zinc-300" 
                          : "bg-slate-50 border-slate-200/50 text-slate-700"
                      }`}>
                        <Clipboard className={`h-3 w-3 ${isDark ? "text-zinc-500" : "text-slate-400"}`} />
                        {log.actionType}
                      </span>
                    </td>
                    <td className={`p-4 text-xs font-light leading-relaxed whitespace-pre-line ${isDark ? "text-zinc-400" : "text-slate-600"}`}>
                      {log.detail}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

      </div>

      {/* --- IN-UI CUSTOM CRITICAL CLEAR LOGS MODAL (Glassmorphic) --- */}
      {isClearConfirmOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in select-none">
          <div className={`w-full max-w-sm border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center max-h-[90vh] overflow-y-auto ${
            isDark ? "bg-zinc-950 border-zinc-800 text-slate-100" : "bg-white/95 text-slate-900 border-slate-100"
          }`}>
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center bg-red-50 border border-red-100 text-red-600 animate-bounce">
              <Trash2 className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">Bersihkan Log Audit Administratif</h3>
              <p className={`text-xs font-light leading-relaxed mt-2 ${isDark ? "text-slate-400" : "text-slate-500"}`}>
                Apakah Anda yakin ingin menghapus seluruh riwayat log audit ini? Tindakan ini bersifat sensitif dan riwayat log aktivitas admin tidak dapat dipulihkan kembali!
              </p>
            </div>

            <div className="flex flex-col-reverse sm:flex-row items-stretch sm:items-center gap-3 w-full">
              <button
                onClick={() => setIsClearConfirmOpen(false)}
                className={`w-full sm:w-1/2 rounded-xl border py-2.5 text-xs font-bold transition-all cursor-pointer ${
                  isDark 
                    ? "border-zinc-800 text-zinc-400 hover:bg-zinc-900" 
                    : "border-slate-200 text-slate-655 hover:bg-slate-50"
                }`}
              >
                Batal
              </button>
              <button
                onClick={async () => {
                  await handleClearAuditLogs();
                  setIsClearConfirmOpen(false);
                }}
                className="w-full sm:w-1/2 rounded-xl bg-red-600 hover:bg-red-700 text-white py-2.5 text-xs font-bold transition-all cursor-pointer shadow-md"
              >
                Hapus Permanen
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
