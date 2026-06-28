"use client";
import React from "react";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import { ShieldCheck, ArrowRight } from "lucide-react";

export default function Solutions() {
  return (
    <main className="relative w-full min-h-screen bg-surface flex flex-col">
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/solutions.mp4" />
        {/* Dark overlay specifically requested for readability */}
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />
        
        <div className="relative z-50">
          <Header />
        </div>
        
        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none" style={{ background: "rgba(255, 255, 255, 0.16)" }}>
            Solutions . Eco-Tech
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Smart solutions for modern cities.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Discover how Genesis.id solves urban ecological challenges through data-driven technology.
          </p>
          
          {/* Action Buttons */}
          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row-reverse items-center justify-center gap-4 animate-fade-up delay-4">
            <a href="#" className="flex items-center gap-2 rounded-xl bg-white px-6 py-3 text-sm font-semibold text-navy-900 shadow-xl shadow-white/10 hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none">
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <button className="flex items-center gap-2 rounded-xl liquid-glass px-6 py-3 text-sm font-medium text-white hover:bg-white/10 border border-white/20 hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer select-none">
              Explore Solutions
              <ArrowRight className="h-4.5 w-4.5" />
            </button>
          </div>
        </div>
      </div>

      {/* Scrollable content below the fold */}
      <section className="relative w-full bg-surface text-navy-900 py-24 px-4 sm:px-8 flex flex-col items-center justify-center border-t border-navy-100">
        <h2 className="text-3xl sm:text-4xl font-light tracking-tight mb-8 text-center">Comprehensive Capabilities</h2>
        <div className="max-w-4xl mx-auto flex flex-col gap-8 text-navy-700 font-light leading-relaxed">
          <p>
            We empower municipalities and citizens to collaborate on an unprecedented scale. 
            Detailed specifications and case studies will be outlined here.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-8">
            <div className="bg-white p-8 rounded-2xl shadow-sm border border-navy-50">
              <h3 className="text-xl font-medium text-navy-900 mb-3">Eco-Reporting</h3>
              <p>Test content block for scrolling. This area will eventually contain rich, interactive descriptions of the app's capabilities.</p>
            </div>
            <div className="bg-white p-8 rounded-2xl shadow-sm border border-navy-50">
              <h3 className="text-xl font-medium text-navy-900 mb-3">Data Analytics</h3>
              <p>Test content block for scrolling. This area will eventually contain rich, interactive descriptions of the app's capabilities.</p>
            </div>
          </div>
          <p className="mt-8 text-center text-sm text-navy-500">
            Scroll test padding. More sections can be added below.
          </p>
        </div>
      </section>
    </main>
  );
}
