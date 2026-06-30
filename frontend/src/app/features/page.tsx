"use client";

import React from "react";
import dynamic from "next/dynamic";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import AnimatedContent from "@/components/reactbits/AnimatedContent";
import GlareHover from "@/components/reactbits/GlareHover";
import BorderGlow from "@/components/reactbits/BorderGlow";
import {
  ShieldCheck, ArrowRight, Star, TrendingUp, Flame, Medal,
  Brain, ScanEye, MapPinned, Satellite, BookOpen, Webhook,
  Zap, Lock, ChevronRight
} from "lucide-react";

const ScrollFloat = dynamic(() => import("@/components/reactbits/ScrollFloat"), { ssr: false });
const ScrollReveal = dynamic(() => import("@/components/reactbits/ScrollReveal"), { ssr: false });

const APK_URL = "https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk";

export default function Features() {
  return (
    <main className="relative w-full min-h-screen bg-surface flex flex-col">
      {/* ═══════════ HERO ═══════════ */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/features.mp4" />
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />

        <div className="relative z-50">
          <Header />
        </div>

        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none" style={{ background: "rgba(255, 255, 255, 0.16)" }}>
            Features · Real-Time
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            See the impact, live.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Interactive map feeds and real-time gamification leaderboards to drive community engagement.
          </p>

          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row-reverse items-center justify-center gap-4 animate-fade-up delay-4">
            <a href={APK_URL} className="flex items-center gap-2 rounded-xl bg-white px-6 py-3 text-sm font-semibold text-navy-900 shadow-xl shadow-white/10 hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none">
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a href="#gamification" className="flex items-center gap-2 rounded-xl liquid-glass px-6 py-3 text-sm font-medium text-white hover:bg-white/10 border border-white/20 hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer select-none">
              Explore Features
              <ArrowRight className="h-4.5 w-4.5" />
            </a>
          </div>
        </div>
      </div>

      {/* ═══════════ GAMIFICATION ENGINE ═══════════ */}
      <section id="gamification" className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 border-t border-navy-100 overflow-hidden">
        <div className="absolute top-0 right-0 h-[500px] w-[500px] rounded-full bg-gold-50 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-gold uppercase mb-3 block">Gamification</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Gamification Engine
            </ScrollFloat>
            <p className="text-navy-600 max-w-xl mx-auto text-sm sm:text-base font-light leading-relaxed">
              Setiap aksi bermakna menghasilkan reward. Sistem XP, Level, Streak, dan Badge dirancang untuk mendorong partisipasi berkelanjutan.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                icon: <Star className="h-5 w-5" />,
                title: "XP System",
                desc: "+100 XP per approved report. Earned automatically via awardReportRewards() when admin approves.",
                accent: "from-amber-400 to-yellow-500",
              },
              {
                icon: <TrendingUp className="h-5 w-5" />,
                title: "Level Progression",
                desc: "Level up setiap 1000 XP. Sistem tier progression menunjukkan kontribusi kumulatif warga.",
                accent: "from-violet-500 to-purple-600",
              },
              {
                icon: <Flame className="h-5 w-5" />,
                title: "Daily Streak",
                desc: "Streak harian ter-reset otomatis jika melewati 24 jam tanpa laporan. Mendorong konsistensi pelaporan.",
                accent: "from-orange-500 to-red-500",
              },
              {
                icon: <Medal className="h-5 w-5" />,
                title: "Badge Collection",
                desc: "Badge otomatis dari milestone dan badge manual dari admin. Disimpan di profile_badges (M2M relation).",
                accent: "from-emerald-500 to-teal-600",
              },
            ].map((card, i) => (
              <AnimatedContent key={card.title} delay={i * 0.12} distance={50}>
                <GlareHover background="white" borderRadius="20px" borderColor="rgba(0,0,0,0.04)" glareColor="#eab308" glareOpacity={0.1}>
                  <div className="p-6 flex flex-col gap-3 w-full">
                    <div className={`h-10 w-10 rounded-xl bg-gradient-to-br ${card.accent} flex items-center justify-center text-white shadow-md`}>
                      {card.icon}
                    </div>
                    <h3 className="text-base font-semibold text-navy-900">{card.title}</h3>
                    <p className="text-navy-600 text-sm font-light leading-relaxed">{card.desc}</p>
                  </div>
                </GlareHover>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════ AI CLASSIFICATION ═══════════ */}
      <section className="relative w-full bg-navy-950 text-white py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute top-1/3 left-1/4 h-[400px] w-[400px] rounded-full bg-cyan-950/30 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-cyan-400 uppercase mb-3 block">AI Pipeline</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-white tracking-tight mb-4">
              AI-Powered Classification
            </ScrollFloat>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Description */}
            <AnimatedContent distance={60} direction="horizontal">
              <div className="space-y-6">
                <ScrollReveal
                  enableBlur
                  blurStrength={3}
                  baseOpacity={0.2}
                  containerClassName="!m-0"
                  textClassName="!text-base !font-light text-white/70 !leading-relaxed"
                >
                  Gemini 2.5 Flash menganalisis setiap foto laporan dan mengekstrak waste_type, danger_level, validity boolean, serta confidence_score numerik. Laporan dengan skor di atas 85% langsung disetujui otomatis oleh sistem — sisanya masuk antrian moderasi admin.
                </ScrollReveal>
                <div className="flex items-center gap-3 text-sm text-white/40">
                  <Brain className="h-4 w-4 text-cyan-400" />
                  <span>Powered by Google Gemini 2.5 Flash via OpenRouter</span>
                </div>
              </div>
            </AnimatedContent>

            {/* Visual pipeline */}
            <AnimatedContent distance={60} direction="horizontal" reverse delay={0.2}>
              <div className="space-y-4">
                {[
                  { label: "Photo Input", detail: "Uploaded via Flutter → GCS bucket", icon: <ScanEye className="h-4 w-4" /> },
                  { label: "AI Analysis", detail: "waste_type · danger_level · confidence", icon: <Brain className="h-4 w-4" /> },
                  { label: "Auto Decision", detail: "≥85% → approved · <85% → pending_human", icon: <Zap className="h-4 w-4" /> },
                  { label: "Admin Review", detail: "Dashboard moderation for edge cases", icon: <Lock className="h-4 w-4" /> },
                ].map((step, i) => (
                  <div key={step.label} className="flex items-start gap-4 rounded-2xl bg-white/[0.03] border border-white/5 p-4">
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-cyan-500/10 text-cyan-400">
                      {step.icon}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-white">{step.label}</p>
                      <p className="text-xs text-white/40 mt-0.5">{step.detail}</p>
                    </div>
                    {i < 3 && <ChevronRight className="h-4 w-4 text-white/10 ml-auto mt-2" />}
                  </div>
                ))}
              </div>
            </AnimatedContent>
          </div>
        </div>
      </section>

      {/* ═══════════ SPATIAL INTELLIGENCE ═══════════ */}
      <section className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute bottom-0 left-0 h-[500px] w-[500px] rounded-full bg-burgundy-100 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-burgundy-700 uppercase mb-3 block">Geo-Spatial</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Spatial Intelligence
            </ScrollFloat>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              {
                icon: <MapPinned className="h-6 w-6" />,
                title: "Anti-Duplicate 50m",
                desc: "PostGIS check_duplicate_report(lat, lng) membandingkan dengan radius 50 meter. Mencegah laporan berulang di lokasi yang sama.",
                accent: "bg-burgundy-50 text-burgundy-700",
              },
              {
                icon: <ScanEye className="h-6 w-6" />,
                title: "PII Detection",
                desc: "Google Vision API mendeteksi wajah dan plat kendaraan. Sharp memproses blur in-memory sebelum upload ke GCS. Zero PII stored.",
                accent: "bg-rose-50 text-rose-600",
              },
              {
                icon: <Satellite className="h-6 w-6" />,
                title: "WKT SRID=4326",
                desc: "Semua data spasial disimpan sebagai PostGIS geometry dengan SRID 4326 (WGS84). Kompatibel dengan GIS tooling standar industri.",
                accent: "bg-indigo-50 text-indigo-600",
              },
            ].map((card, i) => (
              <AnimatedContent key={card.title} delay={i * 0.15} distance={50}>
                <div className="bg-white rounded-2xl p-8 border border-navy-50 shadow-sm hover:shadow-xl hover:scale-[1.02] transition-all duration-300">
                  <div className={`h-12 w-12 rounded-2xl ${card.accent} flex items-center justify-center mb-5`}>
                    {card.icon}
                  </div>
                  <h3 className="text-lg font-semibold text-navy-900 mb-3">{card.title}</h3>
                  <p className="text-navy-600 text-sm font-light leading-relaxed">{card.desc}</p>
                </div>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════ B2G DATA PORTAL ═══════════ */}
      <section className="relative w-full bg-navy-950 text-white py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute bottom-0 right-0 h-[500px] w-[500px] rounded-full bg-indigo-950/40 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <AnimatedContent distance={60}>
              <div>
                <span className="text-xs font-semibold tracking-widest text-indigo-400 uppercase mb-3 block">B2G Portal</span>
                <h2 className="text-3xl sm:text-4xl font-light text-white tracking-tight mb-6">
                  Enterprise-Grade Data Portal
                </h2>
                <div className="space-y-4 text-white/60 text-sm font-light leading-relaxed">
                  <div className="flex items-start gap-3">
                    <Webhook className="h-4 w-4 text-indigo-400 mt-0.5 shrink-0" />
                    <span>OpenAPI Swagger auto-generated dari NestJS decorators. Setiap endpoint terdokumentasi otomatis.</span>
                  </div>
                  <div className="flex items-start gap-3">
                    <Zap className="h-4 w-4 text-indigo-400 mt-0.5 shrink-0" />
                    <span>Fastify adapter menghasilkan ~45,000 req/s throughput. Non-blocking I/O untuk performa maksimal.</span>
                  </div>
                  <div className="flex items-start gap-3">
                    <Lock className="h-4 w-4 text-indigo-400 mt-0.5 shrink-0" />
                    <span>JWT Bearer authentication + RBAC guard. Admin-only endpoints terlindungi @Roles(&apos;admin&apos;) decorator.</span>
                  </div>
                  <div className="flex items-start gap-3">
                    <BookOpen className="h-4 w-4 text-indigo-400 mt-0.5 shrink-0" />
                    <span>Interactive API sandbox di /docs dengan live endpoint testing dan code generation.</span>
                  </div>
                </div>
              </div>
            </AnimatedContent>

            <AnimatedContent distance={60} delay={0.2}>
              <div className="flex justify-center">
                <BorderGlow
                  backgroundColor="#0f0d1a"
                  borderRadius={20}
                  glowRadius={30}
                  glowColor="250 70 70"
                  colors={["#818cf8", "#a78bfa", "#38bdf8"]}
                >
                  <a
                    href="/docs"
                    className="flex items-center justify-center gap-3 px-10 py-5 text-base font-semibold text-white"
                  >
                    <BookOpen className="h-5 w-5" />
                    Explore API Documentation
                    <ArrowRight className="h-4 w-4" />
                  </a>
                </BorderGlow>
              </div>
            </AnimatedContent>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
