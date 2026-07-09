"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Mail, Lock, Eye, EyeOff, AlertCircle, Loader2, Sparkles } from "lucide-react";
import { useLiquidGlass } from "@/lib/useLiquidGlass";

interface AdminLoginFormProps {
  onClose?: () => void;
}

export default function AdminLoginForm({ onClose }: AdminLoginFormProps) {
  const router = useRouter();
  const glassRef = useLiquidGlass<HTMLDivElement>();

  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [loginMode, setLoginMode] = useState<"live" | "simulator">("live");
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [loginLoading, setLoginLoading] = useState<boolean>(false);
  const [loginError, setLoginError] = useState<string | null>(null);

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
          if (onClose) onClose();
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
            if (onClose) onClose();
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
    <div ref={glassRef} className="liquid-glass-dressing rounded-[28px] p-8 relative overflow-hidden w-full">
      
      {/* Top subtle highlight */}
      <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-amber-500 to-indigo-500" />

      {/* Close Button */}
      {onClose && (
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-xl border border-white/10 hover:bg-white/5 text-slate-400 hover:text-white transition-colors cursor-pointer"
          title="Close"
        >
          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      )}
      
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
  );
}
