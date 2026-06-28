"use client";

import React from "react";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import { ArrowDown, MapPin, Award, Webhook, Smartphone, ShieldCheck } from "lucide-react";

export default function Home() {
  return (
    <main className="relative w-full min-h-screen bg-navy-950 flex flex-col">
      {/* 1. Viewport-Height Hero Section */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        {/* Background Loop */}
        <BoomerangVideoBg src="/videos/home.mp4" />
        {/* Dark overlay specifically requested for readability */}
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />

        {/* Header */}
        <div className="relative z-50">
          <Header />
        </div>

        {/* Hero Content */}
        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          {/* Tag badge */}
          <div
            className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none"
            style={{ background: "rgba(255, 255, 255, 0.16)" }}
          >
            Genesis.id . Ecological Platform
          </div>

          {/* Headline */}
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Transform your city.
          </h1>

          {/* Subtext */}
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Report local issues, earn badges, and help governments build smarter communities.
          </p>

          <div className="mt-8 flex flex-col sm:flex-row justify-center items-center w-full sm:w-auto gap-3 sm:gap-4 animate-fade-up delay-4">
            <a
              href="#"
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

        {/* Bounce Scroll Down Indicator */}
        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 animate-bounce cursor-pointer">
          <a href="#features" aria-label="Scroll down">
            <ArrowDown className="text-white/60 hover:text-white transition-colors h-6 w-6" />
          </a>
        </div>
      </div>

      {/* 2. Features / Showcase Section (Below the fold) */}
      <section
        id="features"
        className="relative w-full min-h-screen bg-surface text-navy-900 py-24 px-4 sm:px-6 md:px-8 flex flex-col items-center justify-center border-t border-navy-100 overflow-hidden"
      >
        {/* Ambient background glows */}
        <div className="absolute top-1/4 left-1/4 h-[500px] w-[500px] rounded-full bg-burgundy-100 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 h-[500px] w-[500px] rounded-full bg-navy-100 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-7xl w-full mx-auto flex flex-col items-center text-center">
          <span className="text-xs font-semibold tracking-widest text-burgundy-700 uppercase mb-3">
            Core Capabilities
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-light text-navy-900 tracking-tight mb-6">
            Engineered for active citizenship.
          </h2>
          <p className="text-navy-700 max-w-2xl text-sm sm:text-base font-light mb-16 leading-relaxed">
            Genesis.id combines mobile geotagged inputs with enterprise-grade data analytics to power real-time ecological governance.
          </p>

          {/* Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full">
            {/* Geotagged Issues */}
            <div className="bg-white rounded-3xl p-8 shadow-xl shadow-navy-900/5 border border-navy-50 hover:border-burgundy-300 hover:shadow-2xl hover:scale-[1.02] transition-all duration-300 flex flex-col items-start text-left gap-4">
              <div className="h-12 w-12 rounded-2xl bg-burgundy-50 flex items-center justify-center text-burgundy-700">
                <MapPin className="h-6 w-6" />
              </div>
              <h3 className="text-xl font-medium text-navy-900">Geotagged Issues</h3>
              <p className="text-navy-700 text-sm font-light leading-relaxed">
                Citizens report issues instantly. The Flutter client auto-validates location metadata, preventing fake claims and ensuring pinpoint accuracy.
              </p>
            </div>

            {/* XP & Lencana */}
            <div className="bg-white rounded-3xl p-8 shadow-xl shadow-navy-900/5 border border-navy-50 hover:border-gold hover:shadow-2xl hover:scale-[1.02] transition-all duration-300 flex flex-col items-start text-left gap-4">
              <div className="h-12 w-12 rounded-2xl bg-gold-50 flex items-center justify-center text-gold">
                <Award className="h-6 w-6" />
              </div>
              <h3 className="text-xl font-medium text-navy-900">XP & Lencana</h3>
              <p className="text-navy-700 text-sm font-light leading-relaxed">
                Gain Experience Points (XP) for valid reports. Complete daily streaks and earn exclusive badges that showcase your commitment to ecology.
              </p>
            </div>

            {/* B2G Integration */}
            <div className="bg-white rounded-3xl p-8 shadow-xl shadow-navy-900/5 border border-navy-50 hover:border-emerald hover:shadow-2xl hover:scale-[1.02] transition-all duration-300 flex flex-col items-start text-left gap-4">
              <div className="h-12 w-12 rounded-2xl bg-emerald-light/50 flex items-center justify-center text-emerald">
                <Webhook className="h-6 w-6" />
              </div>
              <h3 className="text-xl font-medium text-navy-900">Automated OpenAPI</h3>
              <p className="text-navy-700 text-sm font-light leading-relaxed">
                City councils ingest clean, processed spatial data via our secure OpenAPI portal. Fastify handles requests efficiently under robust JWT & RBAC guards.
              </p>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
