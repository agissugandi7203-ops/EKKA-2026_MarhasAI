"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Download, Menu, X } from "lucide-react";

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
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

  return (
    <div className={`fixed top-0 left-0 w-full z-50 flex justify-center pointer-events-none transition-all duration-500 ${isScrolled ? 'pt-4 px-4' : 'pt-0 px-0'}`}>
      <header 
        className={`pointer-events-auto w-full transition-all duration-500 flex flex-col gap-2 ${
          isScrolled 
            ? "max-w-5xl rounded-2xl bg-white/80 backdrop-blur-xl border border-black/5 shadow-[0_8px_32px_rgba(0,0,0,0.08)] py-3 px-4 sm:px-6" 
            : "max-w-7xl rounded-2xl bg-transparent border border-transparent py-5 px-4 sm:px-8"
        }`}
      >
        <div className="flex items-center justify-between w-full">
          {/* Logo (left) */}
          <Link href="/" className="flex items-center gap-2 hover:opacity-85 transition-opacity">
            <svg
              viewBox="0 0 256 256"
              className={`h-5 w-5 ${isScrolled ? 'fill-navy-900' : 'fill-white'}`}
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="M 256 256 L 128 256 C 198.692 256 256 198.692 256 128 C 256 57.308 198.692 0 128 0 C 57.308 0 0 57.308 0 128 C 0 198.692 57.308 256 128 256 L 0 256 L 0 0 L 256 0 Z M 128 104 C 141.255 104 152 114.745 152 128 C 152 141.255 141.255 152 128 152 C 114.745 152 104 141.255 104 128 C 104 114.745 114.745 104 128 104 Z" />
            </svg>
            <span className={`text-base font-medium tracking-tight select-none ${isScrolled ? 'text-navy-900' : 'text-white'}`}>
              Genesis.id
            </span>
          </Link>

          {/* Nav Links (center, hidden on mobile/tablet below md) */}
          <nav className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              const textColor = isScrolled 
                ? (isActive ? "text-navy-900 font-semibold" : "text-navy-800/70 hover:text-navy-900 font-light")
                : (isActive ? "text-white font-semibold" : "text-white/80 hover:text-white font-light");
                
              return (
                <Link
                  key={link.label}
                  href={link.href}
                  className={`text-sm transition-all duration-200 ${textColor}`}
                >
                  {link.label}
                  {isActive && (
                    <div className={`h-[2px] w-full mt-1 rounded-full animate-fade-up ${isScrolled ? 'bg-navy-900' : 'bg-white'}`} />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Action Buttons (right) */}
          <div className="flex items-center gap-2.5">
            {/* Admin Portal CTA */}
            <Link
              href="/admin/login"
              className={`hidden sm:flex items-center gap-2 rounded-xl py-1.5 px-3.5 border transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer select-none text-xs font-semibold ${
                isScrolled
                  ? 'border-navy-200 bg-white text-navy-900 hover:bg-navy-50 shadow-sm'
                  : 'border-white/20 bg-white/10 text-white hover:bg-white/20 backdrop-blur-md shadow-sm'
              }`}
            >
              Admin Portal
            </Link>

            {/* Download App CTA button */}
            <a
              href="#"
              className={`flex items-center gap-2 rounded-xl p-1 pr-3 sm:pr-4 shadow-sm hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none ${
                isScrolled ? 'bg-navy-50' : 'bg-white'
              }`}
            >
              <div className="flex items-center justify-center h-7 w-7 rounded-lg bg-navy-900">
                <Download className="h-3.5 w-3.5 text-white" strokeWidth={2.2} />
              </div>
              <span className="text-xs font-semibold text-navy-900 md:inline hidden">
                Download App
              </span>
              <span className="text-xs font-semibold text-navy-900 md:hidden inline">
                Get App
              </span>
            </a>

            {/* Mobile menu toggle */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className={`flex items-center justify-center h-9 w-9 rounded-xl md:hidden hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer ${
                isScrolled ? 'bg-navy-50 text-navy-900' : 'liquid-glass text-white'
              }`}
              aria-label="Toggle Menu"
            >
              {isMenuOpen ? <X className="h-4.5 w-4.5" /> : <Menu className="h-4.5 w-4.5" />}
            </button>
          </div>
        </div>

        {/* Mobile nav dropdown */}
        {isMenuOpen && (
          <div className="md:hidden w-full mt-2 animate-fade-up">
            <div className={`rounded-2xl p-2 flex flex-col gap-1 shadow-xl border ${
              isScrolled 
                ? 'bg-white border-black/5' 
                : 'bg-navy-900/90 backdrop-blur-md border-white/10'
            }`}>
              {navLinks.map((link) => {
                const isActive = pathname === link.href;
                const textColor = isScrolled
                  ? (isActive ? "text-navy-900 font-semibold bg-navy-50" : "text-navy-800/80 hover:bg-navy-50 font-light")
                  : (isActive ? "text-white font-semibold bg-white/10" : "text-white/80 hover:bg-white/10 font-light");
                  
                return (
                  <Link
                    key={link.label}
                    href={link.href}
                    onClick={() => setIsMenuOpen(false)}
                    className={`rounded-xl px-4 py-3 text-sm transition-colors duration-200 ${textColor}`}
                  >
                    {link.label}
                  </Link>
                );
              })}
              
              {/* Divider */}
              <div className={`h-[1px] my-1 ${isScrolled ? 'bg-navy-100/50' : 'bg-white/10'}`} />
              
              {/* Admin Portal in mobile drawer */}
              <Link
                href="/admin/login"
                onClick={() => setIsMenuOpen(false)}
                className={`rounded-xl px-4 py-3 text-sm font-semibold text-center transition-all duration-200 border ${
                  isScrolled
                    ? 'border-navy-200 bg-navy-50 text-navy-900 hover:bg-navy-100'
                    : 'border-white/20 bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                Admin Portal
              </Link>
            </div>
          </div>
        )}
      </header>
    </div>
  );
}
