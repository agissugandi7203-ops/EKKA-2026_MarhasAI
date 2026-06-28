"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ShieldCheck, Mail, Lock, Eye, EyeOff, AlertCircle, ArrowLeft, Terminal } from "lucide-react";

export default function AdminLogin() {
  const router = useRouter();
  
  // State variables with strict types
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
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

      if (
        (email === "admin@genesis.id" && password === "admin123") || 
        (email === "arief@genesis.id" && password === "arief123")
      ) {
        // Dummy credentials
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

      // Live authentication
      const supabaseProjectUrl = "https://abmypsvfuplxmyblerhv.supabase.co";
      const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFibXlwc3ZmdXBseG15Ymxlcmh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxOTM1MTUsImV4cCI6MjA5Nzc2OTUxNX0.PmBk7SfG_uIR2fnVER__qvK3zr4X2IByLNXTNfd5c4A";
      
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
            setError("Akses Ditolak: Akun Anda tidak memiliki peran 'admin'.");
          }
        } else {
          setError("Gagal melakukan verifikasi profil peran admin di server.");
        }
      } else {
        setError("Kredensial salah atau Supabase offline. Silakan gunakan Akun Uji Coba: admin@genesis.id / admin123");
      }
    } catch (err: any) {
      console.error("Login error:", err);
      setError("Gagal menghubungi server. Anda dapat login dengan akun demo: admin@genesis.id / admin123");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative min-h-screen w-full bg-surface flex flex-col justify-center items-center px-4 overflow-hidden font-sans">
      
      {/* Decorative Warm Cream and Indigo ambient blobs */}
      <div className="absolute top-1/4 left-1/4 h-[400px] w-[400px] rounded-full bg-gold/5 blur-[100px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 h-[400px] w-[400px] rounded-full bg-navy-500/5 blur-[100px] pointer-events-none" />

      {/* Back button */}
      <div className="absolute top-6 left-6 z-50">
        <Link 
          href="/" 
          className="flex items-center gap-2 text-sm text-navy-500 hover:text-navy-900 font-semibold transition-colors duration-200"
        >
          <ArrowLeft className="h-4 w-4" />
          Kembali ke Beranda
        </Link>
      </div>

      {/* Login Card */}
      <div className="relative w-full max-w-md z-10 animate-fade-up">
        
        {/* Glow accent */}
        <div className="absolute inset-0 bg-gradient-to-tr from-gold/5 to-navy-500/5 rounded-3xl blur-xl opacity-60 pointer-events-none" />

        <div className="bg-white rounded-3xl p-8 border border-navy-100 shadow-[0_20px_50px_rgba(10,22,40,0.035)]">
          
          {/* Brand Logo & Heading */}
          <div className="flex flex-col items-center text-center mb-8 select-none">
            <div className="h-14 w-14 rounded-2xl bg-navy-50 flex items-center justify-center border border-navy-100 shadow-sm mb-4">
              <ShieldCheck className="h-8 w-8 text-navy-900" />
            </div>
            <h1 className="text-2xl font-bold text-navy-900 tracking-tight">
              Genesis.id Admin
            </h1>
            <p className="text-xs text-navy-500 font-light mt-1.5 max-w-xs leading-normal">
              Portal Keamanan Terpadu & Kontrol Absolut Kota Ekologis
            </p>
          </div>

          {/* Alert Error Box */}
          {error && (
            <div className="mb-6 flex items-start gap-2.5 p-3.5 rounded-xl bg-burgundy-50 border border-burgundy-100 text-burgundy-700 text-xs animate-fade-up">
              <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
              <span className="leading-normal font-medium">{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleLogin} className="flex flex-col gap-5">
            {/* Email field */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-navy-600 pl-1 select-none">
                Email Administrator
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-navy-400">
                  <Mail className="h-4.5 w-4.5" />
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@genesis.id"
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2.5 pl-10 pr-4 text-sm text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-white transition-all duration-200"
                  required
                />
              </div>
            </div>

            {/* Password field */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-navy-600 pl-1 select-none">
                Kata Sandi
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-navy-400">
                  <Lock className="h-4.5 w-4.5" />
                </div>
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full bg-navy-50/50 border border-navy-100 rounded-xl py-2.5 pl-10 pr-10 text-sm text-navy-900 placeholder-navy-400 focus:outline-none focus:border-navy-300 focus:bg-white transition-all duration-200"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-navy-400 hover:text-navy-900 transition-colors cursor-pointer"
                >
                  {showPassword ? <EyeOff className="h-4.5 w-4.5" /> : <Eye className="h-4.5 w-4.5" />}
                </button>
              </div>
            </div>

            {/* Action submit button */}
            <button
              type="submit"
              disabled={loading}
              className="mt-2 w-full rounded-xl bg-navy-900 hover:bg-navy-800 text-white py-2.5 text-sm font-semibold shadow-md hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 cursor-pointer disabled:opacity-50 disabled:scale-100 flex items-center justify-center gap-2 select-none"
            >
              {loading ? (
                <>
                  <div className="h-4 w-4 rounded-full border-2 border-white border-t-transparent animate-spin" />
                  Membuka Otoritas Admin...
                </>
              ) : (
                "Masuk Otoritas Admin"
              )}
            </button>
          </form>

          {/* Dummy account notice */}
          <div className="mt-8 pt-6 border-t border-navy-50">
            <div className="bg-navy-50 rounded-xl p-3.5 border border-navy-100 flex flex-col gap-1 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)]">
              <div className="flex items-center gap-1.5 text-navy-500 text-[10px] uppercase tracking-wider font-bold select-none">
                <Terminal className="h-3 w-3 text-gold" />
                Akun Demo Pengembang
              </div>
              <div className="text-[11px] text-navy-700 font-mono mt-1.5 flex flex-col gap-0.5">
                <div>Email: <span className="text-navy-900 font-semibold">admin@genesis.id</span></div>
                <div>Sandi: <span className="text-navy-900 font-semibold">admin123</span></div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </main>
  );
}
