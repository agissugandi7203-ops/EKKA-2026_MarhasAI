"use client";

import React, { useState, useCallback } from "react";
import dynamic from "next/dynamic";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import AnimatedContent from "@/components/reactbits/AnimatedContent";
import { ShieldCheck, ArrowRight, Mail, GitBranch, MapPin, Send, CheckCircle2, User, Briefcase, MessageSquare } from "lucide-react";

const ScrollFloat = dynamic(() => import("@/components/reactbits/ScrollFloat"), { ssr: false });

const APK_URL = "https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk";

export default function Contact() {
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = useCallback((e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3000);
  }, []);

  return (
    <main className="relative w-full min-h-screen bg-surface flex flex-col">
      {/* ═══════════ HERO ═══════════ */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/contact.mp4" />
        <div className="absolute inset-0 bg-black/50 z-10 pointer-events-none" />

        <div className="relative z-50">
          <Header />
        </div>

        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none" style={{ background: "rgba(255, 255, 255, 0.16)" }}>
            Contact · 24/7 Support
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            We&apos;re here to help.
          </h1>
          <p className="mt-5 sm:mt-6 max-w-xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Get in touch with our team for enterprise queries, community support, or API assistance.
          </p>

          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row-reverse items-center justify-center gap-4 animate-fade-up delay-4">
            <a href={APK_URL} className="flex items-center gap-2 rounded-xl bg-white px-6 py-3 text-sm font-semibold text-navy-900 shadow-xl shadow-white/10 hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none">
              Get the App
              <ShieldCheck className="h-4.5 w-4.5 text-navy-900" />
            </a>
            <a href="#contact-form" className="flex items-center gap-2 rounded-xl liquid-glass px-6 py-3 text-sm font-medium text-white hover:bg-white/10 border border-white/20 hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer select-none">
              Contact Us
              <ArrowRight className="h-4.5 w-4.5" />
            </a>
          </div>
        </div>
      </div>

      {/* ═══════════ CONTACT FORM ═══════════ */}
      <section id="contact-form" className="relative w-full bg-surface text-navy-900 py-28 px-4 sm:px-6 md:px-8 border-t border-navy-100 overflow-hidden">
        <div className="absolute bottom-0 left-1/4 h-[500px] w-[500px] rounded-full bg-burgundy-100/50 blur-[150px] pointer-events-none" />

        <div className="relative z-10 max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs font-semibold tracking-widest text-burgundy-700 uppercase mb-3 block">Contact</span>
            <ScrollFloat containerClassName="!text-3xl sm:!text-4xl md:!text-5xl font-light text-navy-900 tracking-tight mb-4">
              Hubungi Kami
            </ScrollFloat>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-5 gap-10">
            {/* Form */}
            <AnimatedContent distance={60} className="lg:col-span-3">
              <div className="bg-white rounded-3xl border border-navy-50 shadow-xl shadow-navy-900/5 p-8 sm:p-10">
                {submitted ? (
                  <div className="flex flex-col items-center justify-center py-16 text-center">
                    <div className="h-16 w-16 rounded-full bg-emerald-50 flex items-center justify-center mb-4">
                      <CheckCircle2 className="h-8 w-8 text-emerald-600" />
                    </div>
                    <h3 className="text-xl font-semibold text-navy-900 mb-2">Pesan Terkirim!</h3>
                    <p className="text-navy-600 text-sm font-light">Tim kami akan merespons dalam 24 jam kerja.</p>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-5">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                      <div>
                        <label htmlFor="contact-name" className="block text-xs font-semibold text-navy-700 mb-1.5">Nama Lengkap</label>
                        <input
                          id="contact-name"
                          type="text"
                          required
                          className="w-full rounded-xl border border-navy-100 bg-navy-50/30 px-4 py-2.5 text-sm text-navy-900 placeholder:text-navy-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-400 transition-all"
                          placeholder="John Doe"
                        />
                      </div>
                      <div>
                        <label htmlFor="contact-email" className="block text-xs font-semibold text-navy-700 mb-1.5">Email</label>
                        <input
                          id="contact-email"
                          type="email"
                          required
                          className="w-full rounded-xl border border-navy-100 bg-navy-50/30 px-4 py-2.5 text-sm text-navy-900 placeholder:text-navy-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-400 transition-all"
                          placeholder="john@example.com"
                        />
                      </div>
                    </div>

                    <div>
                      <label htmlFor="contact-org" className="block text-xs font-semibold text-navy-700 mb-1.5">Organisasi <span className="text-navy-400 font-normal">(opsional)</span></label>
                      <input
                        id="contact-org"
                        type="text"
                        className="w-full rounded-xl border border-navy-100 bg-navy-50/30 px-4 py-2.5 text-sm text-navy-900 placeholder:text-navy-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-400 transition-all"
                        placeholder="Nama perusahaan atau instansi"
                      />
                    </div>

                    <div>
                      <label htmlFor="contact-subject" className="block text-xs font-semibold text-navy-700 mb-1.5">Subjek</label>
                      <select
                        id="contact-subject"
                        required
                        className="w-full rounded-xl border border-navy-100 bg-navy-50/30 px-4 py-2.5 text-sm text-navy-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-400 transition-all appearance-none"
                      >
                        <option value="">Pilih subjek...</option>
                        <option value="partnership">Partnership & B2G</option>
                        <option value="technical">Technical Support</option>
                        <option value="general">General Inquiry</option>
                      </select>
                    </div>

                    <div>
                      <label htmlFor="contact-message" className="block text-xs font-semibold text-navy-700 mb-1.5">Pesan</label>
                      <textarea
                        id="contact-message"
                        required
                        rows={5}
                        className="w-full rounded-xl border border-navy-100 bg-navy-50/30 px-4 py-2.5 text-sm text-navy-900 placeholder:text-navy-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-400 transition-all resize-none"
                        placeholder="Tuliskan pesan Anda..."
                      />
                    </div>

                    <button
                      type="submit"
                      className="w-full flex items-center justify-center gap-2 rounded-xl bg-navy-900 px-6 py-3 text-sm font-semibold text-white shadow-md hover:bg-navy-800 hover:scale-[1.02] active:scale-[0.98] transition-all duration-200"
                    >
                      <Send className="h-4 w-4" />
                      Kirim Pesan
                    </button>
                  </form>
                )}
              </div>
            </AnimatedContent>

            {/* Contact info cards */}
            <AnimatedContent distance={60} delay={0.2} className="lg:col-span-2">
              <div className="space-y-4">
                {[
                  {
                    icon: <Mail className="h-5 w-5" />,
                    title: "Email",
                    detail: "genesis.id@support.com",
                    sub: "Respon dalam 24 jam kerja",
                  },
                  {
                    icon: <GitBranch className="h-5 w-5" />,
                    title: "GitHub",
                    detail: "agissugandi7203-ops",
                    sub: "Open source contributions",
                    href: "https://github.com/agissugandi7203-ops",
                  },
                  {
                    icon: <MapPin className="h-5 w-5" />,
                    title: "Lokasi",
                    detail: "Surabaya, Jawa Timur",
                    sub: "Indonesia",
                  },
                ].map((info) => (
                  <div key={info.title} className="bg-white rounded-2xl border border-navy-50 p-5 flex items-start gap-4 hover:shadow-md transition-shadow">
                    <div className="h-10 w-10 rounded-xl bg-navy-50 flex items-center justify-center text-navy-600 shrink-0">
                      {info.icon}
                    </div>
                    <div>
                      <p className="text-xs font-semibold text-navy-500 uppercase tracking-wide">{info.title}</p>
                      {info.href ? (
                        <a href={info.href} target="_blank" rel="noreferrer noopener" className="text-sm font-medium text-navy-900 hover:text-indigo-600 transition-colors">
                          {info.detail}
                        </a>
                      ) : (
                        <p className="text-sm font-medium text-navy-900">{info.detail}</p>
                      )}
                      <p className="text-xs text-navy-400 mt-0.5">{info.sub}</p>
                    </div>
                  </div>
                ))}
              </div>
            </AnimatedContent>
          </div>
        </div>
      </section>

      {/* ═══════════ TEAM MOCKUP ═══════════ */}
      <section className="relative w-full bg-navy-950 text-white py-28 px-4 sm:px-6 md:px-8 overflow-hidden">
        <div className="absolute top-0 right-1/3 h-[400px] w-[400px] rounded-full bg-indigo-950/30 blur-[120px] pointer-events-none" />

        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <span className="text-xs font-semibold tracking-widest text-indigo-400 uppercase mb-3 block">Team</span>
          <ScrollFloat containerClassName="!text-3xl sm:!text-4xl font-light text-white tracking-tight mb-12">
            Meet the Team
          </ScrollFloat>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
            {[
              {
                initials: "AF",
                name: "Arief Fajar",
                role: "Lead Developer & System Architect",
                icon: <User className="h-4 w-4" />,
                gradient: "from-violet-500 to-indigo-600",
              },
              {
                initials: "GT",
                name: "Genesis Team",
                role: "Mobile & Flutter Engineering",
                icon: <Briefcase className="h-4 w-4" />,
                gradient: "from-cyan-500 to-blue-600",
              },
              {
                initials: "AO",
                name: "Admin Operations",
                role: "Dashboard & Data Moderation",
                icon: <MessageSquare className="h-4 w-4" />,
                gradient: "from-emerald-500 to-teal-600",
              },
            ].map((person, i) => (
              <AnimatedContent key={person.name} delay={i * 0.15} distance={40}>
                <div className="rounded-2xl bg-white/[0.03] border border-white/5 p-6 text-center">
                  <div className={`h-16 w-16 rounded-2xl bg-gradient-to-br ${person.gradient} flex items-center justify-center mx-auto mb-4 text-white font-bold text-lg shadow-lg`}>
                    {person.initials}
                  </div>
                  <h3 className="text-sm font-semibold text-white mb-1">{person.name}</h3>
                  <p className="text-xs text-white/40 flex items-center justify-center gap-1.5">
                    {person.icon}
                    {person.role}
                  </p>
                </div>
              </AnimatedContent>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
