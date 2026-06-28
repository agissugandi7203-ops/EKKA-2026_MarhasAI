"use client";
import React, { useState, useEffect } from "react";
import BoomerangVideoBg from "@/components/BoomerangVideoBg";
import Header from "@/components/Header";
import {
  ShieldCheck,
  ArrowRight,
  Terminal,
  Code2,
  Database,
  MapPin,
  Activity,
  Copy,
  Check,
  Play,
  RefreshCw,
  Sliders,
  Layers,
  Globe,
  FileText,
  AlertTriangle,
  Eye,
  EyeOff
} from "lucide-react";

export default function Documentation() {
  // Sandbox State
  const [endpoint, setEndpoint] = useState("/reports"); // "/reports" or "/summary"
  const [apiKey, setApiKey] = useState("genesis_trial_key_2026");
  const [showApiKey, setShowApiKey] = useState(false);
  
  // Filters
  const [cityOrDistrict, setCityOrDistrict] = useState("");
  const [status, setStatus] = useState("");
  const [wasteType, setWasteType] = useState("");
  const [dangerLevel, setDangerLevel] = useState("");
  const [limit, setLimit] = useState(10);

  // Dynamic Cities list from backend
  const [citiesList, setCitiesList] = useState<string[]>([]);

  useEffect(() => {
    const fetchCities = async () => {
      try {
        const res = await fetch("https://genesisHub.my.id/b2g/cities", {
          method: "GET",
          headers: {
            "x-api-key": apiKey || "genesis_trial_key_2026",
            "Accept": "application/json",
          },
        });
        if (res.ok) {
          const data = await res.json();
          if (Array.isArray(data)) {
            const cleaned = data.filter(Boolean).sort();
            setCitiesList(cleaned);
            return;
          }
        }
      } catch (err: any) {
        console.warn("Failed to fetch cities from backend, using defaults:", err.message);
      }
      // Fallback to defaults if backend is offline/CORS blocked/unreachable
      setCitiesList(["Kota Surabaya", "Kabupaten Sidoarjo", "Kabupaten Gresik", "Kota Malang"]);
    };

    fetchCities();
  }, [apiKey]);

  // Client Execution
  const [loading, setLoading] = useState(false);
  const [responseJson, setResponseJson] = useState<any>(null);
  const [isMocked, setIsMocked] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Code Tab
  const [codeTab, setCodeTab] = useState<"curl" | "javascript" | "python" | "dart">("curl");
  const [copied, setCopied] = useState(false);

  // Handle auto-scroll to Sandbox
  const scrollToSandbox = () => {
    const element = document.getElementById("sandbox-studio");
    if (element) {
      element.scrollIntoView({ behavior: "smooth" });
    }
  };

  // Generate dynamic query string
  const getQueryString = () => {
    const params = [];
    if (cityOrDistrict) params.push(`city_or_district=${encodeURIComponent(cityOrDistrict)}`);
    if (status) params.push(`status=${status}`);
    if (wasteType) params.push(`waste_type=${encodeURIComponent(wasteType)}`);
    if (dangerLevel) params.push(`danger_level=${encodeURIComponent(dangerLevel)}`);
    if (limit && endpoint === "/reports") params.push(`limit=${limit}`);
    
    // Summary endpoint also supports city sifting
    if (cityOrDistrict && endpoint === "/summary") {
      return `?city_or_district=${encodeURIComponent(cityOrDistrict)}`;
    }

    return params.length > 0 ? `?${params.join("&")}` : "";
  };

  const productionBaseUrl = "https://genesisHub.my.id";
  const displayUrl = `${productionBaseUrl}/b2g${endpoint}${getQueryString()}`;

  // Run Sandbox Request
  const runRequest = async () => {
    setLoading(true);
    setError(null);
    setIsMocked(false);
    setResponseJson(null);

    // Build URL
    const baseUrl = "https://genesisHub.my.id";
    const endpointUrl = `${baseUrl}/b2g${endpoint}${getQueryString()}`;

    try {
      const res = await fetch(endpointUrl, {
        method: "GET",
        headers: {
          "x-api-key": apiKey || "genesis_trial_key_2026",
        },
      });

      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText || "Unauthorized"}`);
      }

      const data = await res.json();
      setResponseJson(data);
    } catch (err: any) {
      console.warn("DaaS sandbox: offline or block. Running emulator backup:", err.message);
      // Fallback emulator dataset
      setIsMocked(true);
      await new Promise((resolve) => setTimeout(resolve, 800)); // Simulate networking
      
      if (endpoint === "/reports") {
        setResponseJson([
          {
            id: "rep_9a7d3c2b-e48f-410a-b32c-9856a2e482ff",
            image_url: "https://storage.googleapis.com/genesis-id-report/reports/usr_01/17822935_blurred.jpg",
            description: "Tumpukan limbah botol plastik menyumbat aliran drainase sungai kecil.",
            location: {
              type: "Point",
              coordinates: [112.7508, -7.2575]
            },
            coordinates: {
              latitude: -7.2575,
              longitude: 112.7508
            },
            status: status || "approved",
            confidence_score: 94.2,
            waste_type: wasteType || "Plastik",
            danger_level: dangerLevel || "Sedang",
            created_at: new Date(Date.now() - 3600000 * 2).toISOString(),
            updated_at: new Date(Date.now() - 3600000).toISOString(),
            region: {
              province: "Jawa Timur",
              city_or_district: cityOrDistrict || "Kota Surabaya"
            },
            reporter: {
              id: "usr_8fa291b8-c38d-4e9a-9e1d-88f1723ac922",
              username: "eko_guardian_99",
              full_name: "Eko Prasetyo"
            }
          },
          {
            id: "rep_2c9f8a4b-12ea-4cfb-81bd-385aef915b82",
            image_url: "https://storage.googleapis.com/genesis-id-report/reports/usr_02/17822941_blurred.jpg",
            description: "Limbah industri rumah tangga berupa oli bekas dibuang sembarangan.",
            location: {
              type: "Point",
              coordinates: [112.7915, -7.2792]
            },
            coordinates: {
              latitude: -7.2792,
              longitude: 112.7915
            },
            status: status || "pending_ai",
            confidence_score: 87.8,
            waste_type: wasteType || "B3",
            danger_level: dangerLevel || "Tinggi",
            created_at: new Date(Date.now() - 3600000 * 8).toISOString(),
            updated_at: new Date(Date.now() - 3600000 * 8).toISOString(),
            region: {
              province: "Jawa Timur",
              city_or_district: cityOrDistrict || "Kota Surabaya"
            },
            reporter: {
              id: "usr_f72c91a0-41da-401f-b328-ea2179836109",
              username: "riani_smart_city",
              full_name: "Riani Lestari"
            }
          }
        ].slice(0, limit ? Number(limit) : 2));
      } else {
        // Summary Mock
        setResponseJson({
          metadata: {
            timestamp: new Date().toISOString(),
            city_filtered: cityOrDistrict || "ALL_REGIONS",
            data_provider: "Genesis.id DaaS Platform (Sandbox Emulator)"
          },
          summary: {
            total_reports: cityOrDistrict ? 42 : 158,
            by_status: {
              pending_ai: cityOrDistrict ? 3 : 15,
              approved: cityOrDistrict ? 25 : 94,
              resolved: cityOrDistrict ? 12 : 44,
              rejected: cityOrDistrict ? 2 : 5
            },
            by_severity: {
              Rendah: cityOrDistrict ? 15 : 52,
              Sedang: cityOrDistrict ? 20 : 76,
              Tinggi: cityOrDistrict ? 7 : 30
            },
            by_waste_type: {
              Plastik: cityOrDistrict ? 18 : 64,
              Organik: cityOrDistrict ? 12 : 42,
              B3: cityOrDistrict ? 5 : 22,
              Lainnya: cityOrDistrict ? 7 : 30
            },
            by_region: cityOrDistrict ? { [cityOrDistrict]: 42 } : {
              "Kota Surabaya": 58,
              "Kabupaten Sidoarjo": 32,
              "Kabupaten Gresik": 26,
              "Kota Malang": 42
            }
          }
        });
      }
    } finally {
      setLoading(false);
    }
  };

  // Generate dynamic code integration snippets
  const getCodeSnippet = () => {
    const key = apiKey || "genesis_trial_key_2026";
    switch (codeTab) {
      case "curl":
        return `curl -X GET "${displayUrl}" \\
  -H "x-api-key: ${key}" \\
  -H "Accept: application/json"`;
      case "javascript":
        return `fetch("${displayUrl}", {
  method: "GET",
  headers: {
    "x-api-key": "${key}",
    "Accept": "application/json"
  }
})
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));`;
      case "python":
        return `import requests

