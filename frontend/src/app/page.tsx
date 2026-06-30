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
  ArrowDown, MapPin, Award, Webhook, Camera, Brain, Building2,
  ShieldCheck, Download, Zap, Trophy, Shield, ScanEye
} from "lucide-react";

const ScrollFloat = dynamic(() => import("@/components/reactbits/ScrollFloat"), { ssr: false });
const LogoLoop = dynamic(() => import("@/components/reactbits/LogoLoop"), { ssr: false });

const APK_URL = "https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk";

/* ── Tech partner logos as inline SVG nodes ── */
const techLogos = [
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Supabase</span>, title: "Supabase" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">NestJS</span>, title: "NestJS" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Flutter</span>, title: "Flutter" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Next.js</span>, title: "Next.js" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">PostGIS</span>, title: "PostGIS" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Google Cloud</span>, title: "Google Cloud" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Fastify</span>, title: "Fastify" },
  { node: <span className="text-white/40 font-semibold text-sm tracking-wide">Gemini AI</span>, title: "Gemini AI" },
];

export default function Home() {
  return (
    <main className="relative w-full min-h-screen bg-navy-950 flex flex-col">
      {/* ═══════════ 1. HERO SECTION ═══════════ */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/home.mp4" />
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />

        <div className="relative z-50">
          <Header />
        </div>

        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div
            className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none"
            style={{ background: "rgba(255, 255, 255, 0.16)" }}
          >
            Genesis.id · Ecological Platform
          </div>

          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Transform your city.
          </h1>

          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Report local issues, earn badges, and help governments build smarter communities.
          </p>

          <div className="mt-8 flex flex-col sm:flex-row justify-center items-center w-full sm:w-auto gap-3 sm:gap-4 animate-fade-up delay-4">
            <a
              href={APK_URL}
              className="flex items-center gap-2 w-full sm:w-auto rounded-xl bg-white px-7 py-2.5 text-sm font-semibold text-navy-900 shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center justify-center"
            >
              Download
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a
              href="#features"
              className="w-full sm:w-auto liquid-glass rounded-xl px-7 py-2.5 text-sm font-semibold text-white shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center"
            >
              Learn More
            </a>
          </div>
        </div>

        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 animate-bounce cursor-pointer">
          <a href="#features" aria-label="Scroll down">
            <ArrowDown className="text-white/60 hover:text-white transition-colors h-6 w-6" />
          </a>
        </div>
      </div>

      {/* ═══════════ 2. FEATURES SECTION ═══════════ */}
      <section
        id="features"
        className="relative w-full min-h-screen bg-surface text-navy-900 py-24 px-4 sm:px-6 md:px-8 flex flex-col items-center justify-center border-t border-navy-100 overflow-hidden"
      >
        <div className="absolute top-1/4 left-1/4 h-[500px] w-[500px] rounded-full bg-burgundy-100 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 h-[500px] w-[500px] rounded-full bg-navy-100 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-7xl w-full mx-auto flex flex-col items-center text-center">
          <span className="text-xs font-semibold tracking-widest text-burgundy-700 uppercase mb-3">
            Core Capabilities
          </span>
          <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl lg:!text-6xl font-light text-navy-900 tracking-tight mb-6">
            Engineered for active citizenship.
          </ScrollFloat>
          <p className="text-navy-700 max-w-2xl text-sm sm:text-base font-light mb-16 leading-relaxed">
            Genesis.id combines mobile geotagged inputs with enterprise-grade data analytics to power real-time ecological governance.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full">
            {[
              {
                icon: <MapPin className="h-6 w-6" />,
                title: "Geotagged Issues",
                desc: "Citizens report issues instantly. The Flutter client auto-validates location metadata, preventing fake claims and ensuring pinpoint accuracy.",
                iconBg: "bg-burgundy-50", iconColor: "text-burgundy-700", hoverBorder: "hover:border-burgundy-300",
              },
              {
                icon: <Award className="h-6 w-6" />,
                title: "XP & Lencana",
                desc: "Gain Experience Points (XP) for valid reports. Complete daily streaks and earn exclusive badges that showcase your commitment to ecology.",
                iconBg: "bg-gold-50", iconColor: "text-gold", hoverBorder: "hover:border-gold",
              },
              {
                icon: <Webhook className="h-6 w-6" />,
                title: "Automated OpenAPI",
                desc: "City councils ingest clean, processed spatial data via our secure OpenAPI portal. Fastify handles requests efficiently under robust JWT & RBAC guards.",
                iconBg: "bg-emerald-light/50", iconColor: "text-emerald", hoverBorder: "hover:border-emerald",
              },
            ].map((card, i) => (
              <AnimatedContent key={card.title} delay={i * 0.15} distance={60}>
                <GlareHover
                  background="white"
                  borderRadius="24px"
                  borderColor="rgba(0,0,0,0.04)"
                  glareColor="#8b5cf6"
                  glareOpacity={0.12}
                >
                  <div className="p-8 flex flex-col items-start text-left gap-4 w-full">
                    <div className={`h-12 w-12 rounded-2xl ${card.iconBg} flex items-center justify-center ${card.iconColor}`}>
                      {card.icon}
                    </div>
                    <h3 className="text-xl font-medium text-navy-900">{card.title}</h3>
                    <p className="text-navy-700 text-sm font-light leading-relaxed">{card.desc}</p>
                  </div>
                </GlareHover>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════ 3. HOW GENESIS WORKS ═══════════ */}
      <section className="relative w-full bg-navy-950 py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 h-[600px] w-[600px] rounded-full bg-indigo-950/40 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto text-center">
          <span className="text-xs font-semibold tracking-widest text-indigo-400 uppercase mb-3 block">
            How It Works
          </span>
          <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-white tracking-tight mb-4">
            Report. Classify. Act.
          </ScrollFloat>
          <p className="text-white/50 max-w-xl mx-auto text-sm sm:text-base font-light mb-20 leading-relaxed">
            Tiga langkah sederhana mengubah laporan warga menjadi data spasial tervalidasi untuk pemerintah kota.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12">
            {[
              {
                step: "01",
                icon: <Camera className="h-7 w-7" />,
                title: "Warga Melaporkan",
                desc: "Foto masalah lingkungan di app Flutter. Lokasi GPS auto-geotag, PII (wajah & plat) otomatis di-blur oleh Google Vision API sebelum upload ke Google Cloud Storage.",
                color: "from-violet-500 to-indigo-600",
              },
              {
                step: "02",
                icon: <Brain className="h-7 w-7" />,
                title: "AI Mengklasifikasi",
                desc: "Gemini 2.5 Flash menganalisis foto → waste_type, danger_level, validity, confidence_score. Skor >85% langsung auto-approve, sisanya masuk antrian moderasi admin.",
                color: "from-cyan-500 to-blue-600",
              },
              {
                step: "03",
                icon: <Building2 className="h-7 w-7" />,
                title: "Kota Bertindak",
                desc: "Dashboard admin menerima data spasial tervalidasi. PostGIS anti-duplikasi radius 50m mencegah laporan berulang. Data siap untuk pengambilan kebijakan real-time.",
                color: "from-emerald-500 to-teal-600",
              },
            ].map((item, i) => (
              <AnimatedContent key={item.step} delay={i * 0.2} distance={80}>
                <div className="relative flex flex-col items-center text-center p-6">
                  <div className="text-[4rem] font-black text-white/[0.03] absolute top-0 left-1/2 -translate-x-1/2 select-none">
                    {item.step}
                  </div>
                  <div className={`h-14 w-14 rounded-2xl bg-gradient-to-br ${item.color} flex items-center justify-center text-white mb-6 shadow-lg`}>
                    {item.icon}
                  </div>
                  <h3 className="text-lg font-semibold text-white mb-3">{item.title}</h3>
                  <p className="text-white/50 text-sm font-light leading-relaxed">{item.desc}</p>
                </div>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════ 4. TRUSTED TECHNOLOGY ═══════════ */}
      <section className="relative w-full bg-[#060612] border-y border-white/5 py-16 px-4 sm:px-6 overflow-hidden">
        <div className="max-w-5xl mx-auto text-center mb-10">
          <p className="text-xs font-semibold tracking-widest text-white/20 uppercase mb-2">
            Built on battle-tested infrastructure
          </p>
          <p className="text-white/30 text-sm font-light">
            ~45,000 req/s throughput · PostGIS spatial queries · End-to-end JWT + RBAC
          </p>
        </div>
        <div className="h-12 relative">
          <LogoLoop
            logos={techLogos}
            speed={60}
            direction="left"
            logoHeight={20}
            gap={64}
            hoverSpeed={0}
            fadeOut
            fadeOutColor="#060612"
            ariaLabel="Technology partners"
          />
        </div>
      </section>

      {/* ═══════════ 5. PLATFORM AT A GLANCE ═══════════ */}
      <section className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute bottom-0 right-0 h-[500px] w-[500px] rounded-full bg-navy-100 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-burgundy-700 uppercase mb-3 block">
              Platform Overview
            </span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Platform at a Glance
            </ScrollFloat>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                icon: <Zap className="h-6 w-6" />,
                title: "Real-time Reports",
                desc: "Geotagged & AI classified with confidence scoring",
                accent: "from-amber-500 to-orange-600",
              },
              {
                icon: <Trophy className="h-6 w-6" />,
                title: "Gamification Tiers",
                desc: "XP progression, Level system, Daily streaks & Badge collection",
                accent: "from-violet-500 to-purple-600",
              },
              {
                icon: <ScanEye className="h-6 w-6" />,
                title: "PII Redaction",
                desc: "Auto face & plate blur via Google Vision API before storage",
                accent: "from-rose-500 to-pink-600",
              },
              {
                icon: <Shield className="h-6 w-6" />,
                title: "B2G Integration",
                desc: "OpenAPI + Webhook-ready endpoints with JWT & RBAC guards",
                accent: "from-emerald-500 to-teal-600",
              },
            ].map((card, i) => (
              <AnimatedContent key={card.title} delay={i * 0.12} distance={50}>
                <GlareHover
                  background="white"
                  borderRadius="20px"
                  borderColor="rgba(0,0,0,0.04)"
                  glareColor="#6366f1"
                  glareOpacity={0.1}
                >
                  <div className="p-6 flex flex-col gap-4 w-full h-full">
                    <div className={`h-11 w-11 rounded-xl bg-gradient-to-br ${card.accent} flex items-center justify-center text-white shadow-md`}>
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

      {/* ═══════════ 6. CTA SECTION ═══════════ */}
      <section className="relative w-full bg-navy-950 py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-navy-950 via-[#0a0a2e] to-navy-950 pointer-events-none" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-[400px] w-[400px] rounded-full bg-indigo-900/20 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-2xl mx-auto text-center">
          <AnimatedContent distance={60}>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-light text-white tracking-tight mb-6">
              Siap mengubah kotamu?
            </h2>
            <p className="text-white/50 text-sm sm:text-base font-light mb-10 leading-relaxed max-w-lg mx-auto">
              Unduh Genesis.id dan mulai melaporkan masalah lingkungan di sekitarmu. Setiap laporan menghasilkan XP, badge, dan data untuk pemerintah kotamu.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <BorderGlow
                backgroundColor="#0f0d1a"
                borderRadius={16}
                glowRadius={30}
                glowColor="250 70 70"
                colors={["#818cf8", "#a78bfa", "#38bdf8"]}
                className="w-full sm:w-auto"
              >
                <a
                  href={APK_URL}
                  className="flex items-center justify-center gap-3 px-8 py-3.5 text-sm font-semibold text-white w-full"
                >
                  <Download className="h-4.5 w-4.5" />
                  Download Genesis.id
                </a>
              </BorderGlow>

              <a
                href="/admin/login"
                className="w-full sm:w-auto rounded-2xl border border-white/10 px-8 py-3.5 text-sm font-semibold text-white/70 hover:text-white hover:border-white/20 transition-all duration-200 text-center"
              >
                Buka Admin Portal
              </a>
            </div>
          </AnimatedContent>
        </div>
      </section>

      {/* ═══════════ 7. FOOTER ═══════════ */}
      <Footer />
    </main>
  );
}
