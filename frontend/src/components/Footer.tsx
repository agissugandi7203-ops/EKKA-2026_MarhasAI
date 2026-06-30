"use client";

import React, { useState } from "react";
import { Globe } from "lucide-react";

export default function Footer() {
  const [newsletterEmail, setNewsletterEmail] = useState<string>("");
  const [newsletterSubscribed, setNewsletterSubscribed] = useState<boolean>(false);

  const handleNewsletterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newsletterEmail) {
      setNewsletterSubscribed(true);
      setNewsletterEmail("");
      setTimeout(() => setNewsletterSubscribed(false), 4000);
    }
  };

  return (
    <footer className="w-full bg-slate-50 text-slate-600 py-20 px-6 sm:px-8 border-t border-slate-200/60 relative z-10 select-none">
      <div className="max-w-6xl w-full mx-auto flex flex-col gap-16">
        
        {/* Top row: Brand & Column Links */}
        <div className="grid grid-cols-2 md:grid-cols-6 gap-10">
          
          {/* Column 1: Brand Info & Status (Takes 2 cols) */}
          <div className="col-span-2 flex flex-col gap-4.5">
            <div className="flex items-center gap-2.5">
              <img src="/logo.png" alt="Genesis Logo" className="h-7.5 w-auto object-contain" />
              <span className="text-[19px] font-bold text-slate-900 tracking-tight">Genesis</span>
            </div>
            <p className="text-xs font-light text-slate-500 max-w-sm leading-relaxed">
              Consolidated smart city crowdsourcing platform and municipal ecological governance console. Re-engineered for maximum accountability.
            </p>
            
            {/* Dynamic Status Indicator */}
            <div className="flex items-center gap-2.5 mt-2 bg-white border border-slate-200/70 px-3.5 py-2 rounded-xl w-fit shadow-[0_2px_8px_rgba(0,0,0,0.01)]">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
              </span>
              <span className="text-[10px] font-semibold text-slate-600 uppercase tracking-wider font-mono">
                All Systems Operational
              </span>
            </div>
          </div>

          {/* Column 2: Platform Links */}
          <div className="flex flex-col gap-3.5">
            <h4 className="text-xs font-bold text-slate-900 tracking-wider uppercase">Platform</h4>
            <ul className="flex flex-col gap-2.5 text-xs font-light text-slate-500">
              <li><a href="/#features" className="hover:text-slate-900 transition-colors duration-150">Features</a></li>
              <li><a href="/#ecosystem" className="hover:text-slate-900 transition-colors duration-150">Ecosystem</a></li>
              <li><a href="/solutions" className="hover:text-slate-900 transition-colors duration-150">Solutions</a></li>
              <li><a href="/services" className="hover:text-slate-900 transition-colors duration-150">Services</a></li>
            </ul>
          </div>

          {/* Column 3: Resources Links */}
          <div className="flex flex-col gap-3.5">
            <h4 className="text-xs font-bold text-slate-900 tracking-wider uppercase">Resources</h4>
            <ul className="flex flex-col gap-2.5 text-xs font-light text-slate-500">
              <li><a href="/docs" className="hover:text-slate-900 transition-colors duration-150">API Reference</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Community</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Guides & Docs</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Open Source</a></li>
            </ul>
          </div>

          {/* Column 4: Company Links */}
          <div className="flex flex-col gap-3.5">
            <h4 className="text-xs font-bold text-slate-900 tracking-wider uppercase">Company</h4>
            <ul className="flex flex-col gap-2.5 text-xs font-light text-slate-500">
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">About Us</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Press Kit</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Careers</a></li>
              <li><a href="/contact" className="hover:text-slate-900 transition-colors duration-150">Contact Us</a></li>
            </ul>
          </div>

          {/* Column 5: Governance Links */}
          <div className="flex flex-col gap-3.5">
            <h4 className="text-xs font-bold text-slate-900 tracking-wider uppercase">Governance</h4>
            <ul className="flex flex-col gap-2.5 text-xs font-light text-slate-500">
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Terms of Service</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Securities</a></li>
              <li><a href="#" className="hover:text-slate-900 transition-colors duration-150">Trust Center</a></li>
            </ul>
          </div>

        </div>

        {/* Divider */}
        <div className="h-[1px] bg-slate-200/60 w-full" />

        {/* Bottom row: Newsletter, Socials, & Copyright */}
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-10">
          
          {/* Newsletter Subscription */}
          <div className="flex flex-col gap-2.5 max-w-sm w-full">
            <h5 className="text-xs font-bold text-slate-900 uppercase tracking-wider">Join our ecosystem updates</h5>
            <p className="text-[11px] text-slate-500 font-light">The latest municipal technology releases, sent bi-weekly.</p>
            
            <form onSubmit={handleNewsletterSubmit} className="flex gap-2 mt-1.5">
              <input
                type="email"
                value={newsletterEmail}
                onChange={(e) => setNewsletterEmail(e.target.value)}
                placeholder="name@email.com"
                className="flex-1 bg-white border border-slate-200 rounded-xl px-3.5 py-2 text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:border-slate-350 transition-colors shadow-sm"
                required
                disabled={newsletterSubscribed}
              />
              <button
                type="submit"
                disabled={newsletterSubscribed}
                className="bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold px-4 py-2 rounded-xl transition-all duration-150 hover:scale-[1.03] active:scale-95 cursor-pointer disabled:opacity-50"
              >
                {newsletterSubscribed ? "Subscribed!" : "Subscribe"}
              </button>
            </form>
          </div>

          {/* Social Links & Copyright */}
          <div className="flex flex-col gap-4.5 items-start md:items-end w-full md:w-auto">
            <div className="flex items-center gap-4 text-slate-400">
              {/* GitHub Social */}
              <a 
                href="https://github.com/agissugandi7203-ops/front_end" 
                target="_blank" 
                rel="noreferrer"
                className="hover:text-slate-800 transition-colors p-1"
                aria-label="GitHub Repository"
              >
                <svg className="h-5 w-5 fill-current" viewBox="0 0 24 24">
                  <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.438 9.8 8.205 11.385.6.11.82-.26.82-.577v-2.234c-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.43.372.82 1.102.82 2.222v3.293c0 .319.22.694.825.576C20.565 21.795 24 17.3 24 12c0-6.63-5.37-12-12-12z" />
                </svg>
              </a>
              
              {/* Twitter / X Social */}
              <a 
                href="#" 
                className="hover:text-slate-800 transition-colors p-1"
                aria-label="Twitter X Link"
              >
                <svg className="h-4.5 w-4.5 fill-current" viewBox="0 0 24 24">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              </a>

              {/* Discord / Chat Social */}
              <a 
                href="#" 
                className="hover:text-slate-800 transition-colors p-1"
                aria-label="Discord Chat Link"
              >
                <svg className="h-5 w-5 fill-current" viewBox="0 0 127.14 96.36">
                  <path d="M107.7,8.07A105.15,105.15,0,0,0,77.26,0a77.19,77.19,0,0,0-3.3,6.83A96.67,96.67,0,0,0,53.22,6.83,77.19,77.19,0,0,0,49.88,0,105.15,105.15,0,0,0,19.44,8.07C3.66,31.58-1.86,54.65,1,77.53A105.73,105.73,0,0,0,32,96.36a77.7,77.7,0,0,0,6.63-10.85,68.43,68.43,0,0,1-10.45-5c.87-.64,1.72-1.31,2.53-2a75.46,75.46,0,0,0,72.9,0c.81.71,1.66,1.38,2.53,2a68.43,68.43,0,0,1-10.45,5,77.7,77.7,0,0,0,6.63,10.85,105.73,105.73,0,0,0,31.06-18.83C129,54.65,123.5,31.58,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53S36.18,40.36,42.45,40.36,53.83,46,53.83,53,48.72,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.24,60,73.24,53S78.41,40.36,84.69,40.36,96.07,46,96.07,53,91,65.69,84.69,65.69Z" />
                </svg>
              </a>
            </div>
            
            <div className="flex flex-col gap-3">
              {/* Team Credit */}
              <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-[10px] text-slate-400">
                <span className="font-semibold text-slate-500">SMK Marhas Margahayu</span>
                <span className="text-slate-300">·</span>
                <span>LKS Dikdasmen 2026</span>
                <span className="text-slate-300">·</span>
                <span>Arief Faja Reza Arrofi</span>
                <span className="text-slate-300">&</span>
                <span>Alysia Fasma Nidai</span>
              </div>
              <div className="text-[10px] text-slate-400 flex flex-col sm:flex-row gap-2 sm:gap-4.5">
                <span>&copy; {new Date().getFullYear()} Genesis Project. All rights reserved.</span>
                <span className="hidden sm:inline">|</span>
                <span className="flex items-center gap-1">
                  <Globe className="h-3 w-3 text-slate-400" />
                  Margahayu, Bandung — Indonesia
                </span>
              </div>
            </div>
          </div>

        </div>

      </div>
    </footer>
  );
}
