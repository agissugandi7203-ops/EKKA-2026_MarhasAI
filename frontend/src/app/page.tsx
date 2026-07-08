"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { useLiquidGlass } from "@/lib/useLiquidGlass";
import { 
  ArrowDown, 
  MapPin, 
  Award, 
  Webhook, 
  ShieldCheck, 
  Flame, 
  Sparkles,
  Lock,
  Mail,
  Eye,
  EyeOff,
  AlertCircle,
  Loader2,
  X,
  Globe,
  Terminal,
  ArrowRight,
  Activity,
  CheckCircle2,
  BookOpen
} from "lucide-react";

export default function Home() {
  const router = useRouter();

  // Apple-style liquid glass refs
  const badgeRef = useLiquidGlass<HTMLDivElement>();
  const learnMoreRef = useLiquidGlass<HTMLAnchorElement>();
  const loginModalCardRef = useLiquidGlass<HTMLDivElement>();

  // Login Modal State
  const [isLoginOpen, setIsLoginOpen] = useState<boolean>(false);
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [loginMode, setLoginMode] = useState<"live" | "simulator">("live");
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [loginLoading, setLoginLoading] = useState<boolean>(false);
  const [loginError, setLoginError] = useState<string | null>(null);

  // Newsletter State
  const [newsletterEmail, setNewsletterEmail] = useState<string>("");
  const [newsletterSubscribed, setNewsletterSubscribed] = useState<boolean>(false);

  const handleNewsletterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newsletterEmail) {
      setNewsletterSubscribed(true);
      setNewsletterEmail("");
      setTimeout(() => setNewsletterSubscribed(false), 4000);
    }
  };

  const handleLoginSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoginLoading(true);
    setLoginError(null);

    if (!email || !password) {
      setLoginError("Email dan password wajib diisi.");
      setLoginLoading(false);
      return;
    }

    try {
      const backendUrl = "https://genesisHub.my.id";

      // 1. SIMULATOR MODE
      if (loginMode === "simulator") {
        const dummyToken = "dummy_admin_jwt_token_2026_val";
        localStorage.setItem("genesis_admin_token", dummyToken);
        localStorage.setItem("genesis_admin_email", email);
        localStorage.setItem("genesis_admin_name", email === "arief@genesis.id" ? "Arief Fajar" : "Genesis Admin");
        localStorage.setItem("genesis_admin_role", "admin");
        localStorage.setItem("genesis_admin_mode", "simulator");
        
        setTimeout(() => {
          setIsLoginOpen(false);
          router.push("/admin");
        }, 800);
        return;
      }

      // 2. LIVE MODE (Direct Supabase Connection)
      const supabaseProjectUrl = "https://uvwkhwryfofnteffrmxe.supabase.co";
      const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2d2tod3J5Zm9mbnRlZmZybXhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxOTUxNTAsImV4cCI6MjA5ODc3MTE1MH0.6eVqtU3A7dsWb9Z1Zn8U0XzL8OT7ixbtOCbJbPHdKAE";
      
      const response = await fetch(`${supabaseProjectUrl}/auth/v1/token?grant_type=password`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "apikey": supabaseAnonKey,
        },
        body: JSON.stringify({ email, password }),
      });

      if (response.ok) {
        const authData = await response.json();
        const token = authData.access_token;

        // Verify admin role via NestJS Profiles API
        const verifyRes = await fetch(`${backendUrl}/profiles/me`, {
          method: "GET",
          headers: {
            "Authorization": `Bearer ${token}`,
            "Accept": "application/json",
          },
        });

        if (verifyRes.ok) {
          const profile = await verifyRes.json();
          if (profile.role === "admin") {
            localStorage.setItem("genesis_admin_token", token);
            localStorage.setItem("genesis_admin_email", email);
            localStorage.setItem("genesis_admin_name", profile.full_name || profile.username || "Admin");
            localStorage.setItem("genesis_admin_role", "admin");
            localStorage.setItem("genesis_admin_mode", "live");
            setIsLoginOpen(false);
            router.push("/admin");
            return;
          } else {
            setLoginError(`Akses Ditolak: Peran akun Anda adalah '${profile.role}'. Hanya akun dengan peran 'admin' yang dapat masuk.`);
          }
        } else {
          setLoginError("Gagal melakukan verifikasi profil peran admin di server backend.");
        }
      } else {
        const errorData = await response.json().catch(() => ({}));
        setLoginError(`Gagal Masuk: ${errorData.error_description || "Email atau kata sandi Anda salah."}`);
      }
    } catch (err: any) {
      console.error("Login error:", err);
      setLoginError("Gagal menghubungi server. Periksa koneksi internet Anda atau coba lagi.");
    } finally {
      setLoginLoading(false);
    }
  };

  return (
    <main className="relative w-full min-h-screen bg-navy-950 flex flex-col font-sans">
      
      {/* 1. Viewport-Height Hero Section */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        {/* Background Loop */}
        <BoomerangVideoBg src="/videos/home.mp4" />
        {/* Dark overlay specifically requested for readability */}
        <div className="absolute inset-0 bg-black/55 z-10 pointer-events-none" />

        {/* Header */}
        <div className="relative z-50">
          <Header onOpenLogin={() => setIsLoginOpen(true)} />
        </div>

        {/* Hero Content */}
        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          {/* Tag badge */}
          <div
            ref={badgeRef}
            className="liquid-glass-dressing rounded-full px-4.5 py-1.5 text-xs text-white animate-fade-up delay-1 mb-6 select-none font-medium uppercase tracking-wider"
          >
            Genesis . Ecological Platform
          </div>

          {/* Headline */}
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.15] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Transform your city.
          </h1>

          {/* Subtext */}
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/85 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Report local issues, earn badges, and help governments build smarter, cleaner communities.
          </p>

          <div className="mt-8 flex flex-col sm:flex-row justify-center items-center w-full sm:w-auto gap-3.5 sm:gap-4 animate-fade-up delay-4">
            <a
              href="https://storage.googleapis.com/arisa-opsi-bucket-2026/app-arm64-v8a-release.apk"
              className="flex items-center gap-2 w-full sm:w-auto rounded-xl bg-white px-7 py-3 text-sm font-semibold text-navy-900 shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center justify-center"
            >
              Download
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a
              ref={learnMoreRef}
              href="#features"
              className="w-full sm:w-auto liquid-glass-dressing rounded-xl px-7 py-3 text-sm font-semibold text-white shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center border-none"
            >
              Learn More
            </a>
          </div>
        </div>

        {/* Bounce Scroll Down Indicator */}
        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 animate-bounce cursor-pointer">
          <a href="#features" aria-label="Scroll down">
            <ArrowDown className="text-white/60 hover:text-white transition-colors h-6 w-6" />
          </a>
        </div>
      </div>

      {/* 2. Features / Showcase Section (Bento Grid 1) */}
      <section
        id="features"
        className="relative w-full bg-[#dde2ef] text-slate-700 py-24 px-4 sm:px-6 md:px-8 flex flex-col items-center justify-center border-t border-slate-300/40 overflow-hidden"
      >
        {/* Ambient background glows */}
        <div className="absolute top-1/4 left-1/4 h-[500px] w-[500px] rounded-full bg-white/20 blur-[130px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 h-[500px] w-[500px] rounded-full bg-white/10 blur-[130px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl w-full mx-auto flex flex-col items-center text-center">
          <span className="text-xs font-bold tracking-widest text-slate-500 uppercase mb-3">
            Core Capabilities
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-light text-slate-900 tracking-tight mb-5">
            Engineered for active citizenship.
          </h2>
          <p className="text-slate-500 max-w-2xl text-sm sm:text-base font-light mb-16 leading-relaxed">
            Genesis combines mobile geotagged inputs with enterprise-grade data analytics to power real-time ecological governance.
          </p>

          {/* Premium Bento Grid Container */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full text-left">
            
            {/* Grid 1: Geotagged Issues & Location Verification (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="absolute top-0 right-0 h-40 w-40 bg-slate-50 rounded-full blur-2xl opacity-50 transition-colors pointer-events-none" />
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-600 border border-slate-100">
                  <MapPin className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Geotagged Issues & Verification</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2 max-w-xl">
                    Citizens report environmental issues instantly. The mobile application automatically validates location metadata via device sensors to prevent false reports and guarantee exact coordination.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2.5 mt-2">
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">GPS Sensor Validation</span>
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">Anti-Spam Shield</span>
              </div>
            </div>

            {/* Grid 2: Gamification (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-600 border border-amber-100">
                  <Award className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">XP & Prestige Badges</h3>
                  <p className="text-slate-500 text-sm font-light leading-relaxed mt-2">
                    Earn Experience Points (XP) for valid reports. Complete daily streaks and earn exclusive badges that showcase ecological governance.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1.5 text-amber-500 font-bold text-sm">
                <Flame className="h-4.5 w-4.5 fill-amber-500" />
                <span>Daily Streak Rewards</span>
              </div>
            </div>

            {/* Grid 3: Secure OpenAPI (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-emerald-50 flex items-center justify-center text-emerald-600 border border-emerald-100">
                  <Webhook className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">B2G OpenAPI Integration</h3>
                  <p className="text-slate-500 text-sm font-light leading-relaxed mt-2">
                    City councils ingest clean, processed spatial data via our secure API. NestJS Fastify handles requests with JWT and Role-Based Guards.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs font-mono text-emerald-600 font-bold">
                <Lock className="h-3.5 w-3.5" />
                <span>JWT & RBAC Protected</span>
              </div>
            </div>

            {/* Grid 4: AI & Vector DB RAG (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="absolute top-0 right-0 h-40 w-40 bg-slate-50 rounded-full blur-2xl opacity-50 transition-colors pointer-events-none" />
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-indigo-50/70 flex items-center justify-center text-indigo-600 border border-indigo-100">
                  <Sparkles className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">AI Assistant & RAG Vector Knowledge Base</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2 max-w-xl">
                    Our AI model auto-classifies waste categories, calculates visual confidence, and checks municipal regulations dynamically using advanced Retrieval-Augmented Generation (RAG) to aid administrator decisions.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2.5 mt-2">
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">RAG Search</span>
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">Visual Confidence AI</span>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 3. Ecosystem & Flow Section (Bento Grid 2) */}
      <section
        id="ecosystem"
        className="relative w-full bg-[#e4e8f3] text-slate-700 py-24 px-4 sm:px-6 md:px-8 flex flex-col items-center justify-center border-t border-slate-300/40 overflow-hidden"
      >
        {/* Glow ambient highlight */}
        <div className="absolute top-1/3 right-1/4 h-[400px] w-[400px] rounded-full bg-white/20 blur-[130px] pointer-events-none" />
        <div className="absolute bottom-1/3 left-1/4 h-[400px] w-[400px] rounded-full bg-indigo-100/20 blur-[130px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl w-full mx-auto flex flex-col items-center text-center">
          <span className="text-xs font-bold tracking-widest text-slate-500 uppercase mb-3">
            Ecosystem Architecture
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-light tracking-tight text-slate-900 mb-5">
            Connected civic coordination.
          </h2>
          <p className="text-slate-600 max-w-2xl text-sm sm:text-base mb-16 leading-relaxed">
            From smart citizen reporting to municipal response coordination, Genesis bridges the communication gap seamlessly.
          </p>

          {/* Premium Bento Grid Container 2 */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full text-left">
            
            {/* Box 1 (Col span 1): Real-time Platform Metrics */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-600 border border-slate-100">
                  <Activity className="h-5 w-5 text-emerald-500 animate-pulse" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Live Operations Status</h3>
                  <p className="text-slate-500 text-sm font-light leading-relaxed mt-2">
                    Ensuring high performance and constant availability across our microservices architecture.
                  </p>
                </div>
              </div>
              <div className="flex flex-col gap-2 bg-slate-100 p-4 rounded-2xl border border-slate-200">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-500">API Response</span>
                  <span className="font-mono text-emerald-650 font-bold">120ms avg</span>
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-500">RAG Vector Classification</span>
                  <span className="font-mono text-emerald-655 font-bold">1.2s avg</span>
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-500">GPS Validation Precision</span>
                  <span className="font-mono text-emerald-655 font-bold">99.98%</span>
                </div>
              </div>
            </div>

            {/* Box 2 (Col span 2): Process Workflow Roadmap */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="absolute top-0 right-0 h-40 w-40 bg-slate-50 rounded-full blur-2xl opacity-50 pointer-events-none" />
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-indigo-50/50 flex items-center justify-center text-indigo-650 border border-indigo-100">
                  <CheckCircle2 className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Governance Coordination Cycle</h3>
                  <p className="text-slate-500 text-sm font-light leading-relaxed mt-2">
                    A cyclic process flow engineered to create accountability and maximize environmental resolution rates.
                  </p>
                </div>
              </div>
              
              {/* Timeline Steps Layout */}
              <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 mt-2">
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <div className="text-[10px] font-bold text-indigo-655 uppercase tracking-widest">01. Report</div>
                  <div className="text-[11px] text-slate-500 font-light mt-1">Geotagged mobile input upload.</div>
                </div>
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <div className="text-[10px] font-bold text-indigo-655 uppercase tracking-widest">02. Verify</div>
                  <div className="text-[11px] text-slate-500 font-light mt-1">AI RAG & administrative validation.</div>
                </div>
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <div className="text-[10px] font-bold text-indigo-655 uppercase tracking-widest">03. Resolve</div>
                  <div className="text-[11px] text-slate-500 font-light mt-1">Municipal action & status update.</div>
                </div>
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <div className="text-[10px] font-bold text-indigo-655 uppercase tracking-widest">04. Reward</div>
                  <div className="text-[11px] text-slate-500 font-light mt-1">Citizens receive level XP & badges.</div>
                </div>
              </div>
            </div>

            {/* Box 3 (Col span 2): B2G Developer Code block IDE */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-emerald-50 flex items-center justify-center text-emerald-600 border border-emerald-100">
                  <Terminal className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Developer OpenAPI Core</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2 max-w-xl">
                    Integrate spatial data feeds directly into government ERPs. Simple REST endpoints secured with strict Bearer JWT auth.
                  </p>
                </div>
              </div>
              
              {/* Code Mockup */}
              <div className="bg-slate-950 rounded-2xl p-4 border border-zinc-850/80 font-mono text-[11px] text-slate-400 select-text">
                <div className="flex items-center justify-between border-b border-zinc-900 pb-2 mb-2.5 text-slate-500">
                  <span>GET /reports/active</span>
                  <span className="text-[9px] bg-zinc-900 px-2 py-0.5 rounded text-emerald-400">200 OK</span>
                </div>
                <div className="text-emerald-400">curl <span className="text-slate-400">-H</span> &quot;Authorization: Bearer JWT_TOKEN&quot; \</div>
                <div className="pl-6 text-slate-400">https://genesisHub.my.id/reports?status=pending</div>
              </div>
            </div>

            {/* Box 4 (Col span 1): Enterprise Governance Access Control */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-700 border border-slate-100">
                  <BookOpen className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Access Safeguards</h3>
                  <p className="text-slate-500 text-sm font-light leading-relaxed mt-2">
                    Role-Based Access Control limits dashboard modification rights strictly to verified municipal officers.
                  </p>
                </div>
              </div>
              <div className="flex items-center justify-between text-xs text-slate-500 font-bold border-t border-slate-100 pt-4">
                <span>API Status Gateway</span>
                <span className="flex items-center gap-1.5 text-emerald-600 text-[10px]">
                  <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  ONLINE
                </span>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 4. New Premium SaaS-Standard Footer Section */}
      <Footer />
      {isLoginOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 select-none">
          {/* Backdrop blur */}
          <div 
            onClick={() => setIsLoginOpen(false)}
            className="absolute inset-0 bg-black/60 backdrop-blur-md transition-opacity duration-300 animate-fade-in"
          />

          {/* Modal Container Card */}
          <div className="relative w-full max-w-[420px] z-10 animate-fade-up">
            {/* Shadow glow base */}
            <div className="absolute -inset-1 bg-gradient-to-r from-amber-500/10 to-indigo-500/10 rounded-[32px] blur-lg opacity-40 pointer-events-none" />

            <div ref={loginModalCardRef} className="liquid-glass-dressing rounded-[28px] p-8 relative overflow-hidden">
              
              {/* Top subtle highlight */}
              <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-amber-500 to-indigo-500" />

              {/* Close Button */}
              <button 
                onClick={() => setIsLoginOpen(false)}
                className="absolute top-4 right-4 p-2 rounded-xl border border-white/10 hover:bg-white/5 text-slate-400 hover:text-white transition-colors cursor-pointer"
                title="Close"
              >
                <X className="h-4.5 w-4.5" />
              </button>
              
              {/* Brand Logo & Heading */}
              <div className="flex flex-col items-center text-center mb-6 select-none mt-2">
                <div className="h-14 w-14 rounded-2xl bg-white/5 flex items-center justify-center border border-white/10 shadow-sm mb-3.5">
                  <img src="/logo.png" alt="Genesis Logo" className="h-9 w-auto object-contain" />
                </div>
                <h1 className="text-lg font-bold text-white tracking-tight flex items-center gap-1.5">
                  Genesis Admin <Sparkles className="h-4 w-4 text-amber-500 shrink-0 fill-amber-500" />
                </h1>
                <p className="text-[11px] text-slate-400 font-light mt-1 max-w-xs leading-relaxed">
                  Consolidated control portal and ecological governance console.
                </p>
              </div>

              {/* Alert Error Box */}
              {loginError && (
                <div className="mb-5 flex items-start gap-2 p-3 rounded-xl bg-red-950/20 border border-red-900/30 text-red-400 text-xs animate-fade-up font-medium">
                  <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
                  <span className="leading-relaxed">{loginError}</span>
                </div>
              )}

              {/* Mode Switcher */}
              <div className="flex p-1 bg-white/5 border border-white/10 rounded-xl mb-5">
                <button
                  type="button"
                  onClick={() => {
                    setLoginMode("live");
                    setLoginError(null);
                  }}
                  className={`flex-1 flex items-center justify-center gap-1.5 py-2 text-xs font-semibold rounded-lg transition-all duration-200 cursor-pointer ${
                    loginMode === "live"
                      ? "bg-white/10 text-white shadow-sm border border-white/15"
                      : "text-slate-400 hover:text-slate-200"
                  }`}
                >
                  <span className={`h-1.5 w-1.5 rounded-full ${loginMode === "live" ? "bg-emerald-500 animate-pulse" : "bg-slate-300"}`} />
                  Live Mode
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setLoginMode("simulator");
                    setLoginError(null);
                  }}
                  className={`flex-1 flex items-center justify-center gap-1.5 py-2 text-xs font-semibold rounded-lg transition-all duration-200 cursor-pointer ${
                    loginMode === "simulator"
                      ? "bg-white/10 text-white shadow-sm border border-white/15"
                      : "text-slate-400 hover:text-slate-200"
                  }`}
                >
                  <span className={`h-1.5 w-1.5 rounded-full ${loginMode === "simulator" ? "bg-amber-500 animate-pulse" : "bg-slate-300"}`} />
                  Simulator
                </button>
              </div>

              {/* Form */}
              <form onSubmit={handleLoginSubmit} className="flex flex-col gap-4">
                {/* Email field */}
                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-bold uppercase tracking-wider text-slate-300 pl-1 select-none">
                    Email
                  </label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-500">
                      <Mail className="h-4 w-4" />
                    </div>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="admin@genesis.id"
                      className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-9 pr-4 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-all duration-150"
                      required
                    />
                  </div>
                </div>

                {/* Password field */}
                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-bold uppercase tracking-wider text-slate-300 pl-1 select-none">
                    Password
                  </label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-500">
                      <Lock className="h-4 w-4" />
                    </div>
                    <input
                      type={showPassword ? "text" : "password"}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-9 pr-9 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-all duration-150"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-500 hover:text-slate-200 transition-colors cursor-pointer"
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                </div>

                {/* Action submit button */}
                <button
                  type="submit"
                  disabled={loginLoading}
                  className={`mt-3 w-full rounded-xl py-2.5 text-xs font-semibold transition-all duration-200 cursor-pointer disabled:opacity-50 flex items-center justify-center gap-2 select-none ${
                    loginMode === "live" 
                      ? "bg-white text-navy-950 hover:bg-slate-100 hover:shadow-lg hover:shadow-white/10" 
                      : "bg-slate-800 text-white hover:bg-slate-700 hover:shadow-lg hover:shadow-slate-800/10"
                  }`}
                >
                  {loginLoading ? (
                    <>
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                      Membuka Otoritas Admin...
                    </>
                  ) : (
                    loginMode === "live" ? "Masuk Otoritas Live" : "Masuk Otoritas Simulator"
                  )}
                </button>
              </form>

            </div>
          </div>
        </div>
      )}

    </main>
  );
}
