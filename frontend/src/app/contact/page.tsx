"use client";

import React, { useState, useRef } from "react";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { 
  ShieldCheck, 
  ArrowRight, 
  Mail, 
  MessageSquare, 
  MapPin, 
  HelpCircle,
  Clock,
  X,
  Sparkles,
  Send,
  Loader2,
  CheckCircle2
} from "lucide-react";
import { useLiquidGlass } from "@/lib/useLiquidGlass";

export default function Contact() {
  const [isOpen, setIsOpen] = useState(false);
  const [transform, setTransform] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  
  const dragStart = useRef({ x: 0, y: 0 });
  const activeTransform = useRef({ x: 0, y: 0 });

  // Form State
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

  // Liquid Glass refs
  const glassRef = useLiquidGlass<HTMLDivElement>();
  const triggerRef = useLiquidGlass<HTMLButtonElement>();

  // Pointer dragging handlers for premium desktop/mobile gesture tracking
  const onPointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    if (e.button !== 0) return; // Only allow drag on left mouse click
    setIsDragging(true);
    dragStart.current = { x: e.clientX, y: e.clientY };
    e.currentTarget.setPointerCapture(e.pointerId);
  };

  const onPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    if (!isDragging) return;
    const dx = e.clientX - dragStart.current.x;
    const dy = e.clientY - dragStart.current.y;
    
    // Containment boundary check helper
    let newX = activeTransform.current.x + dx;
    let newY = activeTransform.current.y + dy;

    setTransform({ x: newX, y: newY });
  };

  const onPointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    if (!isDragging) return;
    setIsDragging(false);
    e.currentTarget.releasePointerCapture(e.pointerId);
    
    const dx = e.clientX - dragStart.current.x;
    const dy = e.clientY - dragStart.current.y;
    activeTransform.current = {
      x: activeTransform.current.x + dx,
      y: activeTransform.current.y + dy
    };
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !email || !message) return;
    setLoading(true);
    
    // Simulate API Submission
    setTimeout(() => {
      setLoading(false);
      setSuccess(true);
      setName("");
      setEmail("");
      setMessage("");
      setTimeout(() => setSuccess(false), 5000);
    }, 1500);
  };

  return (
    <main className="relative w-full min-h-screen bg-slate-50 flex flex-col font-sans">
      
      {/* Hero Section */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/contact.mp4" />
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
            Contact . 24/7 Support
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.15] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            We're here to help.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/85 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Get in touch with our team for enterprise queries, community support, or API assistance.
          </p>
          
          {/* Action Buttons */}
          <div className="mt-8 flex flex-col sm:flex-row justify-center items-center w-full sm:w-auto gap-3.5 sm:gap-4 animate-fade-up delay-4">
            <a 
              href="https://storage.googleapis.com/arisa-opsi-bucket-2026/app-arm64-v8a-release.apk" 
              className="flex items-center gap-2 w-full sm:w-auto rounded-xl bg-white px-7 py-3 text-sm font-semibold text-navy-900 shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center justify-center"
            >
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a 
              href="#grid" 
              className="w-full sm:w-auto liquid-glass rounded-xl px-7 py-3 text-sm font-semibold text-white shadow-md hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none text-center border border-white/10"
            >
              Contact Grid
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
            Support Channels
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-light text-slate-900 tracking-tight mb-5">
            Always connected.
          </h2>
          <p className="text-slate-500 max-w-2xl text-sm sm:text-base font-light mb-16 leading-relaxed">
            Reach out through our specialized pipelines to ensure your environmental questions find the right resolution.
          </p>

          {/* Premium Bento Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full text-left">
            
            {/* Box 1 (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-150/70 shadow-[0_8px_30px_rgba(15,23,42,0.01)] hover:shadow-[0_12px_40px_rgba(15,23,42,0.03)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-indigo-50/50 flex items-center justify-center text-indigo-650 border border-indigo-100">
                  <Mail className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">B2G Partnerships & Implementation</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Are you a municipal official or city council representative looking to deploy Genesis? Get in touch with our dedicated implementation team to setup sandbox environments and geofenced routing rules.
                  </p>
                </div>
              </div>
              <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3.5 mt-2">
                <a 
                  href="mailto:partnership@genesisHub.web.id"
                  className="text-xs font-semibold text-indigo-650 flex items-center gap-1.5 hover:underline"
                >
                  partnership@genesisHub.web.id
                  <ArrowRight className="h-3.5 w-3.5" />
                </a>
              </div>
            </div>

            {/* Box 2 (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-emerald-50 flex items-center justify-center text-emerald-650 border border-emerald-100">
                  <MessageSquare className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Citizen Support</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Encountered an issue with mobile location validation, GPS sensor accuracy, or badge rewards?
                  </p>
                </div>
              </div>
              <a 
                href="mailto:support@genesisHub.web.id" 
                className="text-xs font-semibold text-emerald-650 hover:underline flex items-center gap-1"
              >
                support@genesisHub.web.id
              </a>
            </div>

            {/* Box 3 (Col span 1) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-700 border border-slate-100">
                  <Clock className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Response SLA</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Our technical support dashboard aims to respond to critical inquiries within 12 hours.
                  </p>
                </div>
              </div>
              <span className="text-[10px] bg-slate-50 border border-slate-100 text-slate-500 font-bold uppercase tracking-wider px-3 py-1 rounded-full w-fit">
                24/7 Operations Monitoring
              </span>
            </div>

            {/* Box 4 (Col span 2) */}
            <div className="bg-[#fafbfd] rounded-[32px] p-8 border border-slate-200 shadow-[0_4px_20px_rgba(15,23,42,0.08)] hover:shadow-[0_8px_32px_rgba(15,23,42,0.12)] hover:scale-[1.01] transition-all duration-300 md:col-span-2 flex flex-col justify-between gap-6 relative overflow-hidden group">
              <div className="flex flex-col gap-4">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-700 border border-slate-100">
                  <MapPin className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Operational Hub</h3>
                  <p className="text-slate-600 text-sm leading-relaxed mt-2">
                    Our central systems engineering team is located in Surabaya, coordinating platform status dynamically across Indonesian municipal boundaries.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1 text-xs text-slate-500">
                <HelpCircle className="h-3.5 w-3.5 text-slate-400" />
                <span>Surabaya, Indonesia</span>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* Floating Draggable Contact Card */}
      {isOpen && (
        <div 
          ref={glassRef}
          style={{
            position: "fixed",
            bottom: "100px",
            right: "24px",
            width: "320px",
            zIndex: 999,
            transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
            transition: isDragging ? "none" : "transform 0.15s cubic-bezier(0.25, 0.8, 0.25, 1)",
            touchAction: "none"
          }}
          className="liquid-glass-dressing rounded-[28px] p-6 shadow-2xl overflow-hidden border border-white/10"
        >
          {/* Card Header (Drag Handler) */}
          <div 
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            className="flex items-center justify-between pb-3 border-b border-white/10 cursor-move select-none"
          >
            <div className="flex items-center gap-2">
              <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-[10px] font-bold text-white uppercase tracking-wider">Refractive Live Chat</span>
            </div>
            <button 
              onClick={() => setIsOpen(false)}
              className="text-slate-400 hover:text-white transition-colors cursor-pointer"
            >
              <X className="h-4 w-4" />
            </button>
          </div>

          {/* Card Content */}
          <div className="mt-4 flex flex-col gap-4">
            {success ? (
              <div className="flex flex-col items-center text-center gap-3 py-6 animate-fade-up">
                <div className="h-12 w-12 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                  <CheckCircle2 className="h-6 w-6" />
                </div>
                <h4 className="text-sm font-bold text-white">Pesan Terkirim!</h4>
                <p className="text-[10px] text-slate-400 font-light max-w-[200px]">
                  Terima kasih, tim dukungan kami akan segera menghubungi Anda melalui email.
                </p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-3">
                <p className="text-[11px] text-slate-350 font-light leading-relaxed">
                  Tulis pesan Anda di bawah ini untuk terhubung langsung dengan sistem crowdsourcing Genesis.
                </p>
                <div className="flex flex-col gap-1">
                  <label className="text-[9px] font-bold uppercase tracking-wider text-slate-400 pl-0.5">Nama</label>
                  <input 
                    type="text" 
                    required 
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Nama Anda" 
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-colors"
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-[9px] font-bold uppercase tracking-wider text-slate-400 pl-0.5">Email</label>
                  <input 
                    type="email" 
                    required 
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="email@example.com" 
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-colors"
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-[9px] font-bold uppercase tracking-wider text-slate-400 pl-0.5">Pesan</label>
                  <textarea 
                    rows={2}
                    required 
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Bagaimana kami bisa membantu?" 
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-2 px-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-white/20 focus:bg-white/10 transition-colors resize-none"
                  />
                </div>
                <button
                  type="submit"
                  disabled={loading}
                  className="mt-2 w-full rounded-xl bg-white hover:bg-slate-100 text-navy-950 py-2.5 text-xs font-semibold shadow-md flex items-center justify-center gap-1.5 transition-all cursor-pointer disabled:opacity-50"
                >
                  {loading ? (
                    <>
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                      Mengirim...
                    </>
                  ) : (
                    <>
                      Kirim Pesan
                      <Send className="h-3 w-3" />
                    </>
                  )}
                </button>
              </form>
            )}
          </div>
        </div>
      )}

      {/* Floating Sparkles Glass Trigger Button */}
      <button 
        ref={triggerRef}
        onClick={() => setIsOpen(!isOpen)}
        style={{
          position: "fixed",
          bottom: "24px",
          right: "24px",
          zIndex: 998,
        }}
        className="liquid-glass-dressing h-14 w-14 rounded-full shadow-2xl flex items-center justify-center text-white hover:scale-110 active:scale-95 transition-transform duration-200 cursor-pointer border border-white/15"
        title="Live Support Chat"
      >
        <MessageSquare className="h-6 w-6" />
      </button>

      {/* Reusable Footer */}
      <Footer />

    </main>
  );
}
