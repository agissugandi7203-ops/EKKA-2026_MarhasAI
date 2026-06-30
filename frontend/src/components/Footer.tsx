"use client";

import { ArrowRight, GitBranch, Mail, MapPin, Download, ShieldCheck } from "lucide-react";
import Link from "next/link";

const APK_URL = "https://storage.googleapis.com/arisa-opsi-bucket-2026/apps/app-arm64-v8a-release.apk";

const navigationLinks = [
  { label: "Home", href: "/" },
  { label: "Features", href: "/features" },
  { label: "Solutions", href: "/solutions" },
  { label: "Services", href: "/services" },
  { label: "Contact", href: "/contact" },
];

const resourceLinks = [
  { label: "API Documentation", href: "/docs" },
  { label: "Download App", href: APK_URL, external: true },
  { label: "Admin Portal", href: "/admin/login" },
];

export default function Footer() {
  return (
    <footer className="relative border-t border-white/10 bg-[#060612]">
      <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
        <div className="grid grid-cols-1 gap-12 md:grid-cols-2 lg:grid-cols-4">
          {/* Brand */}
          <div className="lg:col-span-2">
            <div className="flex items-center gap-3 mb-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600">
                <ShieldCheck className="h-5 w-5 text-white" />
              </div>
              <span className="text-xl font-bold text-white tracking-tight">
                Genesis<span className="text-indigo-400">.id</span>
              </span>
            </div>
            <p className="max-w-md text-sm leading-relaxed text-white/50 mb-6">
              Platform pelaporan ekologis kota cerdas berbasis AI. Warga melaporkan masalah lingkungan,
              AI mengklasifikasi secara otomatis, dan pemerintah kota menerima data spasial tervalidasi
              untuk pengambilan kebijakan yang lebih cepat.
            </p>
            <div className="flex items-center gap-4">
              <a
                href="https://github.com/agissugandi7203-ops"
                target="_blank"
                rel="noreferrer noopener"
                className="flex h-9 w-9 items-center justify-center rounded-lg bg-white/5 text-white/40 transition-colors hover:bg-white/10 hover:text-white/80"
                aria-label="GitHub"
              >
                <GitBranch className="h-4 w-4" />
              </a>
              <a
                href="mailto:genesis.id@support.com"
                className="flex h-9 w-9 items-center justify-center rounded-lg bg-white/5 text-white/40 transition-colors hover:bg-white/10 hover:text-white/80"
                aria-label="Email"
              >
                <Mail className="h-4 w-4" />
              </a>
              <a
                href="#"
                className="flex h-9 w-9 items-center justify-center rounded-lg bg-white/5 text-white/40 transition-colors hover:bg-white/10 hover:text-white/80"
                aria-label="Location"
              >
                <MapPin className="h-4 w-4" />
              </a>
            </div>
          </div>

          {/* Navigation */}
          <div>
            <h3 className="mb-4 text-xs font-semibold uppercase tracking-widest text-white/30">
              Navigation
            </h3>
            <ul className="space-y-3">
              {navigationLinks.map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="group flex items-center gap-2 text-sm text-white/50 transition-colors hover:text-white"
                  >
                    <ArrowRight className="h-3 w-3 opacity-0 -translate-x-2 transition-all group-hover:opacity-100 group-hover:translate-x-0" />
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="mb-4 text-xs font-semibold uppercase tracking-widest text-white/30">
              Resources
            </h3>
            <ul className="space-y-3">
              {resourceLinks.map((link) => (
                <li key={link.href}>
                  {link.external ? (
                    <a
                      href={link.href}
                      target="_blank"
                      rel="noreferrer noopener"
                      className="group flex items-center gap-2 text-sm text-white/50 transition-colors hover:text-white"
                    >
                      <Download className="h-3 w-3 opacity-60" />
                      {link.label}
                    </a>
                  ) : (
                    <Link
                      href={link.href}
                      className="group flex items-center gap-2 text-sm text-white/50 transition-colors hover:text-white"
                    >
                      <ArrowRight className="h-3 w-3 opacity-0 -translate-x-2 transition-all group-hover:opacity-100 group-hover:translate-x-0" />
                      {link.label}
                    </Link>
                  )}
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="mt-16 flex flex-col items-center justify-between gap-4 border-t border-white/5 pt-8 sm:flex-row">
          <p className="text-xs text-white/30">
            © {new Date().getFullYear()} Genesis.id Hub · genesisHub.web.id
          </p>
          <p className="text-xs text-white/20">
            Powered by NestJS, Flutter & Next.js
          </p>
        </div>
      </div>
    </footer>
  );
}
