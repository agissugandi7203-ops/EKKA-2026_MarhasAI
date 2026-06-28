"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { 
  Sun, 
  Moon, 
  Sparkles, 
  Send, 
  Bot, 
  AlertTriangle, 
  RefreshCw, 
  Search, 
  X, 
  Loader2, 
  ArrowRight,
  ShieldCheck
} from "lucide-react";

// Sub-components
import Sidebar, { AdminTab } from "./components/Sidebar";
import OverviewTab, { TrashReport, UserProfile } from "./components/OverviewTab";
import ReportsTab from "./components/ReportsTab";
import ProfilesTab from "./components/ProfilesTab";
import RagTab from "./components/RagTab";
import ChallengesTab, { Challenge, OfficialEvent } from "./components/ChallengesTab";
import BroadcastTab, { BroadcastLog } from "./components/BroadcastTab";
import AuditTab, { AuditLog } from "./components/AuditTab";

// Master structures
export interface Badge {
  id: string;
  code: string;
  title: string;
  description: string;
  image_url?: string;
}

export interface RAGDocument {
  id: string;
  title: string;
  category: string;
  charCount: number;
  createdAt: string;
  content?: string;
}

const getBackendUrl = (): string => {
  return "https://genesisHub.my.id";
};

export default function AdminDashboard() {
  const router = useRouter();
  const backendUrl = getBackendUrl();

  // --- STATE SYSTEM ---
  const [adminName, setAdminName] = useState<string>("Admin");
  const [adminEmail, setAdminEmail] = useState<string>("");
  const [isLive, setIsLive] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<AdminTab>("overview");
  
  // Theme state (Default light, matches design requirements)
  const [theme, setTheme] = useState<"light" | "dark">("light");
  
  // Strict connection error state to avoid silent fallback to dummy data
  const [connectionError, setConnectionError] = useState<string | null>(null);

  // AI Assistant Drawer state and conversation history
  const [isAiDrawerOpen, setIsAiDrawerOpen] = useState<boolean>(false);
  const [aiMessages, setAiMessages] = useState<Array<{ sender: "user" | "ai", text: string, timestamp: string }>>([
    { sender: "ai", text: "Halo Administrator! Saya adalah Asisten AI Marhas. Saya siap membantu Anda mengelola data laporan, memantau tingkat bahaya, dan menganalisis status operasional geospasial Genesis.id secara real-time. Ada yang bisa saya bantu hari ini?", timestamp: new Date().toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" }) }
  ]);
  const [aiInput, setAiInput] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(true);
  const [actionLoading, setActionLoading] = useState<boolean>(false);

  // Data collections
  const [reports, setReports] = useState<TrashReport[]>([]);
  const [profiles, setProfiles] = useState<UserProfile[]>([]);
  const [badges, setBadges] = useState<Badge[]>([]);
  const [ragDocs, setRagDocs] = useState<RAGDocument[]>([]);
  
  // New upgraded states
  const [bannedUserIds, setBannedUserIds] = useState<string[]>([]);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>([]);
  const [broadcastLogs, setBroadcastLogs] = useState<BroadcastLog[]>([]);
  const [challenges, setChallenges] = useState<Challenge[]>([]);
  const [events, setEvents] = useState<OfficialEvent[]>([]);

  // Search/Filter states
  const [reportSearch, setReportSearch] = useState<string>("");
  const [reportFilter, setReportFilter] = useState<string>("all");
  const [profileSearch, setProfileSearch] = useState<string>("");

  // Detailed selected views for Modals
  const [selectedReport, setSelectedReport] = useState<TrashReport | null>(null);
  const [selectedProfile, setSelectedProfile] = useState<UserProfile | null>(null);
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
  const [isAddRagOpen, setIsAddRagOpen] = useState<boolean>(false);
  const [ragTitle, setRagTitle] = useState<string>("Tuntunan");
  const [ragCategory, setRagCategory] = useState<string>("Undang-Undang");
  const [ragContent, setRagContent] = useState<string>("");

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
        waste_type: "Plastik",
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
        waste_type: "B3",
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
        waste_type: "Organik",
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
        waste_type: "Konstruksi",
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
    const savedTheme = localStorage.getItem("admin_theme") as "light" | "dark" | null;

    setAdminEmail(email);
    setAdminName(name);
    setIsLive(mode === "live");
    if (savedTheme) {
      setTheme(savedTheme);
    }

    fetchData(mode === "live", token);
  }, []);

  // --- ACTIONS: THEME & CONNECTION MODE TOGGLES ---
  const handleToggleTheme = () => {
    const nextTheme = theme === "light" ? "dark" : "light";
    setTheme(nextTheme);
    localStorage.setItem("admin_theme", nextTheme);
  };

  const handleToggleMode = () => {
    const nextMode = !isLive;
    setIsLive(nextMode);
    localStorage.setItem("genesis_admin_mode", nextMode ? "live" : "simulator");
    const token = localStorage.getItem("genesis_admin_token") || "";
    setConnectionError(null); // Reset any error
    fetchData(nextMode, token);
  };

  // --- FETCH DATA CONTROLLER ---
  const fetchData = async (liveMode: boolean, token: string) => {
    setLoading(true);
    const { mockProfiles, mockReports, mockBadges, mockRagDocs } = generateMockData();

    // Default pre-seeded lists for newly engineered modules
    const defaultChallenges: Challenge[] = [
      { id: "ch-1", code: "report_plastic", title: "Kurangi Sampah Plastik Selokan", xp: 150, points: 20, created_at: "2026-06-01T00:00:00Z" },
      { id: "ch-2", code: "report_b3", title: "Pelopor Pengawas Limbah B3", xp: 300, points: 50, created_at: "2026-06-05T00:00:00Z" },
      { id: "ch-3", code: "report_organic", title: "Pahlawan Pengomposan Hijau", xp: 100, points: 15, created_at: "2026-06-10T00:00:00Z" }
    ];

    const defaultEvents: OfficialEvent[] = [
      { id: "ev-1", title: "Surabaya Green Festival 2026", description: "Kerja bakti pembersihan lingkungan terpadu di seluruh kelurahan kota.", points: 500, created_at: "2026-06-12T00:00:00Z" },
      { id: "ev-2", title: "Gerakan Pilah Sampah Mandiri", description: "Edukasi pilah sampah anorganik dan organik di hulu rumah tangga.", points: 350, created_at: "2026-06-18T00:00:00Z" }
    ];

    const defaultBroadcastLogs: BroadcastLog[] = [
      { id: "bc-01", title: "Peringatan Cuaca Ekstrim & Drainase", message: "Mohon waspada terhadap sampah penyumbat drainase menyambut musim hujan.", category: "alert", target: "all", created_at: "2026-06-27T08:00:00Z" },
      { id: "bc-02", title: "Undangan Surabaya Green Festival", message: "Mari berpartisipasi dan bersihkan kota demi lencana kebanggaan daerah.", category: "event", target: "all", created_at: "2026-06-27T10:00:00Z" }
    ];

    const defaultAuditLogs: AuditLog[] = [
      { id: "aud-01", adminName: "Admin", actionType: "LOGIN", detail: "Berhasil membuka sesi otoritas administratif", timestamp: "2026-06-28T09:00:00Z" },
      { id: "aud-02", adminName: "Admin", actionType: "SYSTEM_LOAD", detail: "Sistem dasbor admin berhasil dimuat dan disinkronkan", timestamp: "2026-06-28T09:00:05Z" }
    ];

    const defaultBannedUsers: string[] = [];

    if (!liveMode) {
      // Offline/Simulator Emulator Mode
      const savedProfiles = localStorage.getItem("emu_profiles");
      const savedReports = localStorage.getItem("emu_reports");
      const savedRag = localStorage.getItem("emu_rag_docs");
      const savedBadges = localStorage.getItem("emu_badges");
      const savedBanned = localStorage.getItem("emu_banned_users");
      const savedChallenges = localStorage.getItem("emu_challenges");
      const savedEvents = localStorage.getItem("emu_events");
      const savedBroadcast = localStorage.getItem("emu_broadcast_logs");
      const savedAudit = localStorage.getItem("emu_audit_logs");

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

      if (savedRag) setRagDocs(JSON.parse(savedRag));
      else {
        setRagDocs(mockRagDocs);
        localStorage.setItem("emu_rag_docs", JSON.stringify(mockRagDocs));
      }

      if (savedBadges) setBadges(JSON.parse(savedBadges));
      else {
        setBadges(mockBadges);
        localStorage.setItem("emu_badges", JSON.stringify(mockBadges));
      }

      if (savedBanned) setBannedUserIds(JSON.parse(savedBanned));
      else {
        setBannedUserIds(defaultBannedUsers);
        localStorage.setItem("emu_banned_users", JSON.stringify(defaultBannedUsers));
      }

      if (savedChallenges) setChallenges(JSON.parse(savedChallenges));
      else {
        setChallenges(defaultChallenges);
        localStorage.setItem("emu_challenges", JSON.stringify(defaultChallenges));
      }

      if (savedEvents) setEvents(JSON.parse(savedEvents));
      else {
        setEvents(defaultEvents);
        localStorage.setItem("emu_events", JSON.stringify(defaultEvents));
      }

      if (savedBroadcast) setBroadcastLogs(JSON.parse(savedBroadcast));
      else {
        setBroadcastLogs(defaultBroadcastLogs);
        localStorage.setItem("emu_broadcast_logs", JSON.stringify(defaultBroadcastLogs));
      }

      if (savedAudit) setAuditLogs(JSON.parse(savedAudit));
      else {
        setAuditLogs(defaultAuditLogs);
        localStorage.setItem("emu_audit_logs", JSON.stringify(defaultAuditLogs));
      }

      setLoading(false);
      return;
    }

    // Live Mode API Integration
    try {
      setConnectionError(null);

      // 1. Profiles
      const profilesRes = await fetch(`${backendUrl}/profiles`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      if (!profilesRes.ok) {
        throw new Error(`Gagal mengambil data profil (Status HTTP: ${profilesRes.status})`);
      }
      const profilesData = await profilesRes.json();

      // 2. Reports
      const reportsRes = await fetch(`${backendUrl}/reports`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      if (!reportsRes.ok) {
        throw new Error(`Gagal mengambil data laporan (Status HTTP: ${reportsRes.status})`);
      }
      const reportsData = await reportsRes.json();

      // 3. Badges
      const badgesRes = await fetch(`${backendUrl}/badges`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      if (!badgesRes.ok) {
        throw new Error(`Gagal mengambil data lencana (Status HTTP: ${badgesRes.status})`);
      }
      const badgesData = await badgesRes.json();

      // 4. RAG / Knowledge Base
      let ragDocsData: RAGDocument[] = [];
      const ragRes = await fetch(`${backendUrl}/knowledge-base`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      if (!ragRes.ok) {
        throw new Error(`Gagal mengambil data basis pengetahuan RAG (Status HTTP: ${ragRes.status})`);
      }
      const rawRag = await ragRes.json();
      if (Array.isArray(rawRag)) {
        ragDocsData = rawRag.map((r: any) => ({
          id: r.id || "",
          title: r.title || "",
          category: r.metadata?.category || "Regulasi",
          charCount: r.content ? r.content.length : 0,
          createdAt: r.created_at ? new Date(r.created_at).toISOString().split("T")[0] : "",
          content: r.content || ""
        }));
      }

      // Read administrative extension layers from LocalStorage also in Live Mode if backend endpoints are pure base RLS restricted
      const savedBanned = localStorage.getItem("emu_banned_users");
      setBannedUserIds(savedBanned ? JSON.parse(savedBanned) : defaultBannedUsers);

      const savedChallenges = localStorage.getItem("emu_challenges");
      setChallenges(savedChallenges ? JSON.parse(savedChallenges) : defaultChallenges);

      const savedEvents = localStorage.getItem("emu_events");
      setEvents(savedEvents ? JSON.parse(savedEvents) : defaultEvents);

      const savedBroadcast = localStorage.getItem("emu_broadcast_logs");
      setBroadcastLogs(savedBroadcast ? JSON.parse(savedBroadcast) : defaultBroadcastLogs);

      const savedAudit = localStorage.getItem("emu_audit_logs");
      setAuditLogs(savedAudit ? JSON.parse(savedAudit) : defaultAuditLogs);

      setProfiles(Array.isArray(profilesData) ? profilesData : []);
      setReports(Array.isArray(reportsData) ? reportsData : []);
      setBadges(Array.isArray(badgesData) ? badgesData : []);
      setRagDocs(ragDocsData);

    } catch (err: any) {
      console.error("Failed to load live data:", err);
      setProfiles([]);
      setReports([]);
      setBadges([]);
      setRagDocs([]);
      setConnectionError(err.message || "Gagal menghubungi server backend produksi.");
    } finally {
      setLoading(false);
    }
  };

  // --- TRIGGER RE-FETCH SHORTHAND ---
  const handleTriggerFetch = () => {
    const token = localStorage.getItem("genesis_admin_token") || "";
    fetchData(isLive, token);
  };

  // --- HANDLERS: LOGOUT ---
  const handleLogout = () => {
    localStorage.removeItem("genesis_admin_token");
    localStorage.removeItem("genesis_admin_email");
    localStorage.removeItem("genesis_admin_name");
    localStorage.removeItem("genesis_admin_role");
    localStorage.removeItem("genesis_admin_mode");
    router.push("/admin/login");
  };

  // --- WRITE AUDIT LOG HELPER ---
  const writeAuditLog = async (actionType: string, detail: string) => {
    const newLog: AuditLog = {
      id: `aud-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      adminName: adminName || "Admin",
      actionType,
      detail,
      timestamp: new Date().toISOString()
    };
    setAuditLogs(prev => {
      const updated = [newLog, ...prev];
      localStorage.setItem("emu_audit_logs", JSON.stringify(updated));
      return updated;
    });
  };

  // --- HANDLERS: REPORT ABSOLUTE CONTROL ---
  const handleUpdateReportStatus = async (id: string, nextStatus: "approved" | "resolved" | "rejected") => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local Simulator Update
      const updated = reports.map((r) => {
        if (r.id === id) {
          return { ...r, status: nextStatus, description: r.description + (adminFeedback ? `\n\n[Feedback Admin]: ${adminFeedback}` : "") };
        }
        return r;
      });
      setReports(updated);
      localStorage.setItem("emu_reports", JSON.stringify(updated));

      // Award automatic mock XP to reporter if approved
      if (nextStatus === "approved" || nextStatus === "resolved") {
        const matchingReport = reports.find(r => r.id === id);
        if (matchingReport) {
          const updatedProfiles = profiles.map((p) => {
            if (p.id === matchingReport.reporter_id) {
              return { ...p, xp: p.xp + 150 };
            }
            return p;
          });
          setProfiles(updatedProfiles);
          localStorage.setItem("emu_profiles", JSON.stringify(updatedProfiles));
        }
      }

      await writeAuditLog("VERIFY_REPORT", `Mengubah status laporan #${id} menjadi ${nextStatus.toUpperCase()}`);
      setSelectedReport(null);
      setAdminFeedback("");
      setActionLoading(false);
      return;
    }

    // Live API update
    try {
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
        await writeAuditLog("VERIFY_REPORT", `[Live] Mengubah status laporan #${id} menjadi ${nextStatus.toUpperCase()}`);
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

  // --- HANDLERS: DELETE INDIVIDUAL REPORT ---
  const handleDeleteReport = async (id: string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      const updated = reports.filter(r => r.id !== id);
      setReports(updated);
      localStorage.setItem("emu_reports", JSON.stringify(updated));
      await writeAuditLog("DELETE_REPORT", `Menghapus laporan sampah #${id} secara permanen`);
      setActionLoading(false);
      return;
    }

    try {
      const res = await fetch(`${backendUrl}/reports/${id}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });
      if (res.ok) {
        setReports(prev => prev.filter(r => r.id !== id));
        await writeAuditLog("DELETE_REPORT", `[Live] Menghapus laporan sampah #${id} secara permanen`);
      } else {
        alert("Gagal menghapus laporan dari backend.");
      }
    } catch (err) {
      console.error("Live delete report error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: BATCH ACTIONS FOR REPORTS ---
  const handleBatchAction = async (ids: string[], action: "approved" | "rejected" | "delete") => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      if (action === "delete") {
        const updated = reports.filter(r => !ids.includes(r.id));
        setReports(updated);
        localStorage.setItem("emu_reports", JSON.stringify(updated));
        await writeAuditLog("BATCH_DELETE", `Menghapus massal ${ids.length} laporan sampah`);
      } else {
        const updated = reports.map(r => {
          if (ids.includes(r.id)) {
            return { ...r, status: action };
          }
          return r;
        });
        setReports(updated);
        localStorage.setItem("emu_reports", JSON.stringify(updated));
        await writeAuditLog(
          action === "approved" ? "BATCH_APPROVE" : "BATCH_REJECT",
          `Memperbarui status ${ids.length} laporan menjadi ${action.toUpperCase()}`
        );
      }
      setActionLoading(false);
      return;
    }

    try {
      for (const id of ids) {
        if (action === "delete") {
          await fetch(`${backendUrl}/reports/${id}`, {
            method: "DELETE",
            headers: { "Authorization": `Bearer ${token}` }
          });
        } else {
          await fetch(`${backendUrl}/reports/${id}`, {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({ status: action, admin_notes: "Aksi massal oleh Administrator." })
          });
        }
      }
      await writeAuditLog(
        action === "delete" ? "BATCH_DELETE" : action === "approved" ? "BATCH_APPROVE" : "BATCH_REJECT",
        `[Live] Eksekusi massal ${action.toUpperCase()} pada ${ids.length} laporan`
      );
      fetchData(true, token || "");
    } catch (err) {
      console.error("Live batch action error:", err);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: USER SUSPENSION (BAN SYSTEM) ---
  const handleToggleBan = async (profileId: string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const isBanned = bannedUserIds.includes(profileId);
    const profile = profiles.find(p => p.id === profileId);
    const username = profile?.username || profileId;

    const updatedBanned = isBanned
      ? bannedUserIds.filter(id => id !== profileId)
      : [...bannedUserIds, profileId];
    
    setBannedUserIds(updatedBanned);
    localStorage.setItem("emu_banned_users", JSON.stringify(updatedBanned));

    await writeAuditLog(
      isBanned ? "UNBAN_USER" : "BAN_USER",
      `${isBanned ? "Membatalkan suspensi" : "Menangguhkan/memblokir"} akun warga @${username}`
    );

    if (isLive) {
      try {
        await fetch(`${backendUrl}/profiles/${profileId}/status`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
          },
          body: JSON.stringify({ banned: !isBanned })
        });
      } catch (err) {
        console.error("Live status endpoint failed, local emulation state synced instead:", err);
      }
    }
    setActionLoading(false);
  };

  // --- HANDLERS: BADGE CATALOG CRUD ---
  const handleCreateBadge = async (code: string, title: string, description: string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const newBdg: Badge = {
      id: `bdg-${Date.now()}`,
      code,
      title,
      description
    };

    if (!isLive) {
      const updated = [...badges, newBdg];
      setBadges(updated);
      localStorage.setItem("emu_badges", JSON.stringify(updated));
      await writeAuditLog("CREATE_BADGE", `Membuat katalog lencana baru: ${title} (${code})`);
      setActionLoading(false);
      return;
    }

    try {
      const res = await fetch(`${backendUrl}/badges`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({ code, title, description })
      });
      if (res.ok) {
        const freshBdg = await res.json();
        setBadges(prev => [...prev, freshBdg]);
        await writeAuditLog("CREATE_BADGE", `[Live] Membuat katalog lencana baru: ${title} (${code})`);
      } else {
        setBadges(prev => [...prev, newBdg]);
        await writeAuditLog("CREATE_BADGE", `[Live Fallback] Membuat katalog lencana baru: ${title} (${code})`);
      }
    } catch (err) {
      setBadges(prev => [...prev, newBdg]);
    } finally {
      setActionLoading(false);
    }
  };

  const handleDeleteBadge = async (id: string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const targetBadge = badges.find(b => b.id === id);
    const badgeTitle = targetBadge?.title || id;

    if (!isLive) {
      const updated = badges.filter(b => b.id !== id);
      setBadges(updated);
      localStorage.setItem("emu_badges", JSON.stringify(updated));
      await writeAuditLog("DELETE_BADGE", `Menghapus lencana dari katalog sistem: ${badgeTitle}`);
      setActionLoading(false);
      return;
    }

    try {
      await fetch(`${backendUrl}/badges/${id}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });
      const updated = badges.filter(b => b.id !== id);
      setBadges(updated);
      await writeAuditLog("DELETE_BADGE", `[Live] Menghapus lencana dari katalog sistem: ${badgeTitle}`);
    } catch (err) {
      const updated = badges.filter(b => b.id !== id);
      setBadges(updated);
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
      // Local simulator update
      const updated = profiles.map((p) => {
        if (p.id === selectedProfile.id) {
          return { ...p, xp: adjustXp, level: adjustLevel, current_streak: adjustStreak };
        }
        return p;
      });
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      await writeAuditLog("ADJUST_GAMIFY", `Menyesuaikan gamifikasi @${selectedProfile.username}: ${adjustXp} XP, Level ${adjustLevel}, Streak ${adjustStreak}`);
      setIsAdjustGamifyOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API Call
    try {
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
        await writeAuditLog("ADJUST_GAMIFY", `[Live] Menyesuaikan gamifikasi @${selectedProfile.username}: ${adjustXp} XP, Level ${adjustLevel}, Streak ${adjustStreak}`);
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
      // Local emulator award
      const updated = profiles.map((p) => {
        if (p.id === selectedProfile.id) {
          const currentBadges = p.badges || [];
          if (currentBadges.some(b => b.code === badgeToAward)) return p;
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
      await writeAuditLog("AWARD_BADGE", `Menyematkan lencana ${badgeObj?.title || badgeToAward} ke profil @${selectedProfile.username}`);
      setIsAwardBadgeOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API award
    try {
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
        await writeAuditLog("AWARD_BADGE", `[Live] Menyematkan lencana ${badgeObj?.title || badgeToAward} ke profil @${selectedProfile.username}`);
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
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const userProfile = profiles.find(p => p.id === profileId);

    if (!isLive) {
      // Local emulator revoke
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
      await writeAuditLog("REVOKE_BADGE", `Mencabut lencana ${badgeCode} dari warga @${userProfile?.username}`);
      setActionLoading(false);
      return;
    }

    // Live API revoke
    try {
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
        await writeAuditLog("REVOKE_BADGE", `[Live] Mencabut lencana ${badgeCode} dari warga @${userProfile?.username}`);
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
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const userProfile = profiles.find(p => p.id === profileId);
    const username = userProfile?.username || profileId;

    if (!isLive) {
      // Local emulator delete
      const updated = profiles.filter(p => p.id !== profileId);
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      await writeAuditLog("DELETE_USER", `Menghapus absolut akun warga @${username}`);
      setActionLoading(false);
      return;
    }

    // Live API delete
    try {
      const res = await fetch(`${backendUrl}/profiles/${profileId}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });

      if (res.ok) {
        await writeAuditLog("DELETE_USER", `[Live] Menghapus absolut akun warga @${username}`);
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
  const handleAddRagDoc = async () => {
    if (!ragTitle || !ragContent) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local emulator add
      const newDoc: RAGDocument = {
        id: `rag-${Date.now()}`,
        title: ragTitle,
        category: ragCategory,
        charCount: ragContent.length,
        createdAt: new Date().toISOString().split("T")[0],
        content: ragContent
      };

      const updated = [newDoc, ...ragDocs];
      setRagDocs(updated);
      localStorage.setItem("emu_rag_docs", JSON.stringify(updated));
      await writeAuditLog("TRAIN_RAG", `Melatih basis data AI RAG dengan regulasi: ${ragTitle}`);

      setRagTitle("Tuntunan");
      setRagContent("");
      setIsAddRagOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API Add
    try {
      const res = await fetch(`${backendUrl}/knowledge-base`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          title: ragTitle,
          content: ragContent,
          metadata: {
            category: ragCategory
          }
        })
      });

      if (res.ok) {
        await writeAuditLog("TRAIN_RAG", `[Live] Melatih basis data AI RAG dengan regulasi: ${ragTitle}`);
        fetchData(true, token || "");
        setRagTitle("Tuntunan");
        setRagContent("");
        setIsAddRagOpen(false);
      } else {
        const errData = await res.json().catch(() => ({}));
        alert(`Gagal melatih RAG: ${errData.message || "Periksa server."}`);
      }
    } catch (err: any) {
      console.error("Live add RAG doc error:", err);
      alert("Error: " + err.message);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: DELETE RAG DOCUMENT ---
  const handleDeleteRagDoc = async (id: string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const docTitle = ragDocs.find(d => d.id === id)?.title || id;

    if (!isLive) {
      // Local emulator delete
      const updated = ragDocs.filter(d => d.id !== id);
      setRagDocs(updated);
      localStorage.setItem("emu_rag_docs", JSON.stringify(updated));
      await writeAuditLog("DELETE_RAG", `Menghapus dokumen regulasi RAG: ${docTitle}`);
      setActionLoading(false);
      return;
    }

    // Live API delete
    try {
      const res = await fetch(`${backendUrl}/knowledge-base/${id}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });

      if (res.ok) {
        await writeAuditLog("DELETE_RAG", `[Live] Menghapus dokumen regulasi RAG: ${docTitle}`);
        fetchData(true, token || "");
      } else {
        const errData = await res.json().catch(() => ({}));
        alert(`Gagal menghapus dokumen RAG: ${errData.message || "Akses Ditolak."}`);
      }
    } catch (err: any) {
      console.error("Live delete RAG doc error:", err);
      alert("Error: " + err.message);
    } finally {
      setActionLoading(false);
    }
  };

  // --- HANDLERS: GAMIFICATION CHALLENGES & EVENTS ---
  const handleAddChallenge = async (code: string, title: string, xp: number, points: number) => {
    setActionLoading(true);
    const newChal: Challenge = {
      id: `ch-${Date.now()}`,
      code,
      title,
      xp,
      points,
      created_at: new Date().toISOString()
    };
    const updated = [newChal, ...challenges];
    setChallenges(updated);
    localStorage.setItem("emu_challenges", JSON.stringify(updated));
    await writeAuditLog("CREATE_CHALLENGE", `Membuat misi harian baru: ${title} (+${xp} XP, +${points} Pts)`);
    setActionLoading(false);
  };

  const handleDeleteChallenge = async (id: string) => {
    setActionLoading(true);
    const targetChal = challenges.find(c => c.id === id);
    const chalTitle = targetChal?.title || id;
    const updated = challenges.filter(c => c.id !== id);
    setChallenges(updated);
    localStorage.setItem("emu_challenges", JSON.stringify(updated));
    await writeAuditLog("DELETE_CHALLENGE", `Menghapus misi harian: ${chalTitle}`);
    setActionLoading(false);
  };

  const handleAddEvent = async (title: string, description: string, points: number) => {
    setActionLoading(true);
    const newEvent: OfficialEvent = {
      id: `ev-${Date.now()}`,
      title,
      description,
      points,
      created_at: new Date().toISOString()
    };
    const updated = [newEvent, ...events];
    setEvents(updated);
    localStorage.setItem("emu_events", JSON.stringify(updated));
    await writeAuditLog("CREATE_EVENT", `Membuat event resmi kota: ${title} (+${points} Pts)`);
    setActionLoading(false);
  };

  const handleDeleteEvent = async (id: string) => {
    setActionLoading(true);
    const targetEv = events.find(e => e.id === id);
    const evTitle = targetEv?.title || id;
    const updated = events.filter(e => e.id !== id);
    setEvents(updated);
    localStorage.setItem("emu_events", JSON.stringify(updated));
    await writeAuditLog("DELETE_EVENT", `Menghapus event resmi kota: ${evTitle}`);
    setActionLoading(false);
  };

  // --- HANDLERS: BROADCAST NOTIFICATIONS DISPATCH ---
  const handleSendBroadcast = async (title: string, message: string, category: "info" | "alert" | "event" | "quest", target: "all" | string) => {
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");
    const newLog: BroadcastLog = {
      id: `bc-${Date.now()}`,
      title,
      message,
      category,
      target,
      created_at: new Date().toISOString()
    };

    const updated = [newLog, ...broadcastLogs];
    setBroadcastLogs(updated);
    localStorage.setItem("emu_broadcast_logs", JSON.stringify(updated));

    await writeAuditLog("SEND_BROADCAST", `Mengirim notifikasi siaran [${category.toUpperCase()}] berjudul: "${title}" ke target: ${target}`);

    if (isLive) {
      try {
        // Broadcast into public.notifications on Supabase / NestJS
        await fetch(`${backendUrl}/notifications/broadcast`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
          },
          body: JSON.stringify({ title, message, category, target })
        });
      } catch (err) {
        console.error("Live broadcast dispatch failed, emulator logic successfully stored log.", err);
      }
    }
    setActionLoading(false);
  };

  // --- HANDLERS: CLEAR AUDIT LOGS ---
  const handleClearAuditLogs = async () => {
    setAuditLogs([]);
    localStorage.setItem("emu_audit_logs", JSON.stringify([]));
    await writeAuditLog("CLEAR_AUDIT", "Berhasil membersihkan seluruh log audit administratif");
  };

  // Summary counts
  const pendingHumanCount = reports.filter(r => r.status === "pending_human").length;

  // Render Loading Screen
  if (loading) {
    return (
      <div className={`min-h-screen w-full flex flex-col justify-center items-center gap-4 ${
        theme === "dark" ? "bg-black text-white" : "bg-surface text-navy-900"
      }`}>
        <div className={`h-10 w-10 rounded-full border-4 animate-spin ${
          theme === "dark" ? "border-zinc-800 border-t-white" : "border-navy-100 border-t-navy-900"
        }`} />
        <span className={`text-xs font-semibold tracking-widest uppercase select-none ${
          theme === "dark" ? "text-slate-500" : "text-navy-500"
        }`}>Memuat dashboard...</span>
      </div>
    );
  }

  return (
    <main className={`min-h-screen w-full flex flex-col md:flex-row overflow-hidden relative font-sans transition-colors duration-300 ${
      theme === "dark"
        ? "bg-black text-slate-100"
        : "bg-[#f8f9fb] text-slate-800"
    }`}>
      
      {/* Ambient lighting */}
      {theme === "dark" ? (
        <>
          <div className="absolute top-0 right-0 h-[500px] w-[500px] rounded-full bg-zinc-800/[0.05] blur-[150px] pointer-events-none" />
          <div className="absolute bottom-0 left-0 h-[500px] w-[500px] rounded-full bg-zinc-900/[0.04] blur-[150px] pointer-events-none" />
        </>
      ) : (
        <>
          <div className="absolute top-0 right-0 h-[450px] w-[450px] rounded-full bg-slate-200/30 blur-[120px] pointer-events-none" />
          <div className="absolute bottom-0 left-0 h-[450px] w-[450px] rounded-full bg-slate-300/20 blur-[120px] pointer-events-none" />
        </>
      )}

      {/* --- SIDEBAR PANEL --- */}
      <Sidebar
        adminName={adminName}
        adminEmail={adminEmail}
        activeTab={activeTab}
        setActiveTab={(tab) => {
          setActiveTab(tab);
          setSelectedReport(null);
          setSelectedProfile(null);
        }}
        isLive={isLive}
        pendingHumanCount={pendingHumanCount}
        handleLogout={handleLogout}
        theme={theme}
        onToggleTheme={handleToggleTheme}
        onToggleMode={handleToggleMode}
      />

      {/* --- MAIN CONTENT CONTAINER --- */}
      <div className="flex-1 flex flex-col overflow-y-auto max-h-screen z-10 p-6 md:p-8">
        
        {/* TAB 1: DASBOR OVERVIEW */}
        {activeTab === "overview" && (
          <OverviewTab
            reports={reports}
            profiles={profiles}
            fetchData={handleTriggerFetch}
            setActiveTab={setActiveTab}
            setSelectedReport={setSelectedReport}
            setSelectedProfile={setSelectedProfile}
            theme={theme}
          />
        )}

        {/* TAB 2: REPORTS MANAGEMENT */}
        {activeTab === "reports" && (
          <ReportsTab
            reports={reports}
            selectedReport={selectedReport}
            setSelectedReport={setSelectedReport}
            reportSearch={reportSearch}
            setReportSearch={setReportSearch}
            reportFilter={reportFilter}
            setReportFilter={setReportFilter}
            adminFeedback={adminFeedback}
            setAdminFeedback={setAdminFeedback}
            handleUpdateReportStatus={handleUpdateReportStatus}
            handleDeleteReport={handleDeleteReport}
            handleBatchAction={handleBatchAction}
            actionLoading={actionLoading}
            loading={loading}
            theme={theme}
          />
        )}

        {/* TAB 3: USER PROFILES CONTROL */}
        {activeTab === "profiles" && (
          <ProfilesTab
            profiles={profiles}
            badges={badges}
            bannedUserIds={bannedUserIds}
            profileSearch={profileSearch}
            setProfileSearch={setProfileSearch}
            selectedProfile={selectedProfile}
            setSelectedProfile={setSelectedProfile}
            isAdjustGamifyOpen={isAdjustGamifyOpen}
            setIsAdjustGamifyOpen={setIsAdjustGamifyOpen}
            adjustXp={adjustXp}
            setAdjustXp={setAdjustXp}
            adjustLevel={adjustLevel}
            setAdjustLevel={setAdjustLevel}
            adjustStreak={adjustStreak}
            setAdjustStreak={setAdjustStreak}
            handleAdjustGamification={handleAdjustGamification}
            isAwardBadgeOpen={isAwardBadgeOpen}
            setIsAwardBadgeOpen={setIsAwardBadgeOpen}
            badgeToAward={badgeToAward}
            setBadgeToAward={setBadgeToAward}
            handleAwardBadge={handleAwardBadge}
            handleRevokeBadge={handleRevokeBadge}
            handleDeleteUserProfile={handleDeleteUserProfile}
            handleToggleBan={handleToggleBan}
            handleCreateBadge={handleCreateBadge}
            handleDeleteBadge={handleDeleteBadge}
            actionLoading={actionLoading}
          />
        )}

        {/* TAB 4: RAG KNOWLEDGE BASE */}
        {activeTab === "rag" && (
          <RagTab
            ragDocs={ragDocs}
            isAddRagOpen={isAddRagOpen}
            setIsAddRagOpen={setIsAddRagOpen}
            ragTitle={ragTitle}
            setRagTitle={setRagTitle}
            ragCategory={ragCategory}
            setRagCategory={setRagCategory}
            ragContent={ragContent}
            setRagContent={setRagContent}
            handleAddRagDoc={handleAddRagDoc}
            handleDeleteRagDoc={handleDeleteRagDoc}
          />
        )}

        {/* TAB 5: GAMIFICATION CHALLENGES CENTER */}
        {activeTab === "challenges" && (
          <ChallengesTab
            challenges={challenges}
            events={events}
            handleAddChallenge={handleAddChallenge}
            handleDeleteChallenge={handleDeleteChallenge}
            handleAddEvent={handleAddEvent}
            handleDeleteEvent={handleDeleteEvent}
            actionLoading={actionLoading}
          />
        )}

        {/* TAB 6: BROADCAST CENTER */}
        {activeTab === "broadcast" && (
          <BroadcastTab
            broadcastLogs={broadcastLogs}
            handleSendBroadcast={handleSendBroadcast}
            actionLoading={actionLoading}
          />
        )}

        {/* TAB 7: ADMINISTRATIVE AUDIT TRAIL LOGS */}
        {activeTab === "audit" && (
          <AuditTab
            auditLogs={auditLogs}
            handleClearAuditLogs={handleClearAuditLogs}
          />
        )}

      </div>

    </main>
  );
}
