-- Aktifkan ekstensi spasial PostGIS dan pencarian vektor pgvector
create extension if not exists postgis;
create extension if not exists vector;

-- Tabel Profil Pengguna (Gamifikasi & Data Diri)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique,
  full_name text,
  avatar_url text,
  province text,
  city_or_district text,
  xp integer default 0 not null,
  level integer default 1 not null,
  report_count integer default 0 not null,
  current_streak integer default 0 not null,
  last_report_date date,
  role text default 'citizen' not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Aktifkan Row Level Security (RLS) di profiles
alter table public.profiles enable row level security;

-- Policies untuk tabel profiles
create policy "Profil dapat dibaca oleh siapa saja" on public.profiles
  for select using (true);

create policy "Pengguna hanya dapat mengubah profil mereka sendiri" on public.profiles
  for update using (auth.uid() = id);

-- Tabel Master Lencana (Badges)
create table public.badges (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  name text not null,
  description text,
  icon_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Aktifkan RLS di badges
alter table public.badges enable row level security;

create policy "Lencana dapat dibaca oleh siapa saja" on public.badges
  for select using (true);

-- Tabel Relasi Lencana Pengguna (Many-to-Many)
create table public.profile_badges (
  profile_id uuid references public.profiles(id) on delete cascade not null,
  badge_id uuid references public.badges(id) on delete cascade not null,
  earned_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (profile_id, badge_id)
);

-- Aktifkan RLS di profile_badges
alter table public.profile_badges enable row level security;

create policy "Lencana pengguna dapat dibaca oleh siapa saja" on public.profile_badges
  for select using (true);

-- Fungsi SQL otomatis untuk sinkronisasi saat pendaftaran baru (auth.users -> public.profiles)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    -- Gunakan username dari meta data, atau default username menggunakan bagian sebelum '@' di email
    coalesce(
      new.raw_user_meta_data->>'username', 
      split_part(new.email, '@', 1) || '_' || substring(md5(random()::text) from 1 for 4)
    ),
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger pendaftaran
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Database View: Leaderboard Pengguna Global
create or replace view public.global_leaderboard as
  select 
    id, 
    username, 
    full_name, 
    avatar_url, 
    xp, 
    level, 
    report_count,
    dense_rank() over (order by xp desc) as rank
  from public.profiles;

-- Database View: Leaderboard Kabupaten/Kota Terbersih (Kontribusi XP & Laporan)
create or replace view public.city_leaderboard as
  select 
    city_or_district, 
    province, 
    sum(xp) as total_xp, 
    sum(report_count) as total_reports,
    dense_rank() over (order by sum(xp) desc) as rank
  from public.profiles
  where city_or_district is not null
  group by city_or_district, province;

-- Indeks untuk meningkatkan performa leaderboard global & regional
CREATE INDEX IF NOT EXISTS profiles_xp_idx ON public.profiles (xp DESC);
CREATE INDEX IF NOT EXISTS profiles_city_idx ON public.profiles (city_or_district);

-- Insert katalog lencana awal (badges) untuk kebutuhan lomba
insert into public.badges (code, name, description, icon_url) values
  ('first_report', 'Laporan Pertama', 'Berhasil mengunggah laporan masalah lingkungan pertama.', 'https://raw.githubusercontent.com/arief/genesis-badges/main/first_report.png'),
  ('streak_3', 'Pecinta Konsisten', 'Melakukan laporan berturut-turut selama 3 hari.', 'https://raw.githubusercontent.com/arief/genesis-badges/main/streak_3.png'),
  ('streak_7', 'Eco Warrior', 'Melakukan laporan berturut-turut selama 7 hari.', 'https://raw.githubusercontent.com/arief/genesis-badges/main/streak_7.png'),
  ('toxic_buster', 'Pembasmi Limbah B3', 'Melaporkan anomali limbah berbahaya (B3) pertama kali.', 'https://raw.githubusercontent.com/arief/genesis-badges/main/toxic_buster.png'),
  ('green_hero', 'Hero Genesis', 'Berhasil mengumpulkan total 1,000 XP.', 'https://raw.githubusercontent.com/arief/genesis-badges/main/green_hero.png')
on conflict (code) do nothing;
