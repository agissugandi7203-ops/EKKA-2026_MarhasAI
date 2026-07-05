-- 1. Membuat tabel app_config untuk konfigurasi versi aplikasi & pembaruan paksa
CREATE TABLE IF NOT EXISTS public.app_config (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1), -- Memastikan hanya ada satu baris konfigurasi global
  min_version TEXT NOT NULL DEFAULT '1.0.0',       -- Versi minimum yang wajib dimiliki pengguna
  latest_version TEXT NOT NULL DEFAULT '1.0.0',    -- Versi terbaru yang tersedia di App Store / Play Store
  update_url TEXT NOT NULL DEFAULT 'https://genesisHub.web.id', -- Link unduhan update aplikasi
  force_update BOOLEAN NOT NULL DEFAULT FALSE,     -- Flag untuk memaksakan update versi terbaru secara global
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Memasukkan data awal (seed)
INSERT INTO public.app_config (id, min_version, latest_version, update_url, force_update)
VALUES (1, '1.0.0', '1.0.0', 'https://genesisHub.web.id', false)
ON CONFLICT (id) DO NOTHING;

-- 3. Mengaktifkan Row Level Security (RLS)
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- 4. Membuat Kebijakan RLS (Public Read)
CREATE POLICY "Konfigurasi aplikasi dapat dibaca oleh siapa saja" 
ON public.app_config 
FOR SELECT 
USING (true);
