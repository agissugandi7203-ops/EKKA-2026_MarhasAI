"use client";

import React, { useEffect, useRef, useState } from "react";
import {
  Search,
  Map,
  X,
  Clock,
  Sparkles,
  CheckCircle,
  UserCheck,
  MapPin,
  Trash2,
  ExternalLink,
  SlidersHorizontal,
  CheckSquare,
  Square,
  AlertTriangle
} from "lucide-react";
import { TrashReport } from "./OverviewTab";

interface ReportsTabProps {
  reports: TrashReport[];
  selectedReport: TrashReport | null;
  setSelectedReport: (report: TrashReport | null) => void;
  reportSearch: string;
  setReportSearch: (query: string) => void;
  reportFilter: string;
  setReportFilter: (filter: string) => void;
  adminFeedback: string;
  setAdminFeedback: (feedback: string) => void;
  handleUpdateReportStatus: (id: string, nextStatus: "approved" | "resolved" | "rejected") => void;
  handleDeleteReport: (id: string) => Promise<void>;
  handleBatchAction: (ids: string[], action: "approved" | "rejected" | "delete") => Promise<void>;
  actionLoading: boolean;
  loading: boolean;
  theme?: "light" | "dark";
}

export default function ReportsTab({
  reports,
  selectedReport,
  setSelectedReport,
  reportSearch,
  setReportSearch,
  reportFilter,
  setReportFilter,
  adminFeedback,
  setAdminFeedback,
  handleUpdateReportStatus,
  handleDeleteReport,
  handleBatchAction,
  actionLoading,
  loading,
  theme = "light"
}: ReportsTabProps) {
  const mapInstanceRef = useRef<any>(null);

  // Advanced Sorting & Area states
  const [sortBy, setSortBy] = useState<"newest" | "danger" | "lowest_ai">("newest");
  const [areaSearch, setAreaSearch] = useState("");
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Custom warning dialog states
  const [batchConfirmAction, setBatchConfirmAction] = useState<{ action: "approved" | "rejected" | "delete"; ids: string[] } | null>(null);
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

  // Leaflet Map Initialization with CartoDB Voyager/Positron Soft Tiles
  useEffect(() => {
    if (loading) return;

    let isMounted = true;
    
    const initLeafletMap = async () => {
      // Load Leaflet CSS
      if (!document.getElementById("leaflet-css")) {
        const link = document.createElement("link");
        link.id = "leaflet-css";
        link.rel = "stylesheet";
        link.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css";
        document.head.appendChild(link);
      }

      // Load Leaflet JS
      if (!(window as any).L) {
        await new Promise<void>((resolve, reject) => {
          const script = document.createElement("script");
          script.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js";
          script.onload = () => resolve();
          script.onerror = () => reject(new Error("Gagal memuat peta Leaflet"));
          document.head.appendChild(script);
        });
      }

      if (!isMounted) return;

      const L = (window as any).L;
      if (!L) return;

      // Clean up previous map instance
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }

      const mapContainer = document.getElementById("admin-gis-map");
      if (!mapContainer) return;

      // Centered on Surabaya / East Java
      const map = L.map("admin-gis-map", {
        zoomControl: false
      }).setView([-7.2504, 112.7508], 11);
      
      mapInstanceRef.current = map;

      L.control.zoom({
        position: "bottomright"
      }).addTo(map);

      // Add CartoDB Voyager tile layer (Soft Light Theme map tiles)
      L.tileLayer("https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png", {
        attribution: '&copy; OpenStreetMap &copy; CartoDB',
        subdomains: "abcd",
        maxZoom: 20
      }).addTo(map);

      // Register map interaction globally for leaflet popup callbacks
      (window as any).openReportFromMap = (id: string) => {
        const rep = reports.find(r => r.id === id);
        if (rep) setSelectedReport(rep);
      };

      // Add markers
      reports.forEach((rep) => {
        let lat = -7.2504;
        let lng = 112.7508;

        if (rep.coordinates?.latitude && rep.coordinates?.longitude) {
          lat = rep.coordinates.latitude;
          lng = rep.coordinates.longitude;
        } else if (rep.location && typeof rep.location === "object" && rep.location.coordinates) {
          lng = rep.location.coordinates[0];
          lat = rep.location.coordinates[1];
        } else if (typeof rep.location === "string" && rep.location.includes("POINT")) {
          const matches = rep.location.match(/POINT\(([-\d.]+)\s+([-\d.]+)\)/);
          if (matches && matches.length >= 3) {
            lng = parseFloat(matches[1]);
            lat = parseFloat(matches[2]);
          }
        }

        // Color coding based on status
        const statusColors: Record<string, string> = {
          pending_ai: "#f59e0b", // Warm Gold
          pending_human: "#d97706", // Darker Gold/Orange
          approved: "#10b981", // Emerald Green
          resolved: "#3b82f6", // Royal Blue
          rejected: "#ef4444" // Crimson Red
        };

        const color = statusColors[rep.status] || "#6b7280";

        // Pulsing custom divIcon
        const markerIcon = L.divIcon({
          className: "custom-map-pin",
          html: `
            <div class="relative flex items-center justify-center">
              <div style="background-color: ${color}20; width: 34px; height: 34px; border-radius: 50%; display: flex; align-items: center; justify-content: center;" class="animate-ping absolute pointer-events-none"></div>
              <div style="background-color: ${color}; width: 14px; height: 14px; border-radius: 50%; border: 2.5px solid #ffffff; box-shadow: 0 2px 10px ${color}80; cursor: pointer;"></div>
            </div>
          `,
          iconSize: [34, 34],
          iconAnchor: [17, 17]
        });

        const marker = L.marker([lat, lng], { icon: markerIcon }).addTo(map);

        const reporterName = rep.profiles?.full_name || rep.profiles?.username || "Warga Anonim";
        const contentString = `
          <div style="color: #0f172a; background-color: #ffffff; font-family: inherit; font-size: 11px; padding: 6px; border-radius: 12px; width: 180px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
            <div style="font-weight: 700; font-size: 12px; margin-bottom: 4px; color: #1e293b;">${rep.waste_type || "Tumpukan Sampah"}</div>
            <div style="color: #64748b; margin-bottom: 6px; font-weight: 500;">Oleh: ${reporterName}</div>
            <div style="max-height: 40px; overflow: hidden; text-overflow: ellipsis; margin-bottom: 8px; color: #334155; line-height: 1.4;">${rep.description || "Tanpa rincian deskripsi."}</div>
            <button onclick="window.openReportFromMap('${rep.id}')" style="background-color: #0f172a; color: #ffffff; border: none; padding: 6px 10px; border-radius: 8px; font-weight: 600; width: 100%; cursor: pointer; transition: transform 0.1s; font-size: 10px;">
              Pemeriksaan Absolut
            </button>
          </div>
        `;

        marker.bindPopup(contentString, {
          className: "light-premium-popup",
          closeButton: false,
          minWidth: 190
        });
      });
    };

    initLeafletMap();

    return () => {
      isMounted = false;
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, [reports, loading]);

  // Handle auto centering / panning to selected report
  useEffect(() => {
    if (!selectedReport || !mapInstanceRef.current) return;
    const L = (window as any).L;
    if (!L) return;

    let lat = -7.2504;
    let lng = 112.7508;

    if (selectedReport.coordinates?.latitude && selectedReport.coordinates?.longitude) {
      lat = selectedReport.coordinates.latitude;
      lng = selectedReport.coordinates.longitude;
    } else if (selectedReport.location && typeof selectedReport.location === "object" && selectedReport.location.coordinates) {
      lng = selectedReport.location.coordinates[0];
      lat = selectedReport.location.coordinates[1];
    } else if (typeof selectedReport.location === "string" && selectedReport.location.includes("POINT")) {
      const matches = selectedReport.location.match(/POINT\(([-\d.]+)\s+([-\d.]+)\)/);
      if (matches && matches.length >= 3) {
        lng = parseFloat(matches[1]);
        lat = parseFloat(matches[2]);
      }
    }

    mapInstanceRef.current.setView([lat, lng], 15, { animate: true, duration: 1 });
  }, [selectedReport]);

  // Handle checkbox selection
  const toggleSelectAll = () => {
    if (selectedIds.length === filteredReports.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(filteredReports.map((r) => r.id));
    }
  };

  const toggleSelectId = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (selectedIds.includes(id)) {
      setSelectedIds(selectedIds.filter((item) => item !== id));
    } else {
      setSelectedIds([...selectedIds, id]);
    }
  };

  const triggerBatchAction = (action: "approved" | "rejected" | "delete") => {
    if (selectedIds.length === 0) return;
    setBatchConfirmAction({ action, ids: [...selectedIds] });
  };

  const handleConfirmBatchAction = async () => {
    if (!batchConfirmAction) return;
    await handleBatchAction(batchConfirmAction.ids, batchConfirmAction.action);
    setSelectedIds([]);
    setBatchConfirmAction(null);
  };

  // 1. Search & Basic Filter
  let filteredReports = reports.filter((r) => {
    const matchText = (r.waste_type || "").toLowerCase().includes(reportSearch.toLowerCase()) ||
                      (r.description || "").toLowerCase().includes(reportSearch.toLowerCase());
    const matchFilter = reportFilter === "all" ? true : r.status === reportFilter;
    
    // Area Search matching
    const matchArea = !areaSearch ? true : 
                      (r.profiles?.city_or_district || "").toLowerCase().includes(areaSearch.toLowerCase()) ||
                      (r.description || "").toLowerCase().includes(areaSearch.toLowerCase());

    return matchText && matchFilter && matchArea;
  });

  // 2. Advanced Sorting Logic
  filteredReports = filteredReports.sort((a, b) => {
    if (sortBy === "danger") {
      const dangerRank: Record<string, number> = { "Tinggi": 3, "Sedang": 2, "Rendah": 1 };
      const rankA = dangerRank[a.danger_level || "Sedang"] || 2;
      const rankB = dangerRank[b.danger_level || "Sedang"] || 2;
      return rankB - rankA;
    }
    if (sortBy === "lowest_ai") {
      const scoreA = a.confidence_score || 100;
      const scoreB = b.confidence_score || 100;
      return scoreA - scoreB; // Ascending: lowest confidence score first
    }
    // "newest" by default
    return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
  });

  // Get Google Maps url
  const getGoogleMapsUrl = (rep: TrashReport) => {
    let lat = -7.2504;
    let lng = 112.7508;
    if (rep.coordinates?.latitude && rep.coordinates?.longitude) {
      lat = rep.coordinates.latitude;
      lng = rep.coordinates.longitude;
    }
    return `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`;
  };

  return (
    <div className="flex flex-col gap-6 animate-fade-up h-full relative">
      
      {/* Header section with inline Search/Filters */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-navy-900">Laporan Spasial Lingkungan Warga</h1>
          <p className="text-xs text-navy-500 font-light mt-1.5">
            Kontrol absolut atas penemuan tumpukan sampah, tindakan massal, hapus rujukan spam, dan verifikasi koordinat spasial.
          </p>
        </div>

        {/* Search & Filter widgets */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Keyword Search */}
          <div className="relative">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-navy-400" />
            <input
              type="text"
              placeholder="Cari kata kunci..."
              value={reportSearch}
              onChange={(e) => setReportSearch(e.target.value)}
              className="bg-white border border-navy-100 rounded-xl pl-9 pr-4 py-2 text-xs text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-navy-50/30 transition-colors w-40 shadow-sm"
            />
          </div>

          {/* Area Search */}
          <div className="relative">
            <MapPin className="absolute left-3.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-navy-400" />
            <input
              type="text"
              placeholder="Filter wilayah..."
              value={areaSearch}
              onChange={(e) => setAreaSearch(e.target.value)}
              className="bg-white border border-navy-100 rounded-xl pl-9 pr-4 py-2 text-xs text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-navy-50/30 transition-colors w-40 shadow-sm"
            />
          </div>

          {/* Status Filter */}
          <select
            value={reportFilter}
            onChange={(e) => setReportFilter(e.target.value)}
            className="bg-white border border-navy-100 rounded-xl px-3 py-2 text-xs text-navy-700 focus:outline-none focus:border-navy-300 cursor-pointer shadow-sm font-medium"
          >
            <option value="all">Semua Status</option>
            <option value="pending_human">Pending Verifikasi</option>
            <option value="pending_ai">Klasifikasi AI</option>
            <option value="approved">Disetujui (Menunggu)</option>
            <option value="resolved">Tuntas (Resolved)</option>
            <option value="rejected">Ditolak (Rejected)</option>
          </select>

          {/* Sorter Dropdown */}
          <div className="flex items-center gap-1 bg-white border border-navy-100 rounded-xl px-2 py-1.5 shadow-sm">
            <SlidersHorizontal className="h-3 w-3 text-navy-500" />
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as any)}
              className="bg-transparent border-none text-[11px] font-bold text-navy-700 focus:outline-none cursor-pointer"
            >
              <option value="newest">Terbaru</option>
              <option value="danger">Bahaya Tertinggi</option>
              <option value="lowest_ai">Skor AI Terendah</option>
            </select>
          </div>
        </div>
      </div>

      {/* Batch Control Header Bar */}
      {filteredReports.length > 0 && (
        <div className="bg-navy-50/70 border border-navy-100/40 rounded-2xl px-4 py-2.5 flex items-center justify-between select-none">
          <button
            onClick={toggleSelectAll}
            className="flex items-center gap-2 text-xs font-bold text-navy-700 cursor-pointer hover:text-navy-900 transition-colors"
          >
            {selectedIds.length === filteredReports.length ? (
              <CheckSquare className="h-4 w-4 text-navy-900" />
            ) : (
              <Square className="h-4 w-4 text-navy-400" />
            )}
            Pilih Semua ({filteredReports.length} Laporan)
          </button>
          
          {selectedIds.length > 0 && (
            <span className="text-[10px] text-navy-500 font-bold uppercase tracking-wider">
              {selectedIds.length} Terpilih dari {filteredReports.length} daftar
            </span>
          )}
        </div>
      )}

      {/* Map + Scroll Feed */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 flex-1 min-h-[500px]">
        
        {/* Left Column: Interactive scroll feed */}
        <div className="lg:col-span-1 flex flex-col gap-4 overflow-y-auto max-h-[600px] pr-2 scrollbar-thin scrollbar-thumb-navy-100">
          {filteredReports.length === 0 ? (
            <div className="bg-white border border-navy-100 rounded-3xl p-8 text-center text-navy-400 text-xs italic shadow-sm">
              Tidak ada laporan tumpukan sampah yang cocok.
            </div>
          ) : (
            filteredReports.map((rep) => {
              const isSelected = selectedReport?.id === rep.id;
              const isChecked = selectedIds.includes(rep.id);
              return (
                <div
                  key={rep.id}
                  onClick={() => setSelectedReport(rep)}
                  className={`p-4 rounded-3xl cursor-pointer border transition-all duration-300 flex flex-col gap-3 relative ${
                    isSelected
                      ? "bg-navy-900 border-navy-900 text-white scale-[1.01] shadow-[0_8px_24px_rgba(5,12,24,0.15)]"
                      : "bg-white border-navy-100/80 hover:bg-navy-50/50 hover:border-navy-200 text-navy-900 shadow-sm"
                  }`}
                >
                  <div className="flex gap-3">
                    {/* Checkbox */}
                    <div
                      onClick={(e) => toggleSelectId(rep.id, e)}
                      className="flex items-center justify-center pt-1"
                    >
                      {isChecked ? (
                        <CheckSquare className={`h-4.5 w-4.5 shrink-0 ${isSelected ? 'text-white' : 'text-navy-900'}`} />
                      ) : (
                        <Square className={`h-4.5 w-4.5 shrink-0 ${isSelected ? 'text-white/40' : 'text-navy-300'}`} />
                      )}
                    </div>

                    <img 
                      src={rep.image_url} 
                      alt={rep.waste_type} 
                      className="h-14 w-14 rounded-xl object-cover border border-navy-100 shrink-0 shadow-sm" 
                    />
                    <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                      <div className="flex items-start justify-between gap-1">
                        <span className={`text-xs font-bold truncate leading-none ${isSelected ? 'text-white' : 'text-navy-900'}`}>
                          {rep.waste_type || "Tumpukan Sampah"}
                        </span>
                        <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded uppercase leading-none shrink-0 ${
                          rep.status === "pending_human" ? "bg-burgundy-50 text-burgundy-500 border border-burgundy-100/50" :
                          rep.status === "pending_ai" ? "bg-gold-50 text-gold border border-gold-100/50" :
                          rep.status === "approved" ? "bg-emerald-light/40 text-emerald border border-emerald-light/60" :
                          rep.status === "resolved" ? "bg-blue-50 text-blue-600 border border-blue-100" :
                          "bg-navy-50 text-navy-500 border border-navy-100"
                        }`}>
                          {rep.status.replace("_", " ")}
                        </span>
                      </div>
                      <p className={`text-[10px] leading-relaxed truncate mt-1 ${isSelected ? 'text-white/70' : 'text-navy-500'}`}>
                        {rep.description}
                      </p>
                      <div className="flex items-center justify-between mt-2 select-none">
                        <span className={`text-[9px] leading-none font-mono ${isSelected ? 'text-white/40' : 'text-navy-400'}`}>
                          {new Date(rep.created_at).toLocaleDateString("id-ID")}
                        </span>
                        
                        {rep.danger_level === "Tinggi" && (
                          <span className="flex items-center gap-0.5 text-red-600 font-extrabold text-[8px] uppercase tracking-wider bg-red-50 border border-red-100 px-1.5 py-0.5 rounded">
                            <AlertTriangle className="h-2 w-2" />
                            CRITICAL
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>

        {/* Right Column: Premium Leaflet map */}
        <div className="lg:col-span-2 flex flex-col gap-4 relative min-h-[400px] h-full rounded-3xl overflow-hidden border border-navy-100 shadow-[0_4px_24px_rgba(10,22,40,0.02)]">
          {/* Visual header overlay */}
          <div className="absolute top-4 left-4 z-[400] select-none pointer-events-none">
            <div className="bg-white/95 backdrop-blur-md rounded-xl py-2 px-3.5 border border-navy-100 shadow-md flex items-center gap-2">
              <Map className="h-4 w-4 text-emerald" />
              <span className="text-[10px] font-bold tracking-wider uppercase text-navy-900">Peta Spasial Real-Time</span>
            </div>
          </div>

          {/* Map canvas */}
          <div id="admin-gis-map" className="w-full h-full bg-navy-50 z-0" style={{ minHeight: "500px" }} />
        </div>

      </div>

      {/* FLOATING BATCH ACTION PANEL */}
      {selectedIds.length > 0 && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 bg-navy-950/95 backdrop-blur-md border border-navy-800 rounded-3xl py-3.5 px-6 shadow-2xl flex flex-col sm:flex-row items-center gap-5 z-50 animate-fade-up select-none max-w-[95%]">
          <div className="text-center sm:text-left">
            <div className="text-xs font-bold text-white">{selectedIds.length} Laporan Spasial Terpilih</div>
            <p className="text-[10px] text-navy-400 font-light mt-0.5">Terapkan tindakan massal absolut secara instan.</p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <button
              onClick={() => triggerBatchAction("approved")}
              className="bg-emerald text-white px-3.5 py-2 rounded-xl text-[11px] font-bold hover:bg-emerald-dark transition-all cursor-pointer shadow-md"
            >
              Setujui Massal
            </button>
            <button
              onClick={() => triggerBatchAction("rejected")}
              className="bg-gold text-navy-950 px-3.5 py-2 rounded-xl text-[11px] font-bold hover:bg-yellow-500 transition-all cursor-pointer shadow-md"
            >
              Tolak Massal
            </button>
            <button
              onClick={() => triggerBatchAction("delete")}
              className="bg-red-600 text-white px-3.5 py-2 rounded-xl text-[11px] font-bold hover:bg-red-700 transition-all cursor-pointer shadow-md"
            >
              Hapus Massal
            </button>
            <button
              onClick={() => setSelectedIds([])}
              className="text-[11px] font-bold text-navy-300 hover:text-white transition-all cursor-pointer"
            >
              Batal
            </button>
          </div>
        </div>
      )}

      {/* ABSOLUTE REPORT ACTION MODAL */}
      {selectedReport && (
        <div className="fixed inset-0 bg-navy-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fade-in">
          <div className="relative w-full max-w-2xl bg-white border border-navy-100 rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
            
            {/* Close */}
            <button 
              onClick={() => setSelectedReport(null)}
              className="absolute top-4 right-4 h-8 w-8 rounded-full bg-navy-50 hover:bg-navy-100 border border-navy-100 flex items-center justify-center cursor-pointer text-navy-600 hover:text-navy-900 transition-colors z-10"
            >
              <X className="h-4 w-4" />
            </button>

            <div className="overflow-y-auto p-6 md:p-8 flex flex-col gap-6">
              
              {/* Heading */}
              <div className="border-b border-navy-50 pb-4 select-none flex items-center justify-between gap-4">
                <div>
                  <span className="text-[10px] font-bold text-gold uppercase tracking-wider">Identifikasi Lapangan Absolut</span>
                  <h2 className="text-xl font-bold text-navy-900 mt-1">Laporan {selectedReport.id}</h2>
                </div>

                {/* Google Maps link & Delete permanently button */}
                <div className="flex items-center gap-2">
                  <a
                    href={getGoogleMapsUrl(selectedReport)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1.5 bg-emerald-light/30 border border-emerald-light/60 hover:bg-emerald hover:text-white hover:border-emerald px-3 py-1.5 rounded-xl text-[10px] font-bold text-emerald transition-all shadow-sm shrink-0 cursor-pointer"
                  >
                    <ExternalLink className="h-3 w-3" />
                    Buka Google Maps
                  </a>

                  <button
                    onClick={() => {
                      setDeleteConfirmId(selectedReport.id);
                    }}
                    className="flex items-center gap-1.5 border border-red-200 bg-red-50 hover:bg-red-600 hover:text-white hover:border-red-600 px-3 py-1.5 rounded-xl text-[10px] font-bold text-red-700 transition-all shadow-sm shrink-0 cursor-pointer"
                  >
                    <Trash2 className="h-3 w-3" />
                    Hapus Laporan
                  </button>
                </div>
              </div>

              {/* Photos + Details */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="relative rounded-2xl overflow-hidden border border-navy-100 aspect-video md:aspect-auto md:h-56 shadow-sm">
                  <img src={selectedReport.image_url} alt="Waste detection" className="w-full h-full object-cover" />
                  <div className="absolute bottom-3 left-3 bg-navy-900/80 px-2 py-1 rounded text-[10px] font-mono backdrop-blur-sm text-white shadow-md">
                    Skor Deteksi AI: {selectedReport.confidence_score ? `${selectedReport.confidence_score.toFixed(1)}%` : "N/A"}
                  </div>
                </div>

                <div className="flex flex-col justify-between gap-4">
                  <div className="flex flex-col gap-2.5 text-xs text-navy-700">
                    <div>
                      <span className="text-navy-400 block font-semibold text-[10px] uppercase">Pelapor</span>
                      <span className="font-bold text-navy-900 mt-0.5 block">{selectedReport.profiles?.full_name || selectedReport.profiles?.username || "Warga Anonim"}</span>
                    </div>
                    <div>
                      <span className="text-navy-400 block font-semibold text-[10px] uppercase">Kategori Sampah</span>
                      <span className="font-bold text-navy-900 mt-0.5 block">{selectedReport.waste_type || "Belum Terdeteksi"}</span>
                    </div>
                    <div>
                      <span className="text-navy-400 block font-semibold text-[10px] uppercase">Tingkat Bahaya</span>
                      <span className="font-bold text-navy-900 mt-0.5 block">{selectedReport.danger_level || "Sedang"}</span>
                    </div>
                    <div>
                      <span className="text-navy-400 block font-semibold text-[10px] uppercase">Tanggal Dikirim</span>
                      <span className="font-bold text-navy-900 mt-0.5 block">{new Date(selectedReport.created_at).toLocaleString("id-ID")}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Description text */}
              <div className="flex flex-col gap-1.5">
                <span className="text-xs text-navy-400 font-semibold uppercase tracking-wider">Deskripsi Laporan</span>
                <p className="bg-navy-50/50 border border-navy-100 rounded-2xl p-4 text-xs text-navy-800 leading-relaxed font-normal">
                  {selectedReport.description || "Tanpa rincian deskripsi."}
                </p>
              </div>

              {/* Admin comments form */}
              <div className="flex flex-col gap-2">
                <label className="text-xs text-navy-700 font-bold select-none">Catatan / Feedback Verifikasi Administrator</label>
                <textarea
                  value={adminFeedback}
                  onChange={(e) => setAdminFeedback(e.target.value)}
                  placeholder="Masukkan instruksi khusus atau catatan penolakan..."
                  rows={2}
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-2xl p-4 text-xs text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-white transition-all shadow-inner"
                />
              </div>

              {/* Actions controllers */}
              <div className="flex flex-wrap items-center justify-end gap-3 pt-4 border-t border-navy-50">
                <button
                  onClick={() => handleUpdateReportStatus(selectedReport.id, "rejected")}
                  disabled={actionLoading}
                  className="rounded-xl border border-burgundy-200 bg-burgundy-50 text-burgundy-700 px-4 py-2.5 text-xs font-semibold hover:bg-burgundy-500 hover:text-white hover:border-burgundy-500 transition-all duration-200 cursor-pointer shadow-sm"
                >
                  Tolak Laporan (Fake/Spam)
                </button>

                {selectedReport.status !== "approved" && selectedReport.status !== "resolved" && (
                  <button
                    onClick={() => handleUpdateReportStatus(selectedReport.id, "approved")}
                    disabled={actionLoading}
                    className="rounded-xl border border-emerald-light bg-emerald-light/30 text-emerald px-4 py-2.5 text-xs font-semibold hover:bg-emerald hover:text-white hover:border-emerald transition-all duration-200 cursor-pointer shadow-sm"
                  >
                    Terima & Setujui Laporan
                  </button>
                )}

                {selectedReport.status === "approved" && (
                  <button
                    onClick={() => handleUpdateReportStatus(selectedReport.id, "resolved")}
                    disabled={actionLoading}
                    className="rounded-xl border border-blue-100 bg-blue-50 text-blue-600 px-4 py-2.5 text-xs font-semibold hover:bg-blue-500 hover:text-white hover:border-blue-500 transition-all duration-200 cursor-pointer shadow-sm animate-pulse"
                  >
                    Tandai Selesai Ditangani
                  </button>
                )}
              </div>

            </div>
          </div>
        </div>
      )}

      {/* --- IN-UI CUSTOM INDIVIDUAL DELETE MODAL (Glassmorphic) --- */}
      {deleteConfirmId && (
        <div className="fixed inset-0 bg-navy-950/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className={`w-full max-w-sm ${theme === "dark" ? "bg-[#131127]/95 border-indigo-900/40 text-slate-100" : "bg-white/95 text-navy-900 border-navy-100"} border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center select-none`}>
            <div className="mx-auto h-12 w-12 rounded-2xl flex items-center justify-center bg-red-50 border border-red-100 text-red-600 animate-bounce">
              <AlertTriangle className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">Hapus Laporan Secara Permanen</h3>
              <p className="text-xs text-navy-500 font-light leading-relaxed mt-2">
                Apakah Anda yakin ingin menghapus laporan <strong className="font-bold">#{deleteConfirmId}</strong> secara permanen dari server? Tindakan ini bersifat irreversible dan tidak dapat dibatalkan!
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => setDeleteConfirmId(null)}
                className="flex-1 rounded-xl border border-navy-100 text-navy-700 hover:bg-navy-50 py-2.5 text-xs font-bold transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={async () => {
                  await handleDeleteReport(deleteConfirmId);
                  setDeleteConfirmId(null);
                  setSelectedReport(null);
                }}
                className="flex-1 rounded-xl bg-red-600 hover:bg-red-700 text-white py-2.5 text-xs font-bold transition-all cursor-pointer shadow-md"
              >
                Hapus Permanen
              </button>
            </div>
          </div>
        </div>
      )}

      {/* --- IN-UI CUSTOM BATCH ACTION MODAL (Glassmorphic) --- */}
      {batchConfirmAction && (
        <div className="fixed inset-0 bg-navy-950/40 backdrop-blur-md flex items-center justify-center p-4 z-[1000] animate-fade-in">
          <div className={`w-full max-w-sm ${theme === "dark" ? "bg-[#131127]/95 border-indigo-900/40 text-slate-100" : "bg-white/95 text-navy-900 border-navy-100"} border backdrop-blur-xl rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6 text-center select-none`}>
            <div className={`mx-auto h-12 w-12 rounded-2xl flex items-center justify-center border ${
              batchConfirmAction.action === "delete" ? "bg-red-50 border-red-100 text-red-600" : "bg-gold-50 border-gold-100 text-gold"
            } animate-pulse`}>
              <AlertTriangle className="h-5.5 w-5.5" />
            </div>

            <div>
              <h3 className="text-base font-bold leading-tight">
                {batchConfirmAction.action === "delete" ? "Hapus Massal Laporan" : "Verifikasi Massal Laporan"}
              </h3>
              <p className="text-xs text-navy-500 font-light leading-relaxed mt-2">
                {batchConfirmAction.action === "delete" 
                  ? `⚠️ PERINGATAN: Anda akan menghapus secara permanen ${batchConfirmAction.ids.length} laporan terpilih dari server. Tindakan ini tidak dapat dibatalkan!`
                  : `Apakah Anda yakin ingin memperbarui status ${batchConfirmAction.ids.length} laporan terpilih secara massal menjadi ${batchConfirmAction.action.toUpperCase()}?`}
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => setBatchConfirmAction(null)}
                className="flex-1 rounded-xl border border-navy-100 text-navy-700 hover:bg-navy-50 py-2.5 text-xs font-bold transition-all cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleConfirmBatchAction}
                className={`flex-1 rounded-xl py-2.5 text-xs font-bold transition-all cursor-pointer shadow-md text-white ${
                  batchConfirmAction.action === "delete" ? "bg-red-600 hover:bg-red-700" : "bg-navy-900 hover:bg-navy-850"
                }`}
              >
                Konfirmasi
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
