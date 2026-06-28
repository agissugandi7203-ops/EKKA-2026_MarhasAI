"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";

// Sub-components
import Sidebar from "./components/Sidebar";
import OverviewTab, { TrashReport, UserProfile } from "./components/OverviewTab";
import ReportsTab from "./components/ReportsTab";
import ProfilesTab from "./components/ProfilesTab";
import RagTab from "./components/RagTab";

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
  const [ragTitle, setRagTitle] = useState<string>("");
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
      // Offline/Simulator Emulator Mode
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

      // 1. Profiles
      const profilesRes = await fetch(`${backendUrl}/profiles`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const profilesData = profilesRes.ok ? await profilesRes.json() : mockProfiles;

      // 2. Reports
      const reportsRes = await fetch(`${backendUrl}/reports`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const reportsData = reportsRes.ok ? await reportsRes.json() : mockReports;

      // 3. Badges
      const badgesRes = await fetch(`${backendUrl}/badges`, {
        headers: { "Authorization": `Bearer ${token}` }
      });
      const badgesData = badgesRes.ok ? await badgesRes.json() : mockBadges;

      // 4. RAG / Knowledge Base
      let ragDocsData: RAGDocument[] = [];
      try {
        const ragRes = await fetch(`${backendUrl}/knowledge-base`, {
          headers: { "Authorization": `Bearer ${token}` }
        });
        if (ragRes.ok) {
          const rawRag = await ragRes.json();
          if (Array.isArray(rawRag)) {
            ragDocsData = rawRag.map((r: any) => ({
              id: r.id || "",
              title: r.title || "",
              category: r.metadata?.category || "Regulasi",
              charCount: r.content ? r.content.length : 0,
              createdAt: r.created_at ? new Date(r.created_at).toISOString().split("T")[0] : ""
            }));
          }
        }
      } catch (ragErr) {
        console.error("Failed to load live RAG docs:", ragErr);
      }

      setProfiles(Array.isArray(profilesData) ? profilesData : mockProfiles);
      setReports(Array.isArray(reportsData) ? reportsData : mockReports);
      setBadges(Array.isArray(badgesData) ? badgesData : mockBadges);
      setRagDocs(ragDocsData.length > 0 ? ragDocsData : mockRagDocs);

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
    router.push("/admin/login");
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

      setSelectedReport(null);
      setAdminFeedback("");
      setActionLoading(false);
      return;
    }

    // Live API update
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
      // Local simulator update
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
      setIsAwardBadgeOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API award
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
      setActionLoading(false);
      return;
    }

    // Live API revoke
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
      // Local emulator delete
      const updated = profiles.filter(p => p.id !== profileId);
      setProfiles(updated);
      localStorage.setItem("emu_profiles", JSON.stringify(updated));
      setActionLoading(false);
      return;
    }

    // Live API delete
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
  const handleAddRagDoc = async () => {
    if (!ragTitle || !ragContent) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local emulator add
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
      setIsAddRagOpen(false);
      setActionLoading(false);
      return;
    }

    // Live API Add
    try {
      const backendUrl = "https://genesisHub.my.id";
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
        // Refetch all live data (including the new RAG doc)
        fetchData(true, token || "");
        setRagTitle("");
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
    if (!confirm("Apakah Anda yakin ingin menghapus dokumen RAG ini dari basis pengetahuan AI?")) return;
    setActionLoading(true);
    const token = localStorage.getItem("genesis_admin_token");

    if (!isLive) {
      // Local emulator delete
      const updated = ragDocs.filter(d => d.id !== id);
      setRagDocs(updated);
      localStorage.setItem("emu_rag_docs", JSON.stringify(updated));
      setActionLoading(false);
      return;
    }

    // Live API delete
    try {
      const backendUrl = "https://genesisHub.my.id";
      const res = await fetch(`${backendUrl}/knowledge-base/${id}`, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
      });

      if (res.ok) {
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

  // Summary counts
  const pendingHumanCount = reports.filter(r => r.status === "pending_human").length;

  // Render Loading Screen (Soft Light Neutral Spinner)
  if (loading) {
    return (
      <div className="min-h-screen w-full bg-surface flex flex-col justify-center items-center gap-4 text-navy-900">
        <div className="h-10 w-10 rounded-full border-4 border-navy-100 border-t-navy-900 animate-spin" />
        <span className="text-xs font-bold tracking-widest text-navy-500 uppercase">Mengotorisasi Portal Kontrol Absolut...</span>
      </div>
    );
  }

  return (
    <main className="min-h-screen w-full bg-surface text-navy-900 flex flex-col md:flex-row overflow-hidden relative font-sans">
      
      {/* Decorative ambient lighting - soft light warm cream highlights */}
      <div className="absolute top-0 right-0 h-[450px] w-[450px] rounded-full bg-gold/5 blur-[120px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 h-[450px] w-[450px] rounded-full bg-navy-500/5 blur-[120px] pointer-events-none" />

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
            actionLoading={actionLoading}
            loading={loading}
          />
        )}

        {/* TAB 3: USER PROFILES CONTROL */}
        {activeTab === "profiles" && (
          <ProfilesTab
            profiles={profiles}
            badges={badges}
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

      </div>

    </main>
  );
}
