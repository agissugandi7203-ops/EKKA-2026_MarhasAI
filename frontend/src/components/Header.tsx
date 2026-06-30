"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Download, Menu, X, Key } from "lucide-react";

interface HeaderProps {
  onOpenLogin?: () => void;
}

export default function Header({ onOpenLogin }: HeaderProps) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 15);
    };
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { label: "Solutions", href: "/solutions" },
    { label: "Services", href: "/services" },
    { label: "Features", href: "/features" },
    { label: "Documentation", href: "/docs" },
    { label: "Contact", href: "/contact" },
  ];

  const handleAdminClick = (e: React.MouseEvent) => {
    if (onOpenLogin) {
      e.preventDefault();
      onOpenLogin();
      setIsMenuOpen(false);
    }
  };

  return (
    <div className={`fixed top-0 left-0 w-full z-50 flex justify-center pointer-events-none transition-all duration-300 ${
      isScrolled ? 'pt-4 px-4' : 'pt-0 px-0'
    }`}>
      <header 
        className={`pointer-events-auto w-full transition-all duration-300 flex flex-col gap-2 ${
          isScrolled 
            ? "max-w-5xl rounded-2xl bg-white/95 backdrop-blur-xl border border-black/5 shadow-[0_8px_32px_rgba(0,0,0,0.08)] py-2.5 px-6" 
            : "max-w-full rounded-none bg-transparent border border-transparent py-5 px-8 sm:px-12 md:px-16"
        }`}
      >
        <div className="w-full flex items-center justify-between">
          {/* Logo (left) */}
          <Link href="/" className="flex items-center gap-2.5 hover:opacity-85 transition-opacity flex-1 justify-start">
            <img src="/logo.png" alt="Genesis Logo" className="h-7 w-auto object-contain" />
            <span className={`text-[17px] font-bold tracking-tight select-none transition-colors duration-300 ${
              isScrolled ? 'text-slate-900' : 'text-white'
            }`}>
              Genesis
            </span>
          </Link>

          {/* Nav Links (center, hidden on mobile/tablet below md) */}
          <nav className="hidden md:flex items-center gap-8 justify-center">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              const textColor = isScrolled 
                ? (isActive ? "text-slate-900 font-bold" : "text-slate-600/95 hover:text-slate-900 font-medium")
                : (isActive ? "text-white font-bold" : "text-white/80 hover:text-white font-medium");
                
              return (
                <Link
                  key={link.label}
                  href={link.href}
                  className={`text-[14px] transition-all duration-200 relative py-1 ${textColor}`}
                >
                  {link.label}
                  {isActive && (
                    <div className={`h-[2px] w-full absolute bottom-0 left-0 rounded-full animate-fade-up ${
                      isScrolled ? 'bg-slate-900' : 'bg-white'
                    }`} />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Action Buttons (right) */}
          <div className="flex items-center gap-3 flex-1 justify-end">
            {/* Admin Portal Key Icon CTA */}
            <Link
              href="/admin/login"
              onClick={handleAdminClick}
              className={`hidden sm:flex items-center justify-center rounded-xl p-2.5 border transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer select-none ${
                isScrolled
                  ? 'border-slate-200 bg-white hover:bg-slate-50 shadow-sm'
                  : 'border-white/20 bg-white/10 hover:bg-white/20 backdrop-blur-md shadow-sm'
              }`}
              title="Portal Admin"
            >
              <Key className={`h-4.5 w-4.5 transition-colors duration-300 ${isScrolled ? 'text-slate-800' : 'text-white'}`} />
            </Link>

            {/* Download App CTA button */}
            <a
              href="https://storage.googleapis.com/arisa-opsi-bucket-2026/app-arm64-v8a-release.apk"
              className={`flex items-center gap-2 rounded-xl p-1 pr-3 sm:pr-4 shadow-sm hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none ${
                isScrolled ? 'bg-slate-50' : 'bg-white'
              }`}
            >
              <div className="flex items-center justify-center h-7.5 w-7.5 rounded-lg bg-navy-900">
                <Download className="h-[15px] w-[15px] text-white" strokeWidth={2.2} />
              </div>
              <span className="text-xs font-semibold text-slate-900 md:inline hidden">
                Download App
              </span>
              <span className="text-xs font-semibold text-slate-900 md:hidden inline">
                Get App
              </span>
            </a>

            {/* Mobile menu toggle */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className={`flex items-center justify-center h-9.5 w-9.5 rounded-xl md:hidden hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer ${
                isScrolled ? 'bg-slate-50 text-slate-900' : 'liquid-glass text-white'
              }`}
              aria-label="Toggle Menu"
            >
              {isMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
          </div>
        </div>

        {/* Mobile nav dropdown */}
        {isMenuOpen && (
          <div className="md:hidden w-full mt-2 animate-fade-up">
            <div className={`rounded-2xl p-2.5 flex flex-col gap-1.5 shadow-xl border ${
              isScrolled 
                ? 'bg-white/95 border-slate-100' 
                : 'bg-navy-900/95 backdrop-blur-md border-white/10'
            }`}>
              {navLinks.map((link) => {
                const isActive = pathname === link.href;
                const textColor = isScrolled
                  ? (isActive ? "text-slate-900 font-bold bg-slate-50" : "text-slate-650 hover:bg-slate-50 font-light")
                  : (isActive ? "text-white font-bold bg-white/10" : "text-white/80 hover:bg-white/10 font-light");
                  
                return (
                  <Link
                    key={link.label}
                    href={link.href}
                    onClick={() => setIsMenuOpen(false)}
                    className={`rounded-xl px-4 py-3 text-[14px] transition-colors duration-200 ${textColor}`}
                  >
                    {link.label}
                  </Link>
                );
              })}
              
              {/* Divider */}
              <div className={`h-[1px] my-1 ${isScrolled ? 'bg-slate-100' : 'bg-white/10'}`} />
              
              {/* Admin Portal in mobile drawer */}
              <Link
                href="/admin/login"
                onClick={handleAdminClick}
                className={`rounded-xl px-4 py-3 text-[14px] font-semibold flex items-center justify-center gap-2 transition-all duration-200 border ${
                  isScrolled
                    ? 'border-slate-200 bg-slate-50 text-slate-800 hover:bg-slate-100'
                    : 'border-white/20 bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                <Key className={`h-4.5 w-4.5 shrink-0 transition-colors duration-300 ${isScrolled ? 'text-slate-800' : 'text-white'}`} />
                Portal Admin
              </Link>
            </div>
          </div>
        )}
      </header>
    </div>
  );
}
