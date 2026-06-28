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
}

export default function AuditTab({
  auditLogs,
  handleClearAuditLogs,
  theme = "light"
}: AuditTabProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState("all");
  const [isClearConfirmOpen, setIsClearConfirmOpen] = useState(false);

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
      alert("Tidak ada log audit untuk diekspor.");
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
    <div className="flex flex-col gap-8 animate-fade-up">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-navy-900">Log Audit Administratif</h1>
        <p className="text-xs text-navy-500 font-light mt-1.5">
          Pantau riwayat operasi sensitif yang dilakukan oleh seluruh administrator Genesis.id secara transparan dan aman.
        </p>
      </div>

      {/* Main Table Panel */}
      <div className="bg-white rounded-3xl p-6 border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)] flex flex-col gap-6">
        
        {/* Controls Bar */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex flex-col md:flex-row items-center gap-3 w-full md:w-auto">
            
            {/* Search Input */}
            <div className="relative w-full md:w-80">
              <span className="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none text-navy-400">
                <Search className="h-4 w-4" />
              </span>
              <input
                type="text"
                placeholder="Cari admin, tindakan, detail log..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-surface border border-navy-100 rounded-2xl pl-11 pr-4 py-2.5 text-xs text-navy-900 placeholder:text-navy-400 focus:outline-none focus:border-navy-500 transition-all font-light"
              />
            </div>

            {/* Filter Dropdown */}
            <div className="relative w-full md:w-52">
              <span className="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none text-navy-400">
                <Filter className="h-4 w-4" />
              </span>
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className="w-full bg-surface border border-navy-100 rounded-2xl pl-11 pr-4 py-2.5 text-xs text-navy-900 focus:outline-none focus:border-navy-500 transition-all cursor-pointer font-medium appearance-none"
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
          <div className="flex items-center gap-3 w-full md:w-auto justify-end">
            <button
              onClick={handleExportText}
              className="flex items-center gap-2 bg-navy-900 hover:bg-navy-850 text-white rounded-2xl px-5 py-2.5 text-xs font-bold transition-all shadow-sm cursor-pointer hover:scale-[1.01] active:scale-[0.99]"
            >
              <Download className="h-4 w-4" />
              Unduh Log (.txt)
            </button>
            
            {auditLogs.length > 0 && (
              <button
                onClick={() => {
                  setIsClearConfirmOpen(true);
                }}
                className="flex items-center gap-2 border border-red-200 bg-red-50 text-red-700 hover:bg-red-100 hover:border-red-300 rounded-2xl px-5 py-2.5 text-xs font-bold transition-all cursor-pointer"
              >
                <Trash2 className="h-4 w-4" />
                Bersihkan Log
              </button>
            )}
          </div>
        </div>

        {/* Audit Log Table */}
        <div className="overflow-x-auto border border-navy-100/50 rounded-2xl">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-surface border-b border-navy-100 select-none">
                <th className="p-4 text-[10px] font-bold text-navy-500 uppercase tracking-wider w-16">No</th>
                <th className="p-4 text-[10px] font-bold text-navy-500 uppercase tracking-wider w-40">Waktu</th>
                <th className="p-4 text-[10px] font-bold text-navy-500 uppercase tracking-wider w-44">Admin</th>
                <th className="p-4 text-[10px] font-bold text-navy-500 uppercase tracking-wider w-48">Tindakan</th>
                <th className="p-4 text-[10px] font-bold text-navy-500 uppercase tracking-wider">Detail Aktivitas</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-navy-50">
              {filteredLogs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center text-center">
                      <div className="h-10 w-10 rounded-2xl bg-surface flex items-center justify-center text-navy-300 border border-navy-100/50 mb-3">
                        <ShieldCheck className="h-5 w-5" />
                      </div>
                      <p className="text-xs font-bold text-navy-800">Tidak Ada Log Terdeteksi</p>
                      <p className="text-[11px] text-navy-400 font-light mt-1">
                        Pencatatan aktivitas administrator kosong atau kata kunci pencarian Anda tidak cocok.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredLogs.map((log, idx) => (
                  <tr key={log.id} className="hover:bg-surface/50 transition-colors">
                    <td className="p-4 text-xs font-bold text-navy-400 font-mono">{idx + 1}</td>
                    <td className="p-4 text-xs text-navy-500 font-light">
                      <div className="flex items-center gap-1.5">
                        <Calendar className="h-3.5 w-3.5 text-navy-400" />
                        <span>
                          {new Date(log.timestamp).toLocaleDateString("id-ID", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric"
                          })}
                        </span>
                        <span className="text-[10px] text-navy-300 font-mono">
                          {new Date(log.timestamp).toLocaleTimeString("id-ID", {
                            hour: "2-digit",
                            minute: "2-digit",
                            second: "2-digit"
                          })}
                        </span>
                      </div>
                    </td>
                    <td className="p-4 text-xs font-bold text-navy-900">{log.adminName}</td>
                    <td className="p-4">
                      <span className="inline-flex items-center gap-1 bg-navy-50 border border-navy-100/40 text-navy-700 px-2.5 py-1 rounded-lg text-[10px] font-bold">
                        <Clipboard className="h-3 w-3 text-navy-400" />
                        {log.actionType}
                      </span>
                    </td>
                    <td className="p-4 text-xs text-navy-600 font-light leading-relaxed whitespace-pre-line">
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
        <div className="fixed inset-0 bg-navy-950/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in select-none">
          <div className={`w-full max-w-sm ${theme === "dark" ? "bg-[#131127]/95 border-indigo-900/40 text-slate-100" : "bg-white/95 text-navy-900 border-navy-100"} border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center`}>
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center bg-red-50 border border-red-100 text-red-600 animate-bounce">
              <Trash2 className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">Bersihkan Log Audit Administratif</h3>
              <p className="text-xs text-navy-500 font-light leading-relaxed mt-2">
                Apakah Anda yakin ingin menghapus seluruh riwayat log audit ini? Tindakan ini bersifat sensitif dan riwayat log aktivitas admin tidak dapat dipulihkan kembali!
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => setIsClearConfirmOpen(false)}
                className="flex-1 rounded-xl border border-navy-100 text-navy-700 hover:bg-navy-50 py-2.5 text-xs font-bold transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={async () => {
                  await handleClearAuditLogs();
                  setIsClearConfirmOpen(false);
                }}
                className="flex-1 rounded-xl bg-red-600 hover:bg-red-700 text-white py-2.5 text-xs font-bold transition-all cursor-pointer shadow-md"
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
