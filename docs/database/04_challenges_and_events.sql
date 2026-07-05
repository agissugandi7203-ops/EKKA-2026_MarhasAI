-- 1. Tabel Event Resmi oleh Admin
create table if not exists public.events (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text not null,
  points integer default 0 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Tabel Master Tantangan Harian (Daily Quests)
create table if not exists public.challenges (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  title text not null,
  xp integer default 0 not null,
  points integer default 0 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Tabel Relasi Penyelesaian Tantangan (dengan Reset Harian Berbasis Tanggal)
create table if not exists public.profile_challenges (
  profile_id uuid references public.profiles(id) on delete cascade not null,
  challenge_id uuid references public.challenges(id) on delete cascade not null,
  completed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (profile_id, challenge_id, completed_at)
);

-- 4. Tabel Notifikasi Warga
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade, -- null = global/semua warga
  title text not null,
  body text not null,
  is_read boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indeks untuk mempercepat pencarian notifikasi per user
create index if not exists notifications_profile_idx on public.notifications(profile_id, created_at desc);

-- Indeks untuk mempercepat pencarian tantangan per user
create index if not exists profile_challenges_profile_idx on public.profile_challenges(profile_id);

-- 5. Aktifkan Row Level Security (RLS)
alter table public.events enable row level security;
alter table public.challenges enable row level security;
alter table public.profile_challenges enable row level security;
alter table public.notifications enable row level security;

-- 6. Kebijakan RLS (Policies)
create policy "Semua orang dapat membaca event" on public.events for select using (true);
create policy "Semua orang dapat membaca tantangan" on public.challenges for select using (true);
create policy "Semua orang dapat membaca notifikasi" on public.notifications for select using (true);
create policy "Pengguna dapat mengelola status tantangan sendiri" on public.profile_challenges for all using (auth.uid() = profile_id);

-- 7. Hubungkan event buatan admin agar otomatis terbuat sebagai notifikasi global
create or replace function public.on_event_created()
returns trigger as $$
begin
  insert into public.notifications (title, body)
  values (
    'Event Baru: ' || new.title,
    new.description || ' (Dapatkan +' || new.points || ' Poin!)'
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_event_created_trigger
  after insert on public.events
  for each row execute procedure public.on_event_created();

-- 8. Seed Tantangan Harian Bawaan
insert into public.challenges (code, title, xp, points) values
  ('report_1_waste', 'Laporkan 1 tumpukan sampah hari ini', 50, 10),
  ('chat_ai', 'Tanya Geni AI tentang regulasi lingkungan', 20, 5),
  ('check_leaderboard', 'Lihat Papan Peringkat hari ini', 10, 2)
on conflict (code) do nothing;

-- 9. Pembaruan Fungsi Spasial check_duplicate_report
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
  where status in ('approved', 'pending_ai', 'pending_human')
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