url = "${displayUrl}"
headers = {
    "x-api-key": "${key}",
    "Accept": "application/json"
}

response = requests.get(url, headers=headers)
if response.status_code == 200:
    data = response.json()
    print(data)
else:
    print(f"Error: {response.status_code}")`;
      case "dart":
        return `import 'package:dio/dio.dart';

void fetchB2gData() async {
  final dio = Dio();
  final url = "${displayUrl}";
  
  try {
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'x-api-key': '${key}',
          'Accept': 'application/json',
        },
      ),
    );
    print(response.data);
  } catch (e) {
    print('Error: $e');
  }
}`;
    }
  };

  // Trigger auto-copy snippet
  const copySnippet = () => {
    navigator.clipboard.writeText(getCodeSnippet());
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <main className="relative w-full min-h-screen bg-surface flex flex-col font-sans antialiased text-navy-900">
      
      {/* 1. Viewport-Height Hero Section */}
      <div className="relative w-full h-screen overflow-hidden flex flex-col justify-between">
        <BoomerangVideoBg src="/videos/docs.mp4" />
        {/* Dark overlay specifically requested for readability */}
        <div className="absolute inset-0 bg-black/55 z-10 pointer-events-none" />
        
        <div className="relative z-50">
          <Header />
        </div>
        
        <div className="relative z-20 flex-1 flex flex-col items-center text-center justify-center px-4 sm:px-6 max-w-7xl mx-auto w-full pb-24 sm:pb-32">
          <div className="liquid-glass rounded-lg px-4 py-1.5 text-xs sm:text-sm text-white animate-fade-up delay-1 mb-5 sm:mb-6 select-none" style={{ background: "rgba(255, 255, 255, 0.16)", backdropFilter: "blur(8px)" }}>
            B2G Integration Portal . Smart City API
          </div>
          <h1 className="max-w-4xl text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-normal leading-[1.1] text-white tracking-tight animate-fade-up delay-2 select-none drop-shadow-lg">
            Sovereign Data-as-a-Service
          </h1>
          <p className="mt-5 sm:mt-6 max-w-2xl text-sm sm:text-base md:text-lg leading-relaxed text-white/90 font-light animate-fade-up delay-3 select-none drop-shadow-md">
            Integrasi spasial real-time bagi instansi pemerintah dan smart city untuk memantau, mendeteksi, dan menanggulangi tumpukan sampah wilayah menggunakan API aman.
          </p>

          {/* Action Buttons */}
          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row-reverse items-center justify-center gap-4 animate-fade-up delay-4">
            <button 
              onClick={scrollToSandbox}
              className="flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-semibold text-navy-900 shadow-xl shadow-white/10 hover:scale-105 active:scale-95 transition-transform duration-200 cursor-pointer select-none"
            >
              API Sandbox
              <Terminal className="h-4.5 w-4.5 text-navy-900" />
            </button>
            <a 
              href="https://genesisHub.my.id/docs"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2 rounded-xl liquid-glass px-6 py-3.5 text-sm font-medium text-white hover:bg-white/10 border border-white/20 hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer select-none"
            >
              Swagger OpenAPI
              <ArrowRight className="h-4.5 w-4.5" />
            </a>
          </div>
        </div>
      </div>

      {/* 2. Overview cards section */}
      <section className="relative w-full bg-surface text-navy-900 py-16 px-4 sm:px-8 border-b border-navy-100">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-12">
            <span className="text-xs uppercase tracking-wider text-primary font-semibold">Enterprise DaaS Features</span>
            <h2 className="text-3xl sm:text-4xl font-light tracking-tight text-navy-900 mt-2">Infrastruktur Integrasi B2G</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-white p-6 rounded-2xl border border-navy-100 hover:border-primary/30 shadow-sm transition-all hover:shadow-md duration-300">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary mb-5">
                <Database className="h-6 w-6" />
              </div>
              <h3 className="text-lg font-medium text-navy-900 mb-2">Penyajian Geospasial</h3>
              <p className="text-sm text-navy-600 font-light leading-relaxed">
                Output data laporan yang ramah standar GIS (Point & koordinat desimal) memudahkan impor otomatis ke platform ArcGIS, QGIS, atau Smart City Dashboard.
              </p>
            </div>
            
            <div className="bg-white p-6 rounded-2xl border border-navy-100 hover:border-primary/30 shadow-sm transition-all hover:shadow-md duration-300">
              <div className="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600 mb-5">
                <ShieldCheck className="h-6 w-6" />
              </div>
              <h3 className="text-lg font-medium text-navy-900 mb-2">Autentikasi API Key</h3>
              <p className="text-sm text-navy-600 font-light leading-relaxed">
                Pengamanan rute menggunakan header `x-api-key` tersertifikasi yang diisolasi khusus per instansi guna membatasi penyalahgunaan data rahasia.
              </p>
            </div>
            
            <div className="bg-white p-6 rounded-2xl border border-navy-100 hover:border-primary/30 shadow-sm transition-all hover:shadow-md duration-300">
              <div className="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600 mb-5">
                <Activity className="h-6 w-6" />
              </div>
              <h3 className="text-lg font-medium text-navy-900 mb-2">Agregasi Statistik</h3>
              <p className="text-sm text-navy-600 font-light leading-relaxed">
                Endpoint summary membantu menyusun grafik pelaporan mingguan, saringan wilayah, tingkat keparahan, serta dominasi jenis limbah otomatis.
              </p>
            </div>
            
            <div className="bg-white p-6 rounded-2xl border border-navy-100 hover:border-primary/30 shadow-sm transition-all hover:shadow-md duration-300">
              <div className="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center text-orange-600 mb-5">
                <Layers className="h-6 w-6" />
              </div>
              <h3 className="text-lg font-medium text-navy-900 mb-2">In-Memory AI Sensing</h3>
              <p className="text-sm text-navy-600 font-light leading-relaxed">
                Data yang didistribusikan telah disensor dari data pribadi sensitif (plat nomor & wajah diblur via Google Vision API) demi mematuhi UU Pelindungan Data Pribadi (PDP).
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 3. API Sandbox & IDE Studio */}
      <section id="sandbox-studio" className="relative w-full bg-slate-50 py-24 px-4 sm:px-8 border-b border-navy-100">
        <div className="max-w-7xl mx-auto">
          
          <div className="flex flex-col lg:flex-row lg:items-end justify-between mb-10 gap-4">
            <div>
              <span className="text-xs uppercase tracking-wider text-primary font-semibold">Interactive Sandbox</span>
              <h2 className="text-3xl sm:text-4xl font-light tracking-tight text-navy-900 mt-2">DaaS Sandbox Studio</h2>
              <p className="text-sm sm:text-base text-navy-600 font-light mt-2 max-w-2xl">
                Sesuaikan filter query, buat kode integrasi multibahasa secara dinamis, dan jalankan request langsung ke backend Genesis.id di dalam terminal interaktif.
              </p>
            </div>
            <div className="flex items-center gap-2 text-xs bg-navy-50 text-navy-700 px-3 py-1.5 rounded-lg border border-navy-100 font-mono">
              <Globe className="h-3.5 w-3.5 text-primary animate-spin-slow" />
              Base URL: {productionBaseUrl}/b2g
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
            
            {/* Left Box: Controls (5 columns) */}
            <div className="lg:col-span-5 bg-white p-6 sm:p-8 rounded-2xl border border-navy-100 shadow-sm">
              <div className="flex items-center gap-2 text-navy-900 font-semibold mb-6 pb-4 border-b border-navy-50">
                <Sliders className="h-5 w-5 text-primary" />
                <span>Parameter Studio</span>
              </div>

              <div className="space-y-5">
                {/* API Key */}
                <div>
                  <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">API Authentication Key</label>
                  <div className="relative">
                    <input
                      type={showApiKey ? "text" : "password"}
                      value={apiKey}
                      onChange={(e) => setApiKey(e.target.value)}
                      placeholder="Masukkan x-api-key..."
                      className="w-full text-sm rounded-xl border border-navy-100 px-4 py-3 bg-slate-50/50 focus:outline-none focus:border-primary/50 font-mono tracking-wide pr-10"
                    />
                    <button
                      type="button"
                      onClick={() => setShowApiKey(!showApiKey)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-navy-400 hover:text-navy-600 transition-colors"
                    >
                      {showApiKey ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                  <p className="text-[11px] text-navy-500 font-light mt-1.5">
                    Gunakan trial key bawaan <span className="font-mono bg-navy-50 px-1 py-0.5 rounded text-navy-700">genesis_trial_key_2026</span> untuk mencoba.
                  </p>
                </div>

                {/* Endpoint Selection */}
                <div>
                  <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">DaaS API Endpoint</label>
                  <div className="grid grid-cols-2 gap-2 bg-slate-100 p-1 rounded-xl">
                    <button
                      onClick={() => setEndpoint("/reports")}
                      className={`py-2 text-xs font-medium rounded-lg transition-all ${endpoint === "/reports" ? "bg-white text-navy-900 shadow-sm font-semibold" : "text-navy-600 hover:text-navy-900"}`}
                    >
                      GET /reports
                    </button>
                    <button
                      onClick={() => setEndpoint("/summary")}
                      className={`py-2 text-xs font-medium rounded-lg transition-all ${endpoint === "/summary" ? "bg-white text-navy-900 shadow-sm font-semibold" : "text-navy-600 hover:text-navy-900"}`}
                    >
                      GET /summary
                    </button>
                  </div>
                </div>

                {/* City Sifter Filter */}
                <div>
                  <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">Filter Kota / Kabupaten</label>
                  <select
                    value={cityOrDistrict}
                    onChange={(e) => setCityOrDistrict(e.target.value)}
                    className="w-full text-sm rounded-xl border border-navy-100 px-4 py-3 bg-slate-50/50 focus:outline-none focus:border-primary/50"
                  >
                    <option value="">Semua Wilayah</option>
                    {citiesList.map((city) => (
                      <option key={city} value={city}>
                        {city}
                      </option>
                    ))}
                  </select>
                </div>

                {endpoint === "/reports" && (
                  <>
                    {/* Status Filter */}
                    <div>
                      <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">Status Laporan</label>
                      <select
                        value={status}
                        onChange={(e) => setStatus(e.target.value)}
                        className="w-full text-sm rounded-xl border border-navy-100 px-4 py-3 bg-slate-50/50 focus:outline-none focus:border-primary/50"
                      >
                        <option value="">Semua Status</option>
                        <option value="pending_ai">Pending AI Classification</option>
                        <option value="approved">Approved & Verified</option>
                        <option value="resolved">Resolved by Cleaner</option>
                        <option value="rejected">Rejected / Invalid</option>
                      </select>
                    </div>

                    {/* Waste Type Filter */}
                    <div>
                      <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">Jenis Sampah (AI Sensor)</label>
                      <select
                        value={wasteType}
                        onChange={(e) => setWasteType(e.target.value)}
                        className="w-full text-sm rounded-xl border border-navy-100 px-4 py-3 bg-slate-50/50 focus:outline-none focus:border-primary/50"
                      >
                        <option value="">Semua Kategori</option>
                        <option value="Plastik">Limbah Plastik</option>
                        <option value="Organik">Limbah Organik</option>
                        <option value="B3">B3 (Bahan Berbahaya)</option>
                        <option value="Lainnya">Lainnya</option>
                      </select>
                    </div>

                    {/* Severity Filter */}
                    <div>
                      <label className="block text-xs font-semibold text-navy-700 uppercase tracking-wider mb-2">Tingkat Bahaya / Keparahan</label>
                      <select
                        value={dangerLevel}
                        onChange={(e) => setDangerLevel(e.target.value)}
                        className="w-full text-sm rounded-xl border border-navy-100 px-4 py-3 bg-slate-50/50 focus:outline-none focus:border-primary/50"
                      >
                        <option value="">Semua Keparahan</option>
                        <option value="Rendah">Rendah</option>
                        <option value="Sedang">Sedang</option>
                        <option value="Tinggi">Tinggi</option>
                      </select>
                    </div>

                    {/* Limit Filter */}
                    <div>
                      <div className="flex justify-between items-center mb-2">
                        <label className="text-xs font-semibold text-navy-700 uppercase tracking-wider">Limit Output Data</label>
                        <span className="text-xs font-semibold text-primary font-mono">{limit} rows</span>
                      </div>
                      <input
                        type="range"
                        min="1"
                        max="50"
                        value={limit}
                        onChange={(e) => setLimit(Number(e.target.value))}
                        className="w-full h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-primary"
                      />
                    </div>
                  </>
                )}

                {/* Execute Button */}
                <button
                  onClick={runRequest}
                  disabled={loading}
                  className="w-full mt-6 flex items-center justify-center gap-2 bg-navy-900 hover:bg-navy-800 disabled:bg-navy-600 text-white font-semibold text-sm rounded-xl py-3.5 shadow-lg shadow-navy-900/10 active:scale-98 hover:scale-[1.01] transition-all cursor-pointer"
                >
                  {loading ? (
                    <>
                      <RefreshCw className="h-4 w-4 animate-spin text-white" />
                      Mengekstraksi Data Spasial...
                    </>
                  ) : (
                    <>
                      <Play className="h-4 w-4 fill-white text-white" />
                      Jalankan Request Sandbox
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* Right Box: Code snippets + Live Terminal (7 columns) */}
            <div className="lg:col-span-7 flex flex-col gap-6 w-full">
              
              {/* SDK Snippets Panel */}
              <div className="bg-navy-950 rounded-2xl overflow-hidden shadow-md border border-navy-900">
                <div className="flex items-center justify-between px-5 py-3.5 bg-navy-900 border-b border-navy-800">
                  <div className="flex items-center gap-2 text-white text-xs font-semibold tracking-wider uppercase font-mono">
                    <Code2 className="h-4 w-4 text-primary" />
                    <span>Integrasi API SDK</span>
                  </div>
                  <button
                    onClick={copySnippet}
                    className="flex items-center gap-1.5 text-navy-300 hover:text-white transition-colors text-xs font-medium bg-navy-800/60 hover:bg-navy-800 px-2.5 py-1 rounded-lg border border-navy-700/50"
                  >
                    {copied ? (
                      <>
                        <Check className="h-3.5 w-3.5 text-emerald-400" />
                        <span className="text-emerald-400 font-semibold font-mono">Copied!</span>
                      </>
                    ) : (
                      <>
                        <Copy className="h-3.5 w-3.5" />
                        <span className="font-mono">Copy Code</span>
                      </>
                    )}
                  </button>
                </div>

                {/* Code Tabs */}
                <div className="flex bg-navy-900/40 px-3 py-1 border-b border-navy-800/60 gap-1 font-mono text-[11px]">
                  {(["curl", "javascript", "python", "dart"] as const).map((tab) => (
                    <button
                      key={tab}
                      onClick={() => setCodeTab(tab)}
                      className={`px-3 py-1.5 rounded-md transition-colors ${codeTab === tab ? "bg-navy-800 text-white font-semibold" : "text-navy-400 hover:text-navy-200"}`}
                    >
                      {tab === "curl" ? "cURL" : tab === "javascript" ? "JavaScript" : tab === "python" ? "Python" : "Dart (Dio)"}
                    </button>
                  ))}
                </div>

                {/* Code Editor Body */}
                <div className="p-5 font-mono text-xs text-navy-200 overflow-x-auto whitespace-pre leading-relaxed bg-navy-950 max-h-56 scrollbar-thin">
                  {getCodeSnippet()}
                </div>
              </div>

              {/* Terminal Panel */}
              <div className="bg-slate-900 rounded-2xl overflow-hidden shadow-md border border-slate-800 flex-1 flex flex-col min-h-[380px]">
                <div className="flex items-center justify-between px-5 py-3.5 bg-slate-900 border-b border-slate-800">
                  <div className="flex items-center gap-2">
                    {/* Console window buttons */}
                    <div className="flex gap-1.5">
                      <div className="w-3 h-3 rounded-full bg-rose-500"></div>
                      <div className="w-3 h-3 rounded-full bg-amber-500"></div>
                      <div className="w-3 h-3 rounded-full bg-emerald-500"></div>
                    </div>
                    <span className="text-slate-400 font-mono text-[11px] ml-2">DaaS_Interactive_Terminal.sh</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-[10px] uppercase font-mono tracking-widest text-slate-500">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    <span>ONLINE RESPONSE</span>
                  </div>
                </div>

                {/* Live Console Output Body */}
                <div className="p-5 font-mono text-[11px] sm:text-xs text-emerald-400 flex-1 overflow-y-auto max-h-[350px] scrollbar-thin bg-black/90 leading-normal">
                  {loading && (
                    <div className="flex flex-col items-center justify-center h-full text-slate-400 gap-3 py-16">
                      <RefreshCw className="h-6 w-6 animate-spin text-primary" />
                      <span className="animate-pulse font-mono">CONNECTING TO GEOSPATIAL DATABASE...</span>
                    </div>
                  )}

                  {!loading && !responseJson && !error && (
                    <div className="flex flex-col items-center justify-center h-full text-slate-500 text-center gap-3 py-16 select-none font-light leading-relaxed">
                      <Terminal className="h-8 w-8 text-slate-600 animate-pulse" />
                      <div>
                        <p>Terminal siap.</p>
                        <p className="text-[11px] text-slate-600 mt-1">Konfigurasi parameter di kiri lalu klik "Jalankan Request Sandbox" untuk melihat data live.</p>
                      </div>
                    </div>
                  )}

                  {!loading && error && (
                    <div className="flex items-start gap-2.5 text-rose-400">
                      <AlertTriangle className="h-4.5 w-4.5 text-rose-500 flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="font-semibold uppercase tracking-wider">ERROR RESPONSE:</p>
                        <p className="mt-1 font-mono text-rose-300">{error}</p>
                      </div>
                    </div>
                  )}

                  {!loading && responseJson && (
                    <div className="h-full">
                      {isMocked && (
                        <div className="mb-4 bg-amber-950/40 text-amber-300 px-3.5 py-2.5 rounded-xl border border-amber-900/60 text-[11px] leading-relaxed flex items-start gap-2">
                          <AlertTriangle className="h-4.5 w-4.5 text-amber-500 flex-shrink-0 mt-0.5" />
                          <div>
                            <span className="font-bold uppercase block mb-0.5">SANDBOX EMULATOR MODE ACTIVE</span>
                            Tidak dapat terhubung langsung ke server lokal (DaaS Offline). Menampilkan data tiruan fidelitas tinggi (*high-fidelity emulator backup*) yang memiliki skema identik dengan data produksi.
                          </div>
                        </div>
                      )}
                      <pre className="text-emerald-400 whitespace-pre scrollbar-none font-mono">
                        {JSON.stringify(responseJson, null, 2)}
                      </pre>
                    </div>
                  )}
                </div>
              </div>

            </div>
          </div>
        </div>
      </section>

      {/* 4. Structured Endpoint Specs Tables */}
      <section className="relative w-full bg-white py-24 px-4 sm:px-8 border-b border-navy-100">
        <div className="max-w-4xl mx-auto">
          <div className="mb-16">
            <span className="text-xs uppercase tracking-wider text-primary font-semibold">Technical Specifications</span>
            <h2 className="text-3xl sm:text-4xl font-light tracking-tight text-navy-900 mt-1">Spesifikasi Schema DaaS</h2>
            <p className="text-sm sm:text-base text-navy-600 font-light mt-2 leading-relaxed">
              Daftar referensi query parameter serta deskripsi response skema JSON dari portal layanan geospasial Genesis.id.
            </p>
          </div>

          <div className="space-y-16">
            {/* Table 1: GET /b2g/reports */}
            <div>
              <div className="flex items-center gap-2 mb-4">
                <span className="px-2 py-1 bg-emerald-100 text-emerald-800 text-[11px] font-bold rounded font-mono">GET</span>
                <span className="font-mono text-sm font-semibold text-navy-900">/b2g/reports</span>
              </div>
              <p className="text-xs sm:text-sm text-navy-600 font-light mb-5 leading-relaxed">
                Menarik seluruh data spasial tumpukan sampah wilayah (GIS-ready). Mendukung fungsionalitas pencarian, filter, dan pembatasan baris untuk GIS Ingestion.
              </p>

              <div className="overflow-x-auto rounded-xl border border-navy-100 shadow-sm bg-slate-50/50">
                <table className="w-full text-left border-collapse text-xs">
                  <thead>
                    <tr className="bg-navy-900 text-white font-mono uppercase tracking-wider">
                      <th className="p-3">Query Parameter</th>
                      <th className="p-3">Tipe</th>
                      <th className="p-3">Wajib</th>
                      <th className="p-3">Deskripsi / Contoh</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-navy-50 leading-relaxed font-light text-navy-800">
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">city_or_district</td>
                      <td className="p-3 font-mono text-primary">String</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Nama kota administrasi lengkap (e.g. <span className="font-mono bg-slate-100 text-navy-700 px-1 py-0.5 rounded">"Kota Surabaya"</span>).</td>
                    </tr>
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">status</td>
                      <td className="p-3 font-mono text-primary">String</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Pilihan status: <span className="font-mono text-navy-600">pending_ai, approved, resolved, rejected</span>.</td>
                    </tr>
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">waste_type</td>
                      <td className="p-3 font-mono text-primary">String</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Jenis klasifikasi AI sampah (e.g. <span className="font-mono bg-slate-100 text-navy-700 px-1 py-0.5 rounded">"Plastik"</span> atau <span className="font-mono bg-slate-100 text-navy-700 px-1 py-0.5 rounded">"B3"</span>).</td>
                    </tr>
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">danger_level</td>
                      <td className="p-3 font-mono text-primary">String</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Tingkat bahaya kerawanan tumpukan: <span className="font-mono text-navy-600">Rendah, Sedang, Tinggi</span>.</td>
                    </tr>
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">limit</td>
                      <td className="p-3 font-mono text-primary">Integer</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Batasi jumlah baris record (default: <span className="font-mono">20</span>, maksimal: <span className="font-mono">100</span>).</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            {/* Table 2: GET /b2g/summary */}
            <div>
              <div className="flex items-center gap-2 mb-4">
                <span className="px-2 py-1 bg-emerald-100 text-emerald-800 text-[11px] font-bold rounded font-mono">GET</span>
                <span className="font-mono text-sm font-semibold text-navy-900">/b2g/summary</span>
              </div>
              <p className="text-xs sm:text-sm text-navy-600 font-light mb-5 leading-relaxed">
                Menarik seluruh agregasi statistik wilayah, menghitung jumlah laporan per status, tingkat keparahan bahaya, serta dominasi kategori sampah geospasial.
              </p>

              <div className="overflow-x-auto rounded-xl border border-navy-100 shadow-sm bg-slate-50/50">
                <table className="w-full text-left border-collapse text-xs">
                  <thead>
                    <tr className="bg-navy-900 text-white font-mono uppercase tracking-wider">
                      <th className="p-3">Query Parameter</th>
                      <th className="p-3">Tipe</th>
                      <th className="p-3">Wajib</th>
                      <th className="p-3">Deskripsi / Contoh</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-navy-50 leading-relaxed font-light text-navy-800">
                    <tr className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-navy-900 font-medium">city_or_district</td>
                      <td className="p-3 font-mono text-primary">String</td>
                      <td className="p-3 font-mono text-navy-500">Opsional</td>
                      <td className="p-3">Saring data agregasi statistik hanya untuk kota/kabupaten tertentu.</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 5. SLA & Legal guidelines */}
      <section className="relative w-full bg-slate-900 text-white py-24 px-4 sm:px-8">
        <div className="max-w-4xl mx-auto flex flex-col md:flex-row gap-12 items-center justify-between">
          <div className="max-w-xl">
            <span className="text-xs uppercase tracking-wider text-primary font-mono font-bold">B2G Service-Level Agreement</span>
            <h2 className="text-3xl font-light tracking-tight mt-2 text-white">SLA Ketersediaan 99.9%</h2>
            <p className="text-sm font-light text-navy-200 mt-4 leading-relaxed">
              Layanan DaaS Genesis.id berjalan di atas infrastruktur server autoscaling Google Cloud Run yang terintegrasi secara redundan dengan database Supabase, menjamin kecepatan response time rata-rata di bawah 120ms bagi sistem pemantauan darurat perkotaan.
            </p>
          </div>
          
          <div className="flex-shrink-0 bg-navy-800 p-8 rounded-2xl border border-navy-700 w-full md:w-auto md:min-w-[250px] text-center shadow-lg shadow-black/20">
            <div className="text-primary text-5xl font-mono font-bold tracking-tight">99.9%</div>
            <div className="text-xs text-navy-300 font-mono tracking-widest uppercase mt-2">Guaranteed Uptime</div>
            <div className="mt-6 border-t border-navy-700/60 pt-6">
              <a 
                href="mailto:support@genesisHub.web.id"
                className="inline-block text-xs font-semibold rounded-lg bg-white text-navy-900 px-4 py-2 hover:bg-slate-100 transition-colors cursor-pointer select-none"
              >
                Hubungi Support
              </a>
            </div>
          </div>
        </div>
      </section>

    </main>
  );
}
