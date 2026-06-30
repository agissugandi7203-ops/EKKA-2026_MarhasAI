"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ShieldCheck, Mail, Lock, Eye, EyeOff, AlertCircle, ArrowLeft, Terminal } from "lucide-react";

export default function AdminLogin() {
  const router = useRouter();

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

    if (!email || !password) {
      setError("Email dan password wajib diisi.");
      setLoading(false);
      return;
    }

    try {
      const backendUrl = "https://genesisHub.my.id";

      // SIMULATOR MODE
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

      // LIVE MODE (Direct Supabase Connection)
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
    } catch (err: unknown) {
      console.error("Login error:", err);
      setError("Gagal menghubungi server. Periksa koneksi internet Anda atau coba lagi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative min-h-screen w-full flex bg-navy-950 overflow-hidden">
      {/* ═══════════ LEFT PANEL — Branding ═══════════ */}
      <div className="hidden lg:flex lg:w-1/2 relative flex-col justify-between p-12 overflow-hidden">
        {/* Ambient glows */}
        <div className="absolute top-1/4 left-1/4 h-[500px] w-[500px] rounded-full bg-indigo-900/20 blur-[150px] pointer-events-none" />
        <div className="absolute bottom-0 right-0 h-[400px] w-[400px] rounded-full bg-violet-900/15 blur-[120px] pointer-events-none" />

        {/* Top — Back link */}
        <Link
          href="/"
          className="relative z-10 flex items-center gap-2 text-sm text-white/40 hover:text-white/80 font-medium transition-colors duration-200 w-fit"
        >
          <ArrowLeft className="h-4 w-4" />
          Kembali ke Beranda
        </Link>

        {/* Center — Logo & tagline */}
        <div className="relative z-10 flex flex-col gap-6">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 shadow-lg">
              <ShieldCheck className="h-6 w-6 text-white" />
            </div>
            <span className="text-2xl font-bold text-white tracking-tight">
              Genesis<span className="text-indigo-400">.id</span>
            </span>
          </div>
          <h2 className="text-4xl xl:text-5xl font-light text-white tracking-tight leading-[1.15]">
            Control center for<br />
            <span className="text-indigo-400">smart city</span> governance.
          </h2>
          <p className="text-white/40 text-sm font-light max-w-md leading-relaxed">
            Dashboard administratif dengan moderasi laporan real-time, analytics geospasial, dan manajemen gamifikasi warga.
          </p>
        </div>

        {/* Bottom — Stats */}
        <div className="relative z-10 flex gap-8">
          {[
            { value: "~45k", label: "req/s throughput" },
            { value: "RBAC", label: "Role-based access" },
            { value: "E2E", label: "JWT encrypted" },
          ].map((stat) => (
            <div key={stat.label}>
              <p className="text-lg font-semibold text-white">{stat.value}</p>
              <p className="text-xs text-white/30">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ═══════════ RIGHT PANEL — Form ═══════════ */}
      <div className="w-full lg:w-1/2 flex flex-col justify-center items-center px-4 sm:px-8 lg:px-16 bg-surface relative">
        {/* Mobile-only back button */}
        <div className="absolute top-6 left-6 z-50 lg:hidden">
          <Link
            href="/"
            className="flex items-center gap-2 text-sm text-navy-500 hover:text-navy-900 font-semibold transition-colors duration-200"
          >
            <ArrowLeft className="h-4 w-4" />
            Kembali
          </Link>
        </div>

        {/* Mobile-only branded header */}
        <div className="lg:hidden flex flex-col items-center text-center mb-8 mt-16">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 shadow-lg mb-3">
            <ShieldCheck className="h-6 w-6 text-white" />
          </div>
          <span className="text-xl font-bold text-navy-900 tracking-tight">
            Genesis<span className="text-indigo-500">.id</span> Admin
          </span>
        </div>

        <div className="w-full max-w-md animate-fade-up">
          {/* Heading — desktop only */}
          <div className="hidden lg:block mb-8">
            <h1 className="text-2xl font-bold text-navy-900 tracking-tight">
              Admin Portal
            </h1>
            <p className="text-sm text-navy-500 font-light mt-1.5">
              Masuk untuk mengakses dashboard pengelolaan kota ekologis
            </p>
          </div>

          {/* Alert Error Box */}
          {error && (
            <div className="mb-6 flex items-start gap-2.5 p-3.5 rounded-xl bg-burgundy-50 border border-burgundy-100 text-burgundy-700 text-xs animate-fade-up">
              <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
              <span className="leading-normal font-medium">{error}</span>
            </div>
          )}

          {/* Mode Switcher */}
          <div className="flex p-1.5 bg-navy-50/70 border border-navy-100 rounded-2xl mb-6">
            <button
              type="button"
              onClick={() => { setLoginMode("live"); setError(null); }}
              className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold rounded-xl transition-all duration-300 cursor-pointer ${
                loginMode === "live"
                  ? "bg-white text-navy-900 shadow-sm border border-navy-100/30"
                  : "text-navy-400 hover:text-navy-700"
              }`}
            >
              <span className={`h-2 w-2 rounded-full ${loginMode === "live" ? "bg-emerald-500 animate-pulse" : "bg-navy-300"}`} />
              Koneksi Live
            </button>
            <button
              type="button"
              onClick={() => { setLoginMode("simulator"); setError(null); }}
              className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold rounded-xl transition-all duration-300 cursor-pointer ${
                loginMode === "simulator"
                  ? "bg-white text-navy-900 shadow-sm border border-navy-100/30"
                  : "text-navy-400 hover:text-navy-700"
              }`}
            >
              <span className={`h-2 w-2 rounded-full ${loginMode === "simulator" ? "bg-gold animate-pulse" : "bg-navy-300"}`} />
              Simulator
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleLogin} className="flex flex-col gap-5">
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

            <button
              type="submit"
              disabled={loading}
              className={`mt-2 w-full rounded-xl text-white py-2.5 text-sm font-semibold shadow-md hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 cursor-pointer disabled:opacity-50 disabled:scale-100 flex items-center justify-center gap-2 select-none ${
                loginMode === "live" ? "bg-navy-900 hover:bg-navy-850" : "bg-gold hover:bg-gold/90 text-navy-900"
              }`}
            >
              {loading ? (
                <>
                  <div className={`h-4 w-4 rounded-full border-2 border-t-transparent animate-spin ${loginMode === "live" ? "border-white" : "border-navy-900"}`} />
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
