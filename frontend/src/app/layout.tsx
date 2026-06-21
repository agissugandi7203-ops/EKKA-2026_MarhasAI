import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Genesis.id Hub - Smart City Citizen Portal",
  description: "Official smart city management portal. Connecting citizens and local authorities through AI-powered report classification, gamification, and real-time dashboard analytics.",
  keywords: ["smart city", "genesis.id", "citizen reports", "AI classification", "city dashboard"],
  manifest: "/manifest.json",
  verification: {
    google: "googlee4a64ab1a21f7c0d",
  },
  openGraph: {
    title: "Genesis.id Hub - Smart City Citizen Portal",
    description: "Official smart city management portal. Connecting citizens and local authorities through AI-powered report classification, gamification, and real-time dashboard analytics.",
    url: "https://genesisHub.web.id",
    siteName: "Genesis.id Hub",
    locale: "id_ID",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Genesis.id Hub - Smart City Citizen Portal",
    description: "Official smart city management portal.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Genesis.id Hub",
    "url": "https://genesisHub.web.id",
    "logo": "https://genesisHub.web.id/next.svg",
    "description": "Genesis.id Hub is a multi-platform smart city portal connecting citizens with administrative dashboards and AI-powered report processing.",
    "sameAs": [
      "https://github.com/agissugandi7203-ops/front_end"
    ]
  };

  return (
    <html lang="en" className={`${geistSans.variable} ${geistMono.variable}`}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
