-- Tabel Laporan Masalah Lingkungan (Crowdsourcing)
create table public.reports (
  id uuid default gen_random_uuid() primary key,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  image_url text not null,
  description text,
  location geometry(Point, 4326) not null, -- Titik koordinat GPS spasial (PostGIS)
  status text default 'pending_ai' not null, -- 'pending_ai' | 'approved' | 'rejected' | 'pending_human'
  confidence_score float default 0.0 not null,
  waste_type text, -- Jenis limbah (misal: plastik, organik, B3)
  danger_level text, -- Tingkat bahaya (misal: low, medium, high)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  admin_notes text
);

-- Indeks Spasial GIST untuk pencarian berbasis jarak koordinat yang efisien
create index reports_location_idx on public.reports using gist(location);

-- Aktifkan Row Level Security (RLS) di tabel reports
alter table public.reports enable row level security;

-- Kebijakan RLS (Policies)
create policy "Laporan dapat dilihat oleh siapa saja" on public.reports
  for select using (true);

create policy "Pengguna terautentikasi dapat membuat laporan" on public.reports
  for insert with check (auth.uid() = reporter_id);

create policy "Hanya admin yang dapat memperbarui laporan" on public.reports
  for update using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Hanya admin yang dapat menghapus laporan" on public.reports
  for delete using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Fungsi Spasial untuk mengecek laporan ganda (anti-spam)
create or replace function public.check_duplicate_report(
  p_lat double precision,
  p_lng double precision
)
returns uuid as $$
declare
  v_report_id uuid;
begin
  select id into v_report_id
  from public.reports
  where status = 'approved'
    and ST_DWithin(
      location,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326),
      0.00045 -- Konversi derajat ke jarak ~50 meter
    )
    and created_at > now() - interval '12 hours'
  order by created_at desc
  limit 1;
  
  return v_report_id;
end;
$$ language plpgsql security definer;

-- Jalankan ini untuk database lama guna menambahkan kolom admin_notes
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS admin_notes text;
