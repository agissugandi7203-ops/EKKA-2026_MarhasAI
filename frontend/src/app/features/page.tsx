"use client";

import React from "react";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { 
  ShieldCheck, 
  ArrowRight, 
  Map, 
  Sparkles, 
  Flame, 
  Award, 
  Locate,
  Eye
} from "lucide-react";

export default function Features() {
  return (
    <main className="relative w-full min-h-screen bg-slate-50 flex flex-col font-sans">
      
      {/* Hero Section */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/features.mp4" />
        {/* Dark overlay specifically requested for readability */}
        <div className="absolute inset-0 bg-black/55 z-10 pointer-events-none" />
        
        <div className="relative z-50">
          <Header />
        </div>
        
        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div 
            className="liquid-glass rounded-full px-4.5 py-1.5 text-xs text-white animate-fade-up delay-1 mb-6 select-none font-medium uppercase tracking-wider" 
            style={{ background: "rgba(255, 255, 255, 0.12)", border: "1px solid rgba(255, 255, 255, 0.15)" }}
          >
            Features . Real-Time
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.15] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            See the impact, live.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/85 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Interactive map feeds, RAG-powered image verification, and real-time gamification to drive civic engagement.
          </p>
          
          {/* Action Buttons */}
          <div className="mt-8 flex flex-col sm:flex-row justify-center items-center w-full sm:w-auto gap-3.5 sm:gap-4 animate-fade-up delay-4">
            <a 
              href="https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk" 
              className="flex items-center gap-2 w-full sm:w-auto rounded-xl bg-white px-7 py-3 text-sm font-semibold text-navy-900 shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center justify-center"
            >
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a 
              href="#grid" 
              className="w-full sm:w-auto liquid-glass rounded-xl px-7 py-3 text-sm font-semibold text-white shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center border border-white/10"
            >
              Explore Features
            </a>
          </div>
        </div>
      </div>

      {/* Bento Grid Content Section */}
      <section 
        id="grid"
        className="relative w-full bg-[#dde2ef] text-slate-700 py-24 px-4 sm:px-6 md:px-8 flex flex-col items-center justify-center border-t border-slate-300/40 overflow-hidden"
      >
        <div className="absolute top-1/4 left-1/4 h-[450px] w-[450px] rounded-full bg-slate-200/50 blur-[130px] pointer-events-none" />
        
        <div className="relative z-10 max-w-6xl w-full mx-auto flex flex-col items-center text-center">
          <span className="text-xs font-bold tracking-widest text-slate-500 uppercase mb-3">
            Core Features
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-light text-slate-900 tracking-tight mb-5">
            Structured for high engagement.
          </h2>
          <p className="text-slate-500 max-w-2xl text-sm sm:text-base font-light mb-16 leading-relaxed">
            Discover the features built into Genesis that turn passive reporting into active, rewarding participation.
          </p>

          {/* Premium Bento Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full text-left">
            
            {/* Box 1 (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-150/70 shadow-[0_8px_30px_rgba(15,23,42,0.01)] hover:shadow-[0_12px_40px_rgba(15,23,42,0.03)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-550 border border-amber-100">
                  <Award className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Prestige System</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Level up by contributing valid reports. Unlocked badges are showcaseable directly on your public avatar profile.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1 text-xs text-amber-500 font-bold">
                <Flame className="h-4.5 w-4.5 fill-amber-500" />
                <span>Level Streaks</span>
              </div>
            </div>

            {/* Box 2 (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="absolute top-0 right-0 h-40 w-40 bg-slate-50 rounded-full blur-2xl opacity-50 pointer-events-none" />
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-700 border border-slate-100">
                  <Map className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Dynamic Mapping</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Browse active issues, resolved reports, and ecological alerts across Surabaya on a fluid vector-rendered interface. Dynamic geofences identify critical waste clusters instantly.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 mt-2">
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">Vector Maps</span>
                <span className="text-[10px] bg-slate-100 border border-slate-200 text-slate-600 font-bold uppercase tracking-wider px-3 py-1 rounded-full">Auto-Geofencing</span>
              </div>
            </div>

            {/* Box 3 (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-indigo-50/50 flex items-center justify-center text-indigo-650 border border-indigo-100">
                  <Sparkles className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">AI Visual Analysis</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Our AI models automatically detect reporting objects from photo uploads, estimate reporting validation confidence, and classify environmental issues to speed up municipal workflows.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1 text-xs font-semibold text-indigo-650">
                <span>View AI Integration</span>
                <ArrowRight className="h-3.5 w-3.5" />
              </div>
            </div>

            {/* Box 4 (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-700 border border-slate-100">
                  <Locate className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">GPS Validation</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Ensuring metadata authenticity to prevent false inputs, spam reports, or spoofed coordinate uploads.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1.5 text-xs text-slate-500">
                <Eye className="h-3.5 w-3.5" />
                <span>Device Sensor Check</span>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* Reusable Footer */}
      <Footer />

    </main>
  );
}
