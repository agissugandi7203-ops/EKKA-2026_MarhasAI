"use client";

import React, { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import {
  ShieldCheck,
  Users,
  FileText,
  MapPin,
  Award,
  LogOut,
  RefreshCw,
  Trash2,
  Edit2,
  CheckCircle,
  XCircle,
  Clock,
  Search,
  Plus,
  Compass,
  TrendingUp,
  Activity,
  UserCheck,
  AwardIcon,
  ChevronRight,
  Info,
  Sliders,
  Sparkles,
  Map,
  X
} from "lucide-react";

// --- STRICT TYPES & INTERFACES (TypeScript Safety) ---

interface Badge {
  id: string;
  code: string;
  title: string;
  description: string;
  image_url?: string;
}

interface UserProfile {
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

interface TrashReport {
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

interface RAGDocument {
  id: string;
  title: string;
  category: string;
  charCount: number;
  createdAt: string;
}

export default function AdminDashboard() {
  const router = useRouter();

  // --- STATE SYSTEM ---
  const [adminName, setAdminName] = useState<string>("Admin");
  const [adminEmail, setAdminEmail] = useState<string>("");
  const [isLive, setIsLive] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<"overview" | "reports" | "profiles" | "rag">("overview");
  const [loading, setLoading] = useState<boolean>(true);
  const [actionLoading, setActionLoading] = useState<boolean>(false);

  // Data collections
  const [reports, setReports] = useState<TrashReport[]>([]);
  const [profiles, setProfiles] = useState<UserProfile[]>([]);
  const [badges, setBadges] = useState<Badge[]>([]);
  const [ragDocs, setRagDocs] = useState<RAGDocument[]>([]);

  // Search/Filter states
  const [reportSearch, setReportSearch] = useState<string>("");
  const [reportFilter, setReportFilter] = useState<string>("all");
  const [profileSearch, setProfileSearch] = useState<string>("");

  // Detailed selected views for Modals
  const [selectedReport, setSelectedReport] = useState<TrashReport | null>(null);
  const [selectedProfile, setSelectedReportProfile] = useState<UserProfile | null>(null);
  const [adminFeedback, setAdminFeedback] = useState<string>("");

  // Gamification adjust modal state
  const [isAdjustGamifyOpen, setIsAdjustGamifyOpen] = useState<boolean>(false);
  const [adjustXp, setAdjustXp] = useState<number>(0);
  const [adjustLevel, setAdjustLevel] = useState<number>(1);
  const [adjustStreak, setAdjustStreak] = useState<number>(0);

  // Badge award modal state
  const [isAwardBadgeOpen, setIsAwardBadgeOpen] = useState<boolean>(false);
  const [badgeToAward, setBadgeToAward] = useState<string>("");

  // RAG add modal state
  const [isAddRagOpen, setIsAwardRagOpen] = useState<boolean>(false);
  const [ragTitle, setRagTitle] = useState<string>("");
  const [ragCategory, setRagCategory] = useState<string>("Regulasi");
  const [ragContent, setRagContent] = useState<string>("");

  // Leaflet Map refs
  const mapInstanceRef = useRef<any>(null);

  // --- MOCK DATABASE FALLBACK (Resiliency Emulator) ---
  const generateMockData = () => {
    const mockProfiles: UserProfile[] = [
      {
        id: "usr-01",
        username: "agissugandi",
        full_name: "Agis Sugandi",
        province: "Jawa Timur",
        city_or_district: "Kota Surabaya",
        role: "citizen",
        xp: 4250,
        level: 12,
        current_streak: 8,
        points: 420,
        created_at: "2026-05-15T08:30:00Z",
        badges: [
          { earned_at: "2026-05-20T10:00:00Z", code: "eco_warrior", title: "Eco Warrior", description: "Melaporkan tumpukan sampah tervalidasi 5 kali." },
          { earned_at: "2026-06-01T11:30:00Z", code: "zero_waste", title: "Zero Waste Hero", description: "Menyelesaikan tantangan zero waste mingguan." }
        ]
      },
      {
        id: "usr-02",
        username: "fajar_sanjaya",
        full_name: "Fajar Sanjaya",
        province: "Jawa Timur",
        city_or_district: "Kabupaten Sidoarjo",
        role: "citizen",
        xp: 1800,
        level: 5,
        current_streak: 3,
        points: 150,
        created_at: "2026-06-02T14:20:00Z",
        badges: [
          { earned_at: "2026-06-10T12:00:00Z", code: "first_report", title: "First Action", description: "Melakukan pelaporan masalah lingkungan pertama kali." }
        ]
      },
      {
        id: "usr-03",
        username: "marhas_ai",
        full_name: "Marhas AI Assistant",
        province: "DKI Jakarta",
        city_or_district: "Kota Jakarta Pusat",
        role: "citizen",
        xp: 8900,
        level: 25,
        current_streak: 15,
        points: 980,
        created_at: "2026-04-10T09:00:00Z",
        badges: [
          { earned_at: "2026-04-15T10:00:00Z", code: "eco_warrior", title: "Eco Warrior", description: "Melaporkan tumpukan sampah tervalidasi 5 kali." },
          { earned_at: "2026-04-20T11:00:00Z", code: "zero_waste", title: "Zero Waste Hero", description: "Menyelesaikan tantangan zero waste mingguan." },
          { earned_at: "2026-05-01T09:00:00Z", code: "super_citizen", title: "Super Citizen", description: "Memiliki kontribusi aktif selama 30 hari berturut-turut." }
        ]
      }
    ];

    const mockReports: TrashReport[] = [
      {
        id: "rep-101",
        reporter_id: "usr-01",
        image_url: "https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&w=600&q=80",
        description: "Tumpukan sampah plastik di selokan air perumahan, menyumbat aliran drainase menjelang musim hujan.",
        status: "pending_human",
        waste_type: "Plastik & Botol",
        danger_level: "Sedang",
        confidence_score: 94.2,
        created_at: "2026-06-27T10:45:00Z",
        profiles: {
          username: "agissugandi",
          full_name: "Agis Sugandi"
        },
        coordinates: {
          latitude: -7.2604,
          longitude: 112.7608
        }
      },
      {
        id: "rep-102",
        reporter_id: "usr-02",
        image_url: "https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=600&q=80",
        description: "Pembuangan limbah sisa bahan kimia industri rumahan ilegal di pinggiran sungai, menimbulkan bau menyengat.",
        status: "pending_ai",
        waste_type: "B3 (Bahan Berbahaya)",
        danger_level: "Tinggi",
        confidence_score: 88.7,
        created_at: "2026-06-28T09:15:00Z",
        profiles: {
          username: "fajar_sanjaya",
          full_name: "Fajar Sanjaya"
        },
        coordinates: {
          latitude: -7.3405,
          longitude: 112.7212
        }
      },
      {
        id: "rep-103",
        reporter_id: "usr-01",
        image_url: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80",
        description: "Sampah daun kering dan kayu lapuk menumpuk di taman kota. Menghalangi pedestrian.",
        status: "approved",
        waste_type: "Organik & Kayu",
        danger_level: "Rendah",
        confidence_score: 98.1,
        created_at: "2026-06-26T14:00:00Z",
        profiles: {
          username: "agissugandi",
          full_name: "Agis Sugandi"
        },
        coordinates: {
          latitude: -7.2482,
          longitude: 112.7535
        }
      },
      {
        id: "rep-104",
        reporter_id: "usr-03",
        image_url: "https://images.unsplash.com/photo-1504439268584-b72c5019471e?auto=format&fit=crop&w=600&q=80",
        description: "Tumpukan sisa beton bangunan liar runtuh di trotoar jalan utama Sukolilo.",
        status: "resolved",
        waste_type: "Anorganik (Konstruksi)",
        danger_level: "Sedang",
        confidence_score: 91.5,
        created_at: "2026-06-25T11:00:00Z",
        profiles: {
          username: "marhas_ai",
          full_name: "Marhas AI Assistant"
        },
        coordinates: {
          latitude: -7.2891,
          longitude: 112.7942
        }
      }
    ];

    const mockBadges: Badge[] = [
      { id: "bdg-1", code: "first_report", title: "First Action", description: "Melakukan pelaporan sampah tervalidasi pertama kali." },
      { id: "bdg-2", code: "eco_warrior", title: "Eco Warrior", description: "Melakukan pelaporan sampah sukses sebanyak 5 kali." },
      { id: "bdg-3", code: "zero_waste", title: "Zero Waste Hero", description: "Menyelesaikan tantangan zero waste mingguan." },
      { id: "bdg-4", code: "super_citizen", title: "Super Citizen", description: "Memiliki kontribusi aktif selama 30 hari berturut-turut." },
      { id: "bdg-5", code: "green_pioneer", title: "Green Pioneer", description: "Melaporkan penemuan pembuangan limbah berbahaya (B3)." }
    ];

    const mockRagDocs: RAGDocument[] = [
      { id: "rag-01", title: "UU Nomor 18 Tahun 2008 tentang Pengelolaan Sampah", category: "Undang-Undang", charCount: 42500, createdAt: "2026-05-10" },
      { id: "rag-02", title: "Perda Kota Surabaya No 5 Tahun 2014 Pengolahan Sampah", category: "Peraturan Daerah", charCount: 28900, createdAt: "2026-05-18" },
      { id: "rag-03", title: "Panduan Penanganan Limbah B3 Rumah Tangga", category: "Standard Operating Procedure", charCount: 15400, createdAt: "2026-06-02" }
    ];

    return { mockProfiles, mockReports, mockBadges, mockRagDocs };
  };

  // --- SECURITY SESSION VALIDATION ---
  useEffect(() => {
    if (typeof window === "undefined") return;

    const token = localStorage.getItem("genesis_admin_token");
    const role = localStorage.getItem("genesis_admin_role");
    
    if (!token || role !== "admin") {
      router.push("/admin/login");
      return;
    }

    const email = localStorage.getItem("genesis_admin_email") || "";
    const name = localStorage.getItem("genesis_admin_name") || "Admin";
    const mode = localStorage.getItem("genesis_admin_mode") || "simulator";

    setAdminEmail(email);
    setAdminName(name);
    setIsLive(mode === "live");

    fetchData(mode === "live", token);
  }, []);

  // --- FETCH DATA CONTROLLER ---
  const fetchData = async (liveMode: boolean, token: string) => {
    setLoading(true);
    const { mockProfiles, mockReports, mockBadges, mockRagDocs } = generateMockData();

    if (!liveMode) {
      // Offline/Simulator Emulator Mode - Fetch local state
      const savedProfiles = localStorage.getItem("emu_profiles");
      const savedReports = localStorage.getItem("emu_reports");
      const savedRag = localStorage.getItem("emu_rag_docs");

      if (savedProfiles) setProfiles(JSON.parse(savedProfiles));
      else {
        setProfiles(mockProfiles);
        localStorage.setItem("emu_profiles", JSON.stringify(mockProfiles));
      }

      if (savedReports) setReports(JSON.parse(savedReports));
      else {
        setReports(mockReports);
        localStorage.setItem("emu_reports", JSON.stringify(mockReports));
      }

      setBadges(mockBadges);

      if (savedRag) setRagDocs(JSON.parse(savedRag));
      else {
        setRagDocs(mockRagDocs);
        localStorage.setItem("emu_rag_docs", JSON.stringify(mockRagDocs));
      }

      setLoading(false);
      return;
    }

    // Live Mode API Integration
    try {
      const backendUrl = "https://genesisHub.my.id";

      // 1. Fetch Profiles
      const profilesRes = await fetch(`${backendUrl}/profiles`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const profilesData = profilesRes.ok ? await profilesRes.json() : mockProfiles;

      // 2. Fetch Reports
      const reportsRes = await fetch(`${backendUrl}/reports`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const reportsData = reportsRes.ok ? await reportsRes.json() : mockReports;

      // 3. Fetch Badges
      const badgesRes = await fetch(`${backendUrl}/badges`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const badgesData = badgesRes.ok ? await badgesRes.json() : mockBadges;

      setProfiles(Array.isArray(profilesData) ? profilesData : mockProfiles);
      setReports(Array.isArray(reportsData) ? reportsData : mockReports);
      setBadges(Array.isArray(badgesData) ? badgesData : mockBadges);
      setRagDocs(mockRagDocs); // RAG local mockup as base

    } catch (err) {
      console.error("Failed to load live data, falling back to simulator:", err);
      setIsLive(false);
      setProfiles(mockProfiles);
      setReports(mockReports);
      setBadges(mockBadges);
      setRagDocs(mockRagDocs);
    } finally {
      setLoading(false);
    }
  };

  // --- INTERACTIVE MAP INITIALIZATION ---
  useEffect(() => {
    // We only mount the map if Leaflet is loaded and we are on Reports tab
    if (activeTab !== "reports" || loading) return;

    let isMounted = true;
    
    const initLeafletMap = async () => {
      // Load CSS
      if (!document.getElementById("leaflet-css")) {
        const link = document.createElement("link");
        link.id = "leaflet-css";
        link.rel = "stylesheet";
        link.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css";
        document.head.appendChild(link);
      }

      // Load JS
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

      // Clean up previous map
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }

      const mapContainer = document.getElementById("admin-gis-map");
      if (!mapContainer) return;

      // Setup map centered around East Java/Surabaya centroid
      const map = L.map("admin-gis-map", {
        zoomControl: false
      }).setView([-7.2504, 112.7508], 11);
      
      mapInstanceRef.current = map;

      L.control.zoom({
        position: "bottomright"
      }).addTo(map);

      // Add CartoDB Dark Matter tile layer for an extremely premium dark theme
      L.tileLayer("https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png", {
        attribution: '&copy; OpenStreetMap &copy; CartoDB',
        subdomains: "abcd",
        maxZoom: 20
      }).addTo(map);

      // Register map interaction endpoint globally so leaflet popups can hook react components
      (window as any).openReportFromMap = (id: string) => {
        const rep = reports.find(r => r.id === id);
        if (rep) setSelectedReport(rep);
      };

      // Add report location markers dynamically
      reports.forEach((rep) => {
        // Parse coordinates from PostGIS POINT or local coordinates keys
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
        } else if ((rep as any).lat && (rep as any).lng) {
          lat = (rep as any).lat;
          lng = (rep as any).lng;
        }

        // Color coding based on status
        const statusColors: Record<string, string> = {
          pending_ai: "#f5e6c8", // Pale Gold
          pending_human: "#c8922a", // Gold
          approved: "#1b7a4e", // Emerald
          resolved: "#2148a0", // Blue
          rejected: "#a3324b" // Burgundy/Red
        };

        const color = statusColors[rep.status] || "#ffffff";

        // Glassmorphic pulsing marker icon
        const markerIcon = L.divIcon({
          className: "custom-map-pin",
          html: `
            <div className="relative flex items-center justify-center">
              <div style="background-color: ${color}20; width: 34px; height: 34px; border-radius: 50%; display: flex; items-center; justify-center;" class="animate-ping absolute pointer-events-none"></div>
              <div style="background-color: ${color}; width: 14px; height: 14px; border-radius: 50%; border: 2.5px solid #050c18; box-shadow: 0 0 15px ${color}; cursor: pointer;"></div>
            </div>
          `,
          iconSize: [34, 34],
          iconAnchor: [17, 17]
        });

        const marker = L.marker([lat, lng], { icon: markerIcon }).addTo(map);

        const reporterName = rep.profiles?.full_name || rep.profiles?.username || "Warga Anonim";
        const contentString = `
          <div style="color: #ffffff; background-color: #0a1628; font-family: inherit; font-size: 11px; padding: 4px; border-radius: 8px; width: 170px;">
            <div style="font-weight: bold; font-size: 12px; margin-bottom: 3px; color: ${color};">${rep.waste_type || "Tumpukan Sampah"}</div>
            <div style="color: rgba(255, 255, 255, 0.6); margin-bottom: 6px;">Oleh: ${reporterName}</div>
            <div style="max-height: 35px; overflow: hidden; text-overflow: ellipsis; margin-bottom: 8px; color: rgba(255, 255, 255, 0.85);">${rep.description || "Tanpa rincian deskripsi."}</div>
            <button onclick="window.openReportFromMap('${rep.id}')" style="background-color: ${color}; color: ${rep.status === 'pending_ai' ? '#0a1628' : '#ffffff'}; border: none; padding: 4.5px 8px; border-radius: 6px; font-weight: bold; width: 100%; cursor: pointer; transition: transform 0.1s;">
              Pemeriksaan Absolut
            </button>
          </div>
        `;

        marker.bindPopup(contentString, {
          className: "glassmorphic-popup",
          closeButton: false,
          minWidth: 180
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
  }, [activeTab, reports, loading]);

  // --- HANDLERS: LOGOUT ---
  const handleLogout = () => {
    localStorage.removeItem("genesis_admin_token");
    localStorage.removeItem("genesis_admin_email");
    localStorage.removeItem("genesis_admin_name");
    localStorage.removeItem("genesis_admin_role");
    router.push("/admin/login");
  };

  // --- HANDLERS: REPORT ABSOLUTE CONTROL (Approve, Resolve, Reject) ---
  const handleUpdateReportStatus = async (id: string, nextStatus: "approved" | "resolved" | "rejected") => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local Simulation Actions
      const updated = reports.map((r) => {
        if (r.id === id) {
          return { ...r, status: nextStatus, description: r.description + (adminFeedback ? `\n\n[Feedback Admin]: ${adminFeedback}` : "") };
        }
        return r;
      });
      setReports(updated);
      localStorage.setItem("emu_reports", JSON.stringify(updated));

      // Award automatic mock XP points to user if approved
      if (nextStatus === "approved" || nextStatus === "resolved") {
        const matchingReport = reports.find(r => r.id === id);
        if (matchingReport) {
          const updatedProfiles = profiles.map((p) => {
            if (p.id === matchingReport.reporter_id) {
              return { ...p, xp: p.xp + 150, points: (p.points || 0) + 15 };
            }
            return p;
          });
          setProfiles(updatedProfiles);
          localStorage.setItem("emu_profiles", JSON.stringify(updatedProfiles));
        }
      }

      setSelectedReport(null);
      setAdminFeedback("");
      setActionLoading(false);
      return;
    }

    // Live API Call
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/reports/${id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          status: nextStatus,
          admin_notes: adminFeedback || "Laporan diverifikasi oleh Administrator."
        })
      });

      if (res.ok) {
        // Reload State
        fetchData(true, token || "");
        setSelectedReport(null);
        setAdminFeedback("");
      } else {
        alert("Gagal memperbarui status laporan ke backend.");
      }
    } catch (err) {
      console.error("Live status update error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: PROFILE REWARDS (XP, Level, Streak Correction) ---
  const handleAdjustGamification = async () => {
    if (!selectedProfile) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local simulation
      const updated = profiles.map((p) => {
        if (p.id === selectedProfile.id) {
          return { ...p, xp: adjustXp, level: adjustLevel, current_streak: adjustStreak };
        }
        return p;
      });
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      setIsAdjustGamifyOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API Call
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/profiles/${selectedProfile.id}/gamification`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          xp: adjustXp,
          level: adjustLevel,
          current_streak: adjustStreak
        })
      });

      if (res.ok) {
        fetchData(true, token || "");
        setIsAdjustGamifyOpen(false);
      } else {
        alert("Gagal melakukan penyesuaian gamifikasi ke server.");
      }
    } catch (err) {
      console.error("Live gamify adjust error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: AWARD BADGE TO USER ---
  const handleAwardBadge = async () => {
    if (!selectedProfile || !badgeToAward) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const badgeObj = badges.find(b => b.code === badgeToAward);

    if (!isLive) {
      // Local simulation
      const updated = profiles.map((p) => {
        if (p.id === selectedProfile.id) {
          const currentBadges = p.badges || [];
          if (currentBadges.some(b => b.code === badgeToAward)) return p; // Already has it
          return {
            ...p,
            badges: [
              ...currentBadges,
              {
                earned_at: new Date().toISOString(),
                code: badgeToAward,
                title: badgeObj?.title || badgeToAward,
                description: badgeObj?.description || ""
              }
            ]
          };
        }
        return p;
      });
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      setIsAwardBadgeOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API call
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/badges/award`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          userId: selectedProfile.id,
          badgeCode: badgeToAward
        })
      });

      if (res.ok) {
        fetchData(true, token || "");
        setIsAwardBadgeOpen(false);
      } else {
        alert("Gagal menyematkan lencana ke profil warga.");
      }
    } catch (err) {
      console.error("Live badge award error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: REVOKE BADGE FROM USER ---
  const handleRevokeBadge = async (profileId: string, badgeCode: string) => {
    if (!confirm("Apakah Anda yakin ingin mencabut lencana ini dari profil warga?")) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local simulation
      const updated = profiles.map((p) => {
        if (p.id === profileId) {
          return {
            ...p,
            badges: (p.badges || []).filter(b => b.code !== badgeCode)
          };
        }
        return p;
      });
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      setActionLoading(false);
      return;
    }

    // Live API call
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/badges/revoke`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          userId: profileId,
          badgeCode
        })
      });

      if (res.ok) {
        fetchData(true, token || "");
      } else {
        alert("Gagal mencabut lencana dari profil.");
      }
    } catch (err) {
      console.error("Live badge revoke error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: DELETE USER PROFILE ABSOLUTE ---
  const handleDeleteUserProfile = async (profileId: string) => {
    if (!confirm("⚠️ PERINGATAN: Aksi ini bersifat absolut dan permanen. Menghapus profil pengguna akan melenyapkan seluruh riwayat akun dan data auth. Anda yakin?")) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local simulation
      const updated = profiles.filter(p => p.id !== profileId);
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      setActionLoading(false);
      return;
    }

    // Live API call
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/profiles/${profileId}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });

      if (res.ok) {
        fetchData(true, token || "");
      } else {
        const errData = await res.json();
        alert(`Gagal menghapus user: ${errData.message || "Akses Ditolak."}`);
      }
    } catch (err: any) {
      console.error("Live delete profile error:", err);
      alert("Error: " + err.message);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: ADD NEW RAG DOCUMENT ---
  const handleAddRagDoc = () => {
    if (!ragTitle || !ragContent) return;
    const newDoc: RAGDocument = {
      id: `rag-0${ragDocs.length + 1}`,
      title: ragTitle,
      category: ragCategory,
      charCount: ragContent.length,
      createdAt: new Date().toISOString().split("T")[0]
    };

    const updated = [newDoc, ...ragDocs];
    setRagDocs(updated);
    localStorage.setItem("emu_rag_docs", JSON.stringify(updated));

    setRagTitle("");
    setRagContent("");
    setIsAwardRagOpen(false);
  };

  // --- CALCULATE SUMMARY COUNTERS ---
  const pendingHumanCount = reports.filter(r => r.status === "pending_human").length;
  const pendingAiCount = reports.filter(r => r.status === "pending_ai").length;
  const approvedCount = reports.filter(r => r.status === "approved").length;
  const resolvedCount = reports.filter(r => r.status === "resolved").length;

  // Render Loader screen
  if (loading) {
    return (
      <div className="min-h-screen w-full bg-navy-950 flex flex-col justify-center items-center gap-4 text-white">
        <div className="h-10 w-10 rounded-full border-2 border-white border-t-transparent animate-spin" />
        <span className="text-xs font-mono text-white/50 tracking-wider">MENGOTORISASI PORTAL KONTROL ABSOLUT...</span>
      </div>
    );
  }

  return (
    <main className="min-h-screen w-full bg-navy-950 text-white flex flex-col md:flex-row overflow-hidden relative font-sans">
      
      {/* Decorative ambient lighting */}
      <div className="absolute top-0 right-0 h-[400px] w-[400px] rounded-full bg-burgundy-900/10 blur-[150px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 h-[400px] w-[400px] rounded-full bg-navy-500/10 blur-[150px] pointer-events-none" />

      {/* --- SIDEBAR PANEL (Liquid Glass) --- */}
      <aside className="w-full md:w-64 shrink-0 border-r border-white/5 bg-navy-900/40 backdrop-blur-xl flex flex-col justify-between p-6 z-20">
        <div className="flex flex-col gap-8">
          
          {/* Brand Logo & Info */}
          <div className="flex items-center gap-3 select-none">
            <div className="h-10 w-10 rounded-xl bg-white/10 flex items-center justify-center border border-white/10 shadow-inner">
              <ShieldCheck className="h-5.5 w-5.5 text-white" />
            </div>
            <div className="flex flex-col">
              <span className="text-base font-normal tracking-tight text-white leading-none">Genesis.id</span>
              <span className="text-[10px] uppercase font-semibold text-gold tracking-wider mt-0.5 leading-none">Otoritas Admin</span>
            </div>
          </div>

          {/* Admin Profile Widget */}
          <div className="liquid-glass rounded-2xl p-4 border border-white/5 bg-white/2 select-none flex items-center gap-3">
            <div className="relative">
              <div className="h-10 w-10 rounded-full bg-white/10 flex items-center justify-center font-bold text-white border border-white/20">
                {adminName.charAt(0).toUpperCase()}
              </div>
              <div className="absolute bottom-0 right-0 h-3 w-3 rounded-full bg-emerald border-2 border-navy-950 flex items-center justify-center">
                <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />
              </div>
            </div>
            <div className="flex flex-col min-w-0">
              <span className="text-xs font-semibold truncate leading-tight">{adminName}</span>
              <span className="text-[10px] text-white/50 truncate leading-none mt-1">{adminEmail}</span>
            </div>
          </div>

          {/* Tab Navigation links */}
          <nav className="flex flex-col gap-1.5">
            <button
              onClick={() => setActiveTab("overview")}
              className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-300 ${
                activeTab === "overview"
                  ? "bg-white text-navy-950 shadow-md font-bold scale-[1.02]"
                  : "text-white/60 hover:text-white hover:bg-white/5"
              }`}
            >
              <Activity className="h-4 w-4 shrink-0" />
              Dasbor Ringkasan
            </button>
            <button
              onClick={() => setActiveTab("reports")}
              className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-300 ${
                activeTab === "reports"
                  ? "bg-white text-navy-950 shadow-md font-bold scale-[1.02]"
                  : "text-white/60 hover:text-white hover:bg-white/5"
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
              className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-300 ${
                activeTab === "profiles"
                  ? "bg-white text-navy-950 shadow-md font-bold scale-[1.02]"
                  : "text-white/60 hover:text-white hover:bg-white/5"
              }`}
            >
              <Users className="h-4 w-4 shrink-0" />
              Kontrol Warga
            </button>
            <button
              onClick={() => setActiveTab("rag")}
              className={`flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl transition-all duration-300 ${
                activeTab === "rag"
                  ? "bg-white text-navy-950 shadow-md font-bold scale-[1.02]"
                  : "text-white/60 hover:text-white hover:bg-white/5"
              }`}
            >
              <FileText className="h-4 w-4 shrink-0" />
              Basis Pengetahuan AI
            </button>
          </nav>
        </div>

        {/* Footer actions inside Sidebar */}
        <div className="flex flex-col gap-4 mt-8">
          {/* Mode status indicator */}
          <div className="flex items-center gap-1.5 px-2">
            <span className={`h-2 w-2 rounded-full ${isLive ? "bg-emerald" : "bg-gold"} animate-pulse`} />
            <span className="text-[10px] text-white/50 select-none">
              Mode: <strong className="text-white">{isLive ? "Live NestJS API" : "Simulasi Emulator"}</strong>
            </span>
          </div>

          <button
            onClick={handleLogout}
            className="flex items-center gap-3 text-xs font-semibold px-4 py-3 rounded-xl border border-white/5 text-white/60 hover:text-white hover:bg-burgundy-900/20 hover:border-burgundy-500/20 transition-all duration-300 cursor-pointer"
          >
            <LogOut className="h-4 w-4 text-burgundy-300" />
            Logout Otoritas
          </button>
        </div>
      </aside>

      {/* --- MAIN MAIN AREA CONTENT --- */}
      <div className="flex-1 flex flex-col overflow-y-auto max-h-screen z-10 p-6 md:p-8">
        
        {/* TAB 1: DASBOR OVERVIEW */}
        {activeTab === "overview" && (
          <div className="flex flex-col gap-8 animate-fade-up">
            
            {/* Header section */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div>
                <h1 className="text-3xl font-light tracking-tight">Selamat Datang kembali, Administrator.</h1>
                <p className="text-xs text-white/50 font-light mt-1">
                  Semua sistem vital beroperasi lancar. Berikut laporan status aktivitas tumpukan sampah terpadu Genesis.id.
                </p>
              </div>
              
              <button 
                onClick={() => fetchData(isLive, localStorage.getItem("genesis_admin_token") || "")}
                className="flex items-center gap-2 self-start bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-xs font-semibold text-white/80 hover:text-white hover:bg-white/10 transition-colors"
              >
                <RefreshCw className="h-3.5 w-3.5" />
                Segarkan Portal
              </button>
            </div>

            {/* KPI Cards Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              
              <div className="liquid-glass rounded-2xl p-5 border border-white/5 bg-white/2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white/50 uppercase">Menunggu Validasi Manusia</span>
                  <div className="h-8 w-8 rounded-lg bg-burgundy-500/10 flex items-center justify-center text-burgundy-300">
                    <Clock className="h-4 w-4" />
                  </div>
                </div>
                <div className="text-3xl font-bold mt-4">{pendingHumanCount}</div>
                <div className="text-[10px] text-white/40 mt-1">Laporan dari warga terklasifikasi AI tumpukan sampah</div>
              </div>

              <div className="liquid-glass rounded-2xl p-5 border border-white/5 bg-white/2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white/50 uppercase">Menunggu Analisis AI</span>
                  <div className="h-8 w-8 rounded-lg bg-gold/10 flex items-center justify-center text-gold">
                    <Sparkles className="h-4 w-4" />
                  </div>
                </div>
                <div className="text-3xl font-bold mt-4">{pendingAiCount}</div>
                <div className="text-[10px] text-white/40 mt-1">Antrean background task Vision-AI Classifier</div>
              </div>

              <div className="liquid-glass rounded-2xl p-5 border border-white/5 bg-white/2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white/50 uppercase">Laporan Aktif</span>
                  <div className="h-8 w-8 rounded-lg bg-emerald/10 flex items-center justify-center text-emerald">
                    <CheckCircle className="h-4 w-4" />
                  </div>
                </div>
                <div className="text-3xl font-bold mt-4">{approvedCount}</div>
                <div className="text-[10px] text-white/40 mt-1">Telah disetujui & siap ditangani petugas kebersihan</div>
              </div>

              <div className="liquid-glass rounded-2xl p-5 border border-white/5 bg-white/2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-white/50 uppercase">Selesai Ditangani</span>
                  <div className="h-8 w-8 rounded-lg bg-blue-500/10 flex items-center justify-center text-blue-400">
                    <UserCheck className="h-4 w-4" />
                  </div>
                </div>
                <div className="text-3xl font-bold mt-4">{resolvedCount}</div>
                <div className="text-[10px] text-white/40 mt-1">Tumpukan sampah telah dieksekusi tuntas di lapangan</div>
              </div>

            </div>

            {/* Core Features Overview: Split Columns */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              
              {/* Quick report activity */}
              <div className="liquid-glass rounded-3xl p-6 border border-white/10 flex flex-col gap-4">
                <div className="flex items-center justify-between border-b border-white/5 pb-4">
                  <h2 className="text-lg font-normal text-white">Laporan Spasial Terkini</h2>
                  <button onClick={() => setActiveTab("reports")} className="text-xs text-white/60 hover:text-white flex items-center gap-1">
                    Lihat Semua
                    <ChevronRight className="h-3 w-3" />
                  </button>
                </div>

                <div className="flex flex-col gap-4">
                  {reports.slice(0, 3).map((rep) => (
                    <div 
                      key={rep.id} 
                      onClick={() => { setSelectedReport(rep); setActiveTab("reports"); }}
                      className="group flex gap-4 p-3 rounded-2xl bg-white/2 border border-white/5 hover:bg-white/5 hover:border-white/10 transition-all duration-300 cursor-pointer"
                    >
                      <img src={rep.image_url} alt={rep.waste_type} className="h-14 w-14 rounded-xl object-cover border border-white/10 shrink-0" />
                      <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                        <div className="flex items-center justify-between gap-2">
                          <span className="text-xs font-bold text-white truncate">{rep.waste_type || "Tumpukan Sampah"}</span>
                          <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full uppercase shrink-0 ${
                            rep.status === "pending_human" ? "bg-burgundy-500/10 text-burgundy-300 border border-burgundy-500/20" :
                            rep.status === "pending_ai" ? "bg-gold/10 text-gold border border-gold/20" :
                            rep.status === "approved" ? "bg-emerald/10 text-emerald border border-emerald/20" :
                            "bg-white/10 text-white/60"
                          }`}>
                            {rep.status}
                          </span>
                        </div>
                        <p className="text-[11px] text-white/60 truncate mt-1">{rep.description}</p>
                        <span className="text-[10px] text-white/40 mt-1">{new Date(rep.created_at).toLocaleString("id-ID")}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Quick users list */}
              <div className="liquid-glass rounded-3xl p-6 border border-white/10 flex flex-col gap-4">
                <div className="flex items-center justify-between border-b border-white/5 pb-4">
                  <h2 className="text-lg font-normal text-white">Warga dengan XP Tertinggi</h2>
                  <button onClick={() => setActiveTab("profiles")} className="text-xs text-white/60 hover:text-white flex items-center gap-1">
                    Lihat Semua
                    <ChevronRight className="h-3 w-3" />
                  </button>
                </div>

                <div className="flex flex-col gap-4">
                  {profiles.slice().sort((a,b) => b.xp - a.xp).slice(0, 3).map((prof) => (
                    <div 
                      key={prof.id}
                      onClick={() => { setSelectedReportProfile(prof); setActiveTab("profiles"); }}
                      className="flex items-center justify-between p-3 rounded-2xl bg-white/2 border border-white/5 hover:bg-white/5 transition-all duration-300 cursor-pointer"
                    >
                      <div className="flex items-center gap-3">
                        <div className="h-9 w-9 rounded-full bg-white/10 flex items-center justify-center font-bold text-white border border-white/10 shrink-0">
                          {prof.username.charAt(0).toUpperCase()}
                        </div>
                        <div className="flex flex-col">
                          <span className="text-xs font-semibold">{prof.full_name || prof.username}</span>
                          <span className="text-[10px] text-white/40">{prof.city_or_district}</span>
                        </div>
                      </div>

                      <div className="flex items-center gap-5 text-right">
                        <div className="flex flex-col">
                          <span className="text-xs font-bold text-white leading-none">{prof.xp} XP</span>
                          <span className="text-[9px] text-gold mt-1 leading-none">Level {prof.level}</span>
                        </div>
                        <div className="flex items-center gap-1 text-emerald-light/60 bg-emerald/10 px-2 py-1 rounded-lg border border-emerald/10 shrink-0 select-none">
                          <span className="text-[10px] font-bold">🔥 {prof.current_streak} Hari</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

            </div>

          </div>
        )}

        {/* TAB 2: REPORTS MANAGEMENT (GIS MAP + LIST) */}
        {activeTab === "reports" && (
          <div className="flex flex-col gap-6 animate-fade-up h-full">
            
            {/* Header section with inline Search/Filters */}
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
              <div>
                <h1 className="text-2xl font-light">Laporan Spasial Lingkungan Warga</h1>
                <p className="text-xs text-white/50 font-light mt-1">
                  Kontrol absolut atas penemuan tumpukan sampah, tunda/tolak laporan palsu, dan verifikasi koordinat spasial.
                </p>
              </div>

              {/* Filters */}
              <div className="flex flex-wrap items-center gap-3">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-white/40" />
                  <input
                    type="text"
                    placeholder="Cari tumpukan..."
                    value={reportSearch}
                    onChange={(e) => setReportSearch(e.target.value)}
                    className="bg-white/5 border border-white/10 rounded-xl pl-9 pr-4 py-1.5 text-xs text-white placeholder-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-colors w-44"
                  />
                </div>

                <select
                  value={reportFilter}
                  onChange={(e) => setReportFilter(e.target.value)}
                  className="bg-navy-900 border border-white/10 rounded-xl px-3 py-1.5 text-xs text-white/80 focus:outline-none focus:border-white/30 cursor-pointer"
                >
                  <option value="all">Semua Status</option>
                  <option value="pending_human">Pending Verifikasi Manusia</option>
                  <option value="pending_ai">Pending Klasifikasi AI</option>
                  <option value="approved">Approved (Menunggu Eksekusi)</option>
                  <option value="resolved">Resolved (Tuntas)</option>
                  <option value="rejected">Rejected (Ditolak)</option>
                </select>
              </div>
            </div>

            {/* Split layout: GIS Map (Top/Right) and List (Bottom/Left) */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 flex-1 min-h-[500px]">
              
              {/* Left Column: Interactive Reports List */}
              <div className="lg:col-span-1 flex flex-col gap-4 overflow-y-auto max-h-[600px] pr-2">
                
                {reports
                  .filter((r) => {
                    const matchText = (r.waste_type || "").toLowerCase().includes(reportSearch.toLowerCase()) ||
                                      (r.description || "").toLowerCase().includes(reportSearch.toLowerCase());
                    const matchFilter = reportFilter === "all" ? true : r.status === reportFilter;
                    return matchText && matchFilter;
                  })
                  .map((rep) => {
                    const isSelected = selectedReport?.id === rep.id;
                    return (
                      <div
                        key={rep.id}
                        onClick={() => setSelectedReport(rep)}
                        className={`p-4 rounded-2xl cursor-pointer border transition-all duration-300 flex flex-col gap-3 ${
                          isSelected
                            ? "bg-white/10 border-white/30 scale-[1.01] shadow-lg shadow-black/20"
                            : "bg-white/2 border-white/5 hover:bg-white/5 hover:border-white/10"
                        }`}
                      >
                        <div className="flex gap-3">
                          <img src={rep.image_url} alt={rep.waste_type} className="h-14 w-14 rounded-xl object-cover border border-white/10 shrink-0" />
                          <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div className="flex items-start justify-between gap-1">
                              <span className="text-xs font-bold text-white truncate leading-none">{rep.waste_type || "Tumpukan Sampah"}</span>
                              <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded uppercase leading-none shrink-0 ${
                                rep.status === "pending_human" ? "bg-burgundy-500/20 text-burgundy-300 border border-burgundy-500/20" :
                                rep.status === "pending_ai" ? "bg-gold/20 text-gold border border-gold/20" :
                                rep.status === "approved" ? "bg-emerald/20 text-emerald border border-emerald/20" :
                                rep.status === "resolved" ? "bg-blue-500/20 text-blue-300 border border-blue-500/20" :
                                "bg-white/10 text-white/50"
                              }`}>
                                {rep.status.replace("_", " ")}
                              </span>
                            </div>
                            <p className="text-[10px] text-white/50 leading-tight truncate mt-1">{rep.description}</p>
                            <span className="text-[9px] text-white/30 leading-none mt-2">
                              {new Date(rep.created_at).toLocaleDateString("id-ID")}
                            </span>
                          </div>
                        </div>
                      </div>
                    );
                  })}
              </div>

              {/* Right Column: Premium GIS Map Container */}
              <div className="lg:col-span-2 flex flex-col gap-4 relative min-h-[400px] h-full rounded-3xl overflow-hidden border border-white/10 shadow-2xl">
                {/* Visual Glassmorphic header overlay on Map */}
                <div className="absolute top-4 left-4 z-10 select-none pointer-events-none">
                  <div className="liquid-glass backdrop-blur-md rounded-xl py-2 px-3.5 border border-white/10 shadow-lg flex items-center gap-2">
                    <Map className="h-4 w-4 text-emerald" />
                    <span className="text-[10px] font-semibold tracking-wider uppercase text-white/95">Peta Spasial Real-Time</span>
                  </div>
                </div>

                {/* Leaflet Mount Node */}
                <div id="admin-gis-map" className="w-full h-full bg-navy-950 z-0" style={{ minHeight: "500px" }} />
              </div>

            </div>

            {/* EXPANDED MODAL DETAIL LAPORAN: PEMERIKSAAN ABSOLUT */}
            {selectedReport && (
              <div className="fixed inset-0 bg-black/70 backdrop-blur-md flex items-center justify-center p-4 z-50 animate-fade-in">
                <div className="relative w-full max-w-2xl bg-navy-900/95 border border-white/10 rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
                  
                  {/* Close button */}
                  <button 
                    onClick={() => setSelectedReport(null)}
                    className="absolute top-4 right-4 h-8 w-8 rounded-full bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center cursor-pointer text-white/70 hover:text-white transition-colors z-10"
                  >
                    <X className="h-4 w-4" />
                  </button>

                  <div className="overflow-y-auto p-6 md:p-8 flex flex-col gap-6">
                    
                    {/* Header */}
                    <div className="border-b border-white/5 pb-4 select-none">
                      <span className="text-[10px] font-bold text-gold uppercase tracking-wider">Identifikasi Lapangan Absolut</span>
                      <h2 className="text-xl font-normal text-white mt-1">Laporan {selectedReport.id}</h2>
                    </div>

                    {/* Image and basic info */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="relative rounded-2xl overflow-hidden border border-white/10 aspect-video md:aspect-auto md:h-56">
                        <img src={selectedReport.image_url} alt={selectedReport.waste_type} className="w-full h-full object-cover" />
                        <div className="absolute bottom-3 left-3 bg-black/50 px-2 py-1 rounded text-[10px] font-mono backdrop-blur-sm">
                          Skor Deteksi AI: {selectedReport.confidence_score ? `${selectedReport.confidence_score.toFixed(1)}%` : "N/A"}
                        </div>
                      </div>

                      <div className="flex flex-col justify-between gap-4">
                        <div className="flex flex-col gap-2.5 text-xs">
                          <div>
                            <span className="text-white/50 block font-light">Pelapor</span>
                            <span className="font-semibold text-white mt-0.5 block">{selectedReport.profiles?.full_name || selectedReport.profiles?.username || "Warga Anonim"}</span>
                          </div>
                          <div>
                            <span className="text-white/50 block font-light">Kategori Sampah</span>
                            <span className="font-semibold text-white mt-0.5 block">{selectedReport.waste_type || "Belum Terdeteksi"}</span>
                          </div>
                          <div>
                            <span className="text-white/50 block font-light">Tingkat Bahaya</span>
                            <span className="font-semibold text-white mt-0.5 block">{selectedReport.danger_level || "Sedang"}</span>
                          </div>
                          <div>
                            <span className="text-white/50 block font-light">Tanggal Dikirim</span>
                            <span className="font-semibold text-white mt-0.5 block">{new Date(selectedReport.created_at).toLocaleString("id-ID")}</span>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Description */}
                    <div className="flex flex-col gap-1.5">
                      <span className="text-xs text-white/50 font-light">Deskripsi Laporan</span>
                      <p className="bg-white/5 border border-white/5 rounded-2xl p-4 text-xs text-white/95 leading-relaxed font-light">
                        {selectedReport.description || "Tanpa rincian deskripsi."}
                      </p>
                    </div>

                    {/* Admin Action Comments feedback */}
                    <div className="flex flex-col gap-2">
                      <label className="text-xs text-white/70 font-semibold select-none">Catatan / Feedback Verifikasi Administrator</label>
                      <textarea
                        value={adminFeedback}
                        onChange={(e) => setAdminFeedback(e.target.value)}
                        placeholder="Masukkan instruksi khusus atau catatan penolakan..."
                        rows={2}
                        className="bg-white/5 border border-white/10 rounded-2xl p-4 text-xs text-white placeholder-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-colors"
                      />
                    </div>

                    {/* ACTION CONTROLS (ABSOLUTE AUTONOMY) */}
                    <div className="flex flex-wrap items-center justify-end gap-3 pt-4 border-t border-white/5">
                      <button
                        onClick={() => handleUpdateReportStatus(selectedReport.id, "rejected")}
                        disabled={actionLoading}
                        className="rounded-xl border border-burgundy-500/30 bg-burgundy-900/30 text-burgundy-100 px-4 py-2.5 text-xs font-semibold hover:bg-burgundy-500 hover:text-white transition-all duration-200 cursor-pointer"
                      >
                        Tolak Laporan (Fake/Spam)
                      </button>

                      {selectedReport.status !== "approved" && selectedReport.status !== "resolved" && (
                        <button
                          onClick={() => handleUpdateReportStatus(selectedReport.id, "approved")}
                          disabled={actionLoading}
                          className="rounded-xl border border-emerald/30 bg-emerald/10 text-emerald-light px-4 py-2.5 text-xs font-semibold hover:bg-emerald hover:text-white transition-all duration-200 cursor-pointer"
                        >
                          Terima & Setujui Laporan
                        </button>
                      )}

                      {selectedReport.status === "approved" && (
                        <button
                          onClick={() => handleUpdateReportStatus(selectedReport.id, "resolved")}
                          disabled={actionLoading}
                          className="rounded-xl border border-blue-500/30 bg-blue-500/10 text-blue-300 px-4 py-2.5 text-xs font-semibold hover:bg-blue-500 hover:text-white transition-all duration-200 cursor-pointer animate-pulse"
                        >
                          Tandai Selesai Ditangani
                        </button>
                      )}
                    </div>

                  </div>
                </div>
              </div>
            )}

          </div>
        )}

        {/* TAB 3: USER PROFILES MANAGEMENT */}
        {activeTab === "profiles" && (
          <div className="flex flex-col gap-6 animate-fade-up">
            
            {/* Header section with search */}
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
              <div>
                <h1 className="text-2xl font-light">Manajemen Kontrol Warga Genesis.id</h1>
                <p className="text-xs text-white/50 font-light mt-1">
                  Kontrol absolut atas lencana, pencabutan akun ilegal, dan penyesuaian nilai gamifikasi (XP, level, streak) warga.
                </p>
              </div>

              {/* Search bar */}
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-white/40" />
                <input
                  type="text"
                  placeholder="Cari warga/username..."
                  value={profileSearch}
                  onChange={(e) => setProfileSearch(e.target.value)}
                  className="bg-white/5 border border-white/10 rounded-xl pl-9 pr-4 py-1.5 text-xs text-white placeholder-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-colors w-52"
                />
              </div>
            </div>

            {/* Profiles Data Table Container */}
            <div className="liquid-glass rounded-3xl border border-white/10 overflow-hidden shadow-2xl">
              <table className="w-full border-collapse text-left text-xs">
                <thead>
                  <tr className="border-b border-white/5 bg-white/2 select-none font-bold text-white/50 uppercase text-[10px] tracking-wider">
                    <th className="p-4 pl-6">Profil Warga</th>
                    <th className="p-4">Domisili</th>
                    <th className="p-4">Level & XP</th>
                    <th className="p-4">Streak</th>
                    <th className="p-4">Lencana Diperoleh</th>
                    <th className="p-4 pr-6 text-right">Otoritas Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5">
                  {profiles
                    .filter((p) => {
                      const text = (p.full_name || p.username || "").toLowerCase();
                      return text.includes(profileSearch.toLowerCase());
                    })
                    .map((prof) => (
                      <tr key={prof.id} className="hover:bg-white/2 transition-colors">
                        {/* 1. Name & details */}
                        <td className="p-4 pl-6">
                          <div className="flex items-center gap-3">
                            <div className="h-9 w-9 rounded-full bg-white/10 flex items-center justify-center font-bold border border-white/10 shrink-0">
                              {prof.username.charAt(0).toUpperCase()}
                            </div>
                            <div className="flex flex-col">
                              <span className="font-semibold text-white">{prof.full_name || prof.username}</span>
                              <span className="text-[10px] text-white/40 font-mono">ID: {prof.id}</span>
                            </div>
                          </div>
                        </td>

                        {/* 2. City & Province */}
                        <td className="p-4 text-white/80">
                          <div className="flex flex-col">
                            <span>{prof.city_or_district || "Anonim"}</span>
                            <span className="text-[10px] text-white/40">{prof.province || "Anonim"}</span>
                          </div>
                        </td>

                        {/* 3. Level & XP */}
                        <td className="p-4">
                          <div className="flex flex-col">
                            <span className="font-bold">Lvl {prof.level}</span>
                            <span className="text-[10px] text-white/50">{prof.xp} XP</span>
                          </div>
                        </td>

                        {/* 4. Active Streak */}
                        <td className="p-4 font-mono font-semibold text-emerald-light">
                          🔥 {prof.current_streak} Hari
                        </td>

                        {/* 5. Badges list with interactive revoke (x) icon */}
                        <td className="p-4">
                          <div className="flex flex-wrap gap-1.5 max-w-sm">
                            {(prof.badges || []).map((b) => (
                              <span 
                                key={b.code} 
                                className="group flex items-center gap-1 text-[9px] font-bold bg-white/5 text-white/80 px-2 py-0.5 rounded-full border border-white/10"
                              >
                                {b.title}
                                <button 
                                  onClick={() => handleRevokeBadge(prof.id, b.code)}
                                  className="text-white/40 hover:text-burgundy-300 transition-colors shrink-0 cursor-pointer ml-0.5"
                                  title="Cabut Lencana"
                                >
                                  &times;
                                </button>
                              </span>
                            ))}
                            {(prof.badges || []).length === 0 && (
                              <span className="text-[10px] text-white/30 italic">Belum mendapat lencana.</span>
                            )}
                          </div>
                        </td>

                        {/* 6. Absolute controls */}
                        <td className="p-4 pr-6 text-right">
                          <div className="flex items-center justify-end gap-2.5">
                            
                            {/* Adjust gamification buttons */}
                            <button
                              onClick={() => {
                                setSelectedReportProfile(prof);
                                setAdjustXp(prof.xp);
                                setAdjustLevel(prof.level);
                                setAdjustStreak(prof.current_streak);
                                setIsAdjustGamifyOpen(true);
                              }}
                              className="p-2 rounded-lg border border-white/10 bg-white/5 text-white/80 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
                              title="Koreksi Nilai Gamifikasi"
                            >
                              <Sliders className="h-3.5 w-3.5" />
                            </button>

                            {/* Award Badge button */}
                            <button
                              onClick={() => {
                                setSelectedReportProfile(prof);
                                setBadgeToAward("");
                                setIsAwardBadgeOpen(true);
                              }}
                              className="p-2 rounded-lg border border-white/10 bg-white/5 text-gold hover:bg-gold/10 transition-colors cursor-pointer"
                              title="Sematkan Lencana Baru"
                            >
                              <Award className="h-3.5 w-3.5" />
                            </button>

                            {/* Delete User absolutely */}
                            <button
                              onClick={() => handleDeleteUserProfile(prof.id)}
                              className="p-2 rounded-lg border border-burgundy-500/20 bg-burgundy-900/10 text-burgundy-300 hover:bg-burgundy-500 hover:text-white transition-colors cursor-pointer"
                              title="Hapus Akun User Permanen"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                            </button>

                          </div>
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>

            {/* MODAL 1: ADJUST GAMIFICATION */}
            {isAdjustGamifyOpen && selectedProfile && (
              <div className="fixed inset-0 bg-black/60 backdrop-blur-md flex items-center justify-center p-4 z-50">
                <div className="w-full max-w-sm bg-navy-900/95 border border-white/10 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
                  
                  <div className="border-b border-white/5 pb-3">
                    <h3 className="text-base font-semibold">Koreksi Gamifikasi Warga</h3>
                    <p className="text-[11px] text-white/50 mt-0.5">Edit XP, Level, dan Streak untuk {selectedProfile.full_name || selectedProfile.username}.</p>
                  </div>

                  <div className="flex flex-col gap-4">
                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1 select-none">Experience Points (XP)</label>
                      <input
                        type="number"
                        value={adjustXp}
                        onChange={(e) => setAdjustXp(parseInt(e.target.value) || 0)}
                        className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none"
                      />
                    </div>

                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1 select-none">Level Warga</label>
                      <input
                        type="number"
                        value={adjustLevel}
                        onChange={(e) => setAdjustLevel(parseInt(e.target.value) || 1)}
                        className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none"
                      />
                    </div>

                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1 select-none">Current Daily Streak (Hari)</label>
                      <input
                        type="number"
                        value={adjustStreak}
                        onChange={(e) => setAdjustStreak(parseInt(e.target.value) || 0)}
                        className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none"
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-white/5">
                    <button
                      onClick={() => setIsAdjustGamifyOpen(false)}
                      className="rounded-xl bg-white/5 text-white/70 border border-white/10 px-4 py-2 text-xs font-semibold hover:bg-white/10 transition-all cursor-pointer"
                    >
                      Batal
                    </button>
                    <button
                      onClick={handleAdjustGamification}
                      disabled={actionLoading}
                      className="rounded-xl bg-white text-navy-950 px-4 py-2 text-xs font-semibold hover:bg-white/90 transition-all cursor-pointer"
                    >
                      Terapkan Koreksi
                    </button>
                  </div>

                </div>
              </div>
            )}

            {/* MODAL 2: AWARD BADGE */}
            {isAwardBadgeOpen && selectedProfile && (
              <div className="fixed inset-0 bg-black/60 backdrop-blur-md flex items-center justify-center p-4 z-50">
                <div className="w-full max-w-sm bg-navy-900/95 border border-white/10 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
                  
                  <div className="border-b border-white/5 pb-3">
                    <h3 className="text-base font-semibold">Sematkan Lencana Baru</h3>
                    <p className="text-[11px] text-white/50 mt-0.5">Pilih lencana prestasi untuk disematkan pada {selectedProfile.full_name || selectedProfile.username}.</p>
                  </div>

                  <div className="flex flex-col gap-1.5">
                    <label className="text-[11px] font-semibold text-white/70 pl-1 select-none">Lencana Tersedia</label>
                    <select
                      value={badgeToAward}
                      onChange={(e) => setBadgeToAward(e.target.value)}
                      className="w-full bg-navy-950 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none cursor-pointer"
                    >
                      <option value="">-- Pilih Lencana --</option>
                      {badges.map((b) => (
                        <option key={b.code} value={b.code}>
                          {b.title} - {b.description}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-white/5">
                    <button
                      onClick={() => setIsAwardBadgeOpen(false)}
                      className="rounded-xl bg-white/5 text-white/70 border border-white/10 px-4 py-2 text-xs font-semibold hover:bg-white/10 transition-all cursor-pointer"
                    >
                      Batal
                    </button>
                    <button
                      onClick={handleAwardBadge}
                      disabled={actionLoading || !badgeToAward}
                      className="rounded-xl bg-gold text-white px-4 py-2 text-xs font-semibold hover:scale-105 active:scale-95 transition-all cursor-pointer"
                    >
                      Sematkan Lencana
                    </button>
                  </div>

                </div>
              </div>
            )}

          </div>
        )}

        {/* TAB 4: RAG KNOWLEDGE BASE */}
        {activeTab === "rag" && (
          <div className="flex flex-col gap-6 animate-fade-up">
            
            {/* Header section with actions */}
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
              <div>
                <h1 className="text-2xl font-light">Basis Pengetahuan AI & Regulasi Sampah</h1>
                <p className="text-xs text-white/50 font-light mt-1">
                  Unggah file regulasi kota, SOP, dan aturan penanganan limbah daerah untuk melatih chatbot RAG AI warga.
                </p>
              </div>

              <button
                onClick={() => setIsAwardRagOpen(true)}
                className="flex items-center gap-2 self-start bg-white text-navy-950 rounded-xl px-4 py-2 text-xs font-semibold hover:bg-white/90 hover:scale-[1.02] active:scale-[0.98] transition-all cursor-pointer shadow-md"
              >
                <Plus className="h-4 w-4 shrink-0" />
                Latih Dokumen RAG Baru
              </button>
            </div>

            {/* RAG Documents Grid cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {ragDocs.map((doc) => (
                <div key={doc.id} className="liquid-glass rounded-3xl p-6 border border-white/10 bg-white/2 flex flex-col justify-between gap-5">
                  <div className="flex flex-col gap-2">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-bold text-gold uppercase tracking-wider">{doc.category}</span>
                      <span className="text-[10px] text-white/40">{doc.id}</span>
                    </div>
                    <h3 className="text-sm font-semibold text-white leading-snug mt-1">{doc.title}</h3>
                  </div>

                  <div className="flex items-center justify-between border-t border-white/5 pt-4">
                    <div className="flex flex-col">
                      <span className="text-[10px] text-white/40">Karakter Terindeks</span>
                      <span className="text-xs font-bold font-mono mt-0.5">{(doc.charCount / 1000).toFixed(1)}k Chars</span>
                    </div>
                    <span className="text-[10px] text-white/50">{doc.createdAt}</span>
                  </div>
                </div>
              ))}
            </div>

            {/* MODAL 3: TRAIN RAG NEW DOCUMENT */}
            {isAddRagOpen && (
              <div className="fixed inset-0 bg-black/60 backdrop-blur-md flex items-center justify-center p-4 z-50">
                <div className="w-full max-w-lg bg-navy-900/95 border border-white/10 rounded-3xl shadow-2xl p-6 md:p-8 flex flex-col gap-6">
                  
                  <div className="border-b border-white/5 pb-3 select-none">
                    <h3 className="text-base font-semibold">Latih Dokumen Pengetahuan RAG</h3>
                    <p className="text-[11px] text-white/50 mt-0.5">Tambahkan dokumen teks regulasi atau SOP untuk memperkaya kecerdasan RAG Chatbot.</p>
                  </div>

                  <div className="flex flex-col gap-4">
                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1">Judul Dokumen</label>
                      <input
                        type="text"
                        value={ragTitle}
                        onChange={(e) => setRagTitle(e.target.value)}
                        placeholder="e.g. UU Penanganan Sampah No 15"
                        className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none"
                      />
                    </div>

                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1">Kategori Dokumen</label>
                      <select
                        value={ragCategory}
                        onChange={(e) => setRagCategory(e.target.value)}
                        className="w-full bg-navy-950 border border-white/10 rounded-xl py-2 px-3 text-xs text-white focus:outline-none cursor-pointer"
                      >
                        <option value="Undang-Undang">Undang-Undang</option>
                        <option value="Peraturan Daerah">Peraturan Daerah</option>
                        <option value="SOP Penanganan">Standard Operating Procedure (SOP)</option>
                        <option value="Sanksi & Denda">Sanksi & Denda Lingkungan</option>
                      </select>
                    </div>

                    <div className="flex flex-col gap-1.5">
                      <label className="text-[11px] font-semibold text-white/70 pl-1">Isi Dokumen Teks Regulasi</label>
                      <textarea
                        value={ragContent}
                        onChange={(e) => setRagContent(e.target.value)}
                        placeholder="Tempel dokumen lengkap atau salinan pasal regulasi di sini..."
                        rows={6}
                        className="w-full bg-white/5 border border-white/10 rounded-2xl p-3 text-xs text-white focus:outline-none"
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-white/5">
                    <button
                      onClick={() => setIsAwardRagOpen(false)}
                      className="rounded-xl bg-white/5 text-white/70 border border-white/10 px-4 py-2 text-xs font-semibold hover:bg-white/10 transition-all cursor-pointer"
                    >
                      Batal
                    </button>
                    <button
                      onClick={handleAddRagDoc}
                      disabled={!ragTitle || !ragContent}
                      className="rounded-xl bg-white text-navy-950 px-4 py-2 text-xs font-semibold hover:bg-white/90 hover:scale-105 active:scale-95 transition-all cursor-pointer"
                    >
                      Mulai Pelatihan AI RAG
                    </button>
                  </div>

                </div>
              </div>
            )}

          </div>
        )}

      </div>

    </main>
  );
}
