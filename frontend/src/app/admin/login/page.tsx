"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Mail, Lock, Eye, EyeOff, AlertCircle, ArrowLeft, Loader2, Sparkles } from "lucide-react";
import { useLiquidGlass } from "@/lib/useLiquidGlass";

export default function AdminLogin() {
  const router = useRouter();
  const glassRef = useLiquidGlass<HTMLDivElement>();
  
  // State variables with strict types
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [loginMode, setLoginMode] = useState<"live" | "simulator">("live");
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    // Basic Validation
    if (!email || !password) {
      setError("Email dan password wajib diisi.");
      setLoading(false);
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
            router.push("/admin");
            return;
          } else {
            setError(`Akses Ditolak: Peran akun Anda adalah '${profile.role}'. Hanya akun dengan peran 'admin' yang dapat masuk.`);
          }
        } else {
          setError("Gagal melakukan verifikasi profil peran admin di server backend.");
        }
      } else {
        const errorData = await response.json().catch(() => ({}));
        setError(`Gagal Masuk: ${errorData.error_description || "Email atau kata sandi Anda salah."}`);
      }
    } catch (err: any) {
      console.error("Login error:", err);
      setError("Gagal menghubungi server. Periksa koneksi internet Anda atau coba lagi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative min-h-screen w-full bg-navy-950 flex flex-col justify-center items-center px-4 overflow-hidden font-sans">
      
      {/* Premium Subtle Ambient Gradients */}
      <div className="absolute top-0 right-0 h-[600px] w-[600px] rounded-full bg-amber-500/10 blur-[140px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 h-[600px] w-[600px] rounded-full bg-indigo-500/15 blur-[140px] pointer-events-none" />
      
      {/* Decorative Grid Overlay */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)] opacity-40 pointer-events-none" />

      {/* Back button */}
      <div className="absolute top-6 left-6 z-50">
        <Link 
          href="/" 
          className="flex items-center gap-2 text-xs font-semibold text-slate-400 hover:text-white transition-colors duration-200"
        >
          <ArrowLeft className="h-4 w-4" />
          Beranda
        </Link>
      </div>

      {/* Login Card Container */}
      <div className="relative w-full max-w-[420px] z-10 animate-fade-up">
        
        {/* Shadow glow base */}
        <div className="absolute -inset-1 bg-gradient-to-r from-amber-500/10 to-indigo-500/10 rounded-[32px] blur-lg opacity-40 pointer-events-none" />

        <div ref={glassRef} className="liquid-glass-dressing rounded-[28px] p-8 relative overflow-hidden">
          
          {/* Top subtle highlight */}
          <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-amber-500 to-indigo-500" />
          
          {/* Brand Logo & Heading */}
          <div className="flex flex-col items-center text-center mb-8 select-none">
            <div className="h-16 w-16 rounded-2xl bg-white/5 flex items-center justify-center border border-white/10 shadow-sm mb-4">
              <img src="/logo.png" alt="Genesis Logo" className="h-10 w-auto object-contain" />
            </div>
            <h1 className="text-xl font-bold text-white tracking-tight flex items-center gap-1.5">
              Genesis Admin <Sparkles className="h-4 w-4 text-amber-500 shrink-0 fill-amber-500" />
            </h1>
            <p className="text-xs text-slate-400 font-light mt-1 max-w-xs leading-relaxed">
              Consolidated control portal and ecological governance console.
            </p>
          </div>

          {/* Alert Error Box */}
          {error && (
            <div className="mb-6 flex items-start gap-2.5 p-3.5 rounded-xl bg-red-950/20 border border-red-900/30 text-red-400 text-xs animate-fade-up font-medium">
              <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
              <span className="leading-relaxed">{error}</span>
            </div>
          )}

          {/* Mode Switcher */}
          <div className="flex p-1 bg-white/5 border border-white/10 rounded-xl mb-6">
            <button
              type="button"
              onClick={() => {
                setLoginMode("live");
                setError(null);
              }}
              className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold rounded-lg transition-all duration-200 cursor-pointer ${
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
                setError(null);
              }}
              className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold rounded-lg transition-all duration-200 cursor-pointer ${
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
          <form onSubmit={handleLogin} className="flex flex-col gap-4">
            {/* Email field */}
            <div className="flex flex-col gap-1.5">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-300 pl-1 select-none">
                Email
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-500">
                  <Mail className="h-4 w-4" />
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@genesis.id"
                  className="w-full bg-white/5 border border-white/10 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-all duration-150"
                  required
                />
              </div>
            </div>

            {/* Password field */}
            <div className="flex flex-col gap-1.5">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-300 pl-1 select-none">
                Password
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-500">
                  <Lock className="h-4 w-4" />
                </div>
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full bg-white/5 border border-white/10 rounded-xl py-2.5 pl-10 pr-10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-all duration-150"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-500 hover:text-slate-200 transition-colors cursor-pointer"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4.5 w-4.5" />}
                </button>
              </div>
            </div>

            {/* Action submit button */}
            <button
              type="submit"
              disabled={loading}
              className={`mt-4 w-full rounded-xl py-3 text-sm font-semibold transition-all duration-200 cursor-pointer disabled:opacity-50 flex items-center justify-center gap-2 select-none ${
                loginMode === "live" 
                  ? "bg-white text-navy-950 hover:bg-slate-100 hover:shadow-lg hover:shadow-white/10" 
                  : "bg-slate-800 text-white hover:bg-slate-700 hover:shadow-lg hover:shadow-slate-800/10"
              }`}
            >
              {loading ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Membuka Otoritas Admin...
                </>
              ) : (
                loginMode === "live" ? "Masuk Otoritas Live" : "Masuk Otoritas Simulator"
              )}
            </button>
          </form>

        </div>
      </div>
    </main>
  );
}
