-- MIRRORBALL FANTASY — SHARABLE BETA DATABASE
-- Run this in Supabase SQL Editor after creating a project.
-- This schema is designed for 7 players + 1 commissioner and keeps
-- league data separate from the website code.

create table if not exists public.leagues (
  id text primary key,
  name text not null,
  season integer not null,
  commissioner_user_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  display_name text not null,
  email text,
  user_id uuid unique,
  role text not null default 'player' check (role in ('player','commissioner')),
  team_name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.couples (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  name text not null,
  status text not null default 'Active' check (status in ('Active','Eliminated')),
  eliminated_week integer,
  created_at timestamptz not null default now()
);

create table if not exists public.roster (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  couple_id uuid not null references public.couples(id) on delete cascade,
  roster_type text not null check (roster_type in ('draft','wildcard')),
  created_at timestamptz not null default now(),
  unique (player_id, couple_id, roster_type)
);

create table if not exists public.dances (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  couple_id uuid not null references public.couples(id) on delete cascade,
  week integer not null,
  dance_name text not null,
  judge_1 numeric not null,
  judge_2 numeric not null,
  judge_3 numeric not null,
  judge_4 numeric not null,
  total numeric not null,
  bonus numeric not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.eliminations (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  couple_id uuid not null references public.couples(id) on delete cascade,
  week integer not null,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.bonuses (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  week integer,
  points integer not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.pickem_questions (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  week integer not null,
  question_order integer not null,
  question text not null,
  points integer not null check (points in (3,4,6)),
  correct_answer text,
  locked boolean not null default false,
  created_at timestamptz not null default now(),
  unique (league_id, week, question_order)
);

create table if not exists public.pickem_picks (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.pickem_questions(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  answer text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (question_id, player_id)
);

create table if not exists public.pickem_scores (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  week integer not null,
  points integer not null default 0,
  created_at timestamptz not null default now(),
  unique (player_id, week)
);

-- RLS is the important security layer for a public browser app.
alter table public.leagues enable row level security;
alter table public.players enable row level security;
alter table public.couples enable row level security;
alter table public.roster enable row level security;
alter table public.dances enable row level security;
alter table public.eliminations enable row level security;
alter table public.bonuses enable row level security;
alter table public.pickem_questions enable row level security;
alter table public.pickem_picks enable row level security;
alter table public.pickem_scores enable row level security;

-- Public league viewing. Writes should be routed through authenticated policies
-- in the production pass once the 7 accounts are created.
create policy "public can view league"
on public.leagues for select using (true);

create policy "public can view couples"
on public.couples for select using (true);

create policy "public can view players"
on public.players for select using (true);

create policy "public can view roster"
on public.roster for select using (true);

create policy "public can view dances"
on public.dances for select using (true);

create policy "public can view eliminations"
on public.eliminations for select using (true);

create policy "public can view pickem questions"
on public.pickem_questions for select using (true);

create policy "authenticated players can manage their picks"
on public.pickem_picks for all to authenticated
using (player_id = auth.uid())
with check (player_id = auth.uid());

create policy "public can view pickem scores"
on public.pickem_scores for select using (true);

-- Commissioner write policies should be tightened to the commissioner account
-- after the commissioner user's UUID is known. Do not use a service-role key in
-- the browser.
