"use client";

import React from "react";
import dynamic from "next/dynamic";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import AnimatedContent from "@/components/reactbits/AnimatedContent";
import GlareHover from "@/components/reactbits/GlareHover";
import {
  ShieldCheck, ArrowRight, Users, Building2, Code2,
  Droplets, Package, ShoppingBag, Gift, Ticket,
  Smartphone, Server, Database, Brain, Eye, MessageSquare
} from "lucide-react";

const ScrollFloat = dynamic(() => import("@/components/reactbits/ScrollFloat"), { ssr: false });
const ScrollReveal = dynamic(() => import("@/components/reactbits/ScrollReveal"), { ssr: false });
const CardSwap = dynamic(() => import("@/components/reactbits/CardSwap"), { ssr: false });

const APK_URL = "https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk";

export default function Solutions() {
  return (
    <main className="relative w-full min-h-screen bg-surface flex flex-col">
      {/* ═══════════ HERO ═══════════ */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/solutions.mp4" />
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />

        <div className="relative z-50">
          <Header />
        </div>

        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none" style={{ background: "rgba(255, 255, 255, 0.16)" }}>
            Solutions · Eco-Tech
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Smart solutions for modern cities.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Discover how Genesis.id solves urban ecological challenges through data-driven technology.
          </p>

          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row-reverse items-center justify-center gap-4 animate-fade-up delay-4">
            <a href={APK_URL} className="flex items-center gap-2 rounded-xl bg-white px-6 py-3 text-sm font-semibold text-navy-900 shadow-xl shadow-white/10 hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none">
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a href="#use-cases" className="flex items-center gap-2 rounded-xl liquid-glass px-6 py-3 text-sm font-medium text-white hover:bg-white/10 border border-white/20 hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer select-none">
              Explore Solutions
              <ArrowRight className="h-4.5 w-4.5" />
            </a>
          </div>
        </div>
      </div>

      {/* ═══════════ USE CASES ═══════════ */}
      <section id="use-cases" className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 border-t border-navy-100 overflow-hidden">
        <div className="absolute top-0 left-1/3 h-[500px] w-[500px] rounded-full bg-indigo-100/50 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-indigo-600 uppercase mb-3 block">Use Cases</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Solusi untuk Setiap Peran
            </ScrollFloat>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-5 gap-12 items-center">
            {/* Left Column - Description */}
            <div className="lg:col-span-2 space-y-6">
              <span className="text-xs font-semibold tracking-widest text-indigo-600 uppercase block">Collaborative Roles</span>
              <h3 className="text-2xl sm:text-3xl font-light text-navy-900 leading-tight">
                Kolaborasi Tiga Aktor Utama
              </h3>
              <p className="text-navy-700 text-sm sm:text-base font-light leading-relaxed">
                Platform Genesis.id menghubungkan Warga, Pemerintah Kota, dan Developer dalam satu ekosistem digital untuk pengelolaan kota yang transparan dan efisien.
              </p>
              <div className="pt-4 border-t border-navy-100 flex flex-col gap-3">
                <div className="flex items-center gap-2 text-xs font-semibold text-navy-500">
                  <span className="h-1.5 w-1.5 rounded-full bg-violet-600" />
                  Warga: Pelapor aktif & penerima reward
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-navy-500">
                  <span className="h-1.5 w-1.5 rounded-full bg-cyan-600" />
                  Pemkot: Verifikator & pembuat kebijakan
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-navy-500">
                  <span className="h-1.5 w-1.5 rounded-full bg-emerald-600" />
                  Developer: Integrator & pembangun API
                </div>
              </div>
              <p className="text-xs text-navy-400 font-light italic">
                *Arahkan kursor atau sentuh tumpukan kartu untuk menjeda animasi.
              </p>
            </div>

            {/* Right Column - CardSwap stacked cards */}
            <div className="lg:col-span-3 flex justify-center items-center h-[420px] overflow-visible w-full max-w-lg mx-auto">
              <CardSwap width="100%" height={360} cardDistance={30} verticalDistance={35} delay={4500} pauseOnHover>
                {[
                  {
                    icon: <Users className="h-8 w-8" />,
                    role: "Untuk Warga",
                    desc: "Ambil foto isu lingkungan lewat aplikasi Flutter. Lokasi tervalidasi secara otomatis. Dapatkan reward XP dan koin untuk ditukar sembako gratis di toko reward.",
                    details: ["Upload foto ber-geotag", "Sensor wajah & plat nomor", "XP, Level & Harian Streak", "Penukaran Koin Emas"],
                    gradient: "from-violet-500 to-indigo-600",
                    border: "border-violet-500/20",
                  },
                  {
                    icon: <Building2 className="h-8 w-8" />,
                    role: "Untuk Pemerintah Kota",
                    desc: "Akses dashboard admin Next.js real-time untuk memantau sebaran isu kota. Analisis spasial berbasis GIS (PostGIS) anti-duplikasi membantu alokasi respon terarah.",
                    details: ["Leaflet Map visualisasi", "Moderasi dibantu AI", "Query spasial PostGIS", "Ekspor data PDF/Excel"],
                    gradient: "from-cyan-500 to-blue-600",
                    border: "border-cyan-500/20",
                  },
                  {
                    icon: <Code2 className="h-8 w-8" />,
                    role: "Untuk Developer",
                    desc: "Integrasikan sistem internal kota dengan REST API NestJS Fastify. Otentikasi JWT Bearer dengan RBAC aman dan OpenAPI Swagger interaktif.",
                    details: ["Swagger docs auto-generated", "JWT Bearer auth + RBAC", "Webhook notifikasi", "GeoJSON & WKT output"],
                    gradient: "from-emerald-500 to-teal-600",
                    border: "border-emerald-500/20",
                  },
                ].map((card) => (
                  <div
                    key={card.role}
                    className={`card-swap-card bg-white border ${card.border} rounded-3xl p-8 flex flex-col justify-between shadow-2xl`}
                    style={{ position: "absolute", top: 0, left: 0 }}
                  >
                    <div>
                      <div className={`h-14 w-14 rounded-2xl bg-gradient-to-br ${card.gradient} flex items-center justify-center text-white mb-6 shadow-md`}>
                        {card.icon}
                      </div>
                      <h4 className="text-xl font-bold text-navy-900 mb-2">{card.role}</h4>
                      <p className="text-navy-600 text-sm font-light leading-relaxed mb-6">{card.desc}</p>
                    </div>
                    <ul className="flex flex-wrap gap-x-4 gap-y-1.5 border-t border-navy-50 pt-4">
                      {card.details.map((detail) => (
                        <li key={detail} className="flex items-center gap-1.5 text-xs text-navy-500 font-light">
                          <span className="h-1 w-1 rounded-full bg-navy-400" />
                          {detail}
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
              </CardSwap>
            </div>
          </div>
        </div>
      </section>

      {/* ═══════════ IMPACT ARCHITECTURE ═══════════ */}
      <section className="relative w-full bg-navy-950 text-white py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute bottom-0 right-1/4 h-[400px] w-[400px] rounded-full bg-indigo-950/30 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-indigo-400 uppercase mb-3 block">Architecture</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-white tracking-tight mb-4">
              Impact Architecture
            </ScrollFloat>
          </div>

          <ScrollReveal
            enableBlur
            blurStrength={3}
            baseOpacity={0.15}
            containerClassName="max-w-2xl mx-auto !m-0 mb-12"
            textClassName="!text-base !font-light text-white/60 !leading-relaxed text-center"
          >
            Arsitektur multi-layer yang menghubungkan warga dengan pemerintah kota melalui pipeline data AI yang tervalidasi secara spasial dan temporal.
          </ScrollReveal>

          <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mt-12">
            {[
              { icon: <Smartphone className="h-5 w-5" />, label: "Flutter Client", sub: "Cross-platform mobile" },
              { icon: <Server className="h-5 w-5" />, label: "NestJS Gateway", sub: "Fastify ~45k req/s" },
              { icon: <Database className="h-5 w-5" />, label: "Supabase + PostGIS", sub: "Spatial PostgreSQL" },
              { icon: <Eye className="h-5 w-5" />, label: "Vision API", sub: "PII detection & blur" },
              { icon: <Brain className="h-5 w-5" />, label: "Gemini 2.5 Flash", sub: "AI classification" },
              { icon: <MessageSquare className="h-5 w-5" />, label: "RAG Chatbot", sub: "Regulasi knowledge" },
            ].map((item, i) => (
              <AnimatedContent key={item.label} delay={i * 0.1} distance={40}>
                <div className="rounded-2xl bg-white/[0.03] border border-white/5 p-5 text-center">
                  <div className="flex justify-center mb-3">
                    <div className="h-10 w-10 rounded-xl bg-indigo-500/10 flex items-center justify-center text-indigo-400">
                      {item.icon}
                    </div>
                  </div>
                  <p className="text-sm font-medium text-white">{item.label}</p>
                  <p className="text-xs text-white/30 mt-1">{item.sub}</p>
                </div>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════ REWARD ECOSYSTEM ═══════════ */}
      <section className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute top-1/4 right-0 h-[500px] w-[500px] rounded-full bg-gold-50 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-gold uppercase mb-3 block">Rewards</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Reward Ecosystem
            </ScrollFloat>
            <p className="text-navy-600 max-w-lg mx-auto text-sm sm:text-base font-light leading-relaxed">
              Konversi XP menjadi koin emas (XP × 3), lalu tukarkan dengan produk sembako nyata. Berkontribusi pada lingkungan, dapatkan manfaat langsung.
            </p>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
            {[
              { icon: <Droplets className="h-6 w-6" />, name: "Minyak Goreng", coins: "450 Koin" },
              { icon: <Package className="h-6 w-6" />, name: "Beras Premium", coins: "600 Koin" },
              { icon: <ShoppingBag className="h-6 w-6" />, name: "Gula Kristal", coins: "300 Koin" },
              { icon: <Gift className="h-6 w-6" />, name: "Paket Sembako", coins: "1500 Koin" },
              { icon: <Ticket className="h-6 w-6" />, name: "Voucher Belanja", coins: "900 Koin" },
            ].map((item, i) => (
              <AnimatedContent key={item.name} delay={i * 0.1} distance={40}>
                <GlareHover
                  background="white"
                  borderRadius="16px"
                  borderColor="rgba(0,0,0,0.04)"
                  glareColor="#eab308"
                  glareOpacity={0.12}
                >
                  <div className="p-5 flex flex-col items-center text-center gap-3 w-full">
                    <div className="h-12 w-12 rounded-xl bg-gold-50 flex items-center justify-center text-gold">
                      {item.icon}
                    </div>
                    <h3 className="text-sm font-semibold text-navy-900">{item.name}</h3>
                    <span className="text-xs text-gold font-medium">{item.coins}</span>
                  </div>
                </GlareHover>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
