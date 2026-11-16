-- Mirrorball Fantasy: weekly dance assignments
-- Run once in Supabase SQL Editor. Safe to re-run.

create table if not exists public.dance_assignments (
  id uuid primary key default gen_random_uuid(),
  league_id text not null references public.leagues(id) on delete cascade,
  couple_id uuid not null references public.couples(id) on delete cascade,
  week integer not null check (week > 0),
  dance_style text not null,
  song_title text,
  song_artist text,
  source_note text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint dance_assignments_league_week_couple_key unique (league_id, week, couple_id)
);

create index if not exists dance_assignments_league_week_idx
  on public.dance_assignments (league_id, week);

alter table public.dance_assignments enable row level security;

drop policy if exists "league members can view published dance assignments" on public.dance_assignments;
create policy "league members can view published dance assignments"
on public.dance_assignments for select to authenticated
using (
  published = true
  or exists (
    select 1 from public.players p
    where p.user_id = auth.uid()
      and p.league_id = dance_assignments.league_id
      and p.role = 'commissioner'
  )
);

drop policy if exists "commissioner can insert dance assignments" on public.dance_assignments;
create policy "commissioner can insert dance assignments"
on public.dance_assignments for insert to authenticated
with check (
  exists (
    select 1 from public.players p
    where p.user_id = auth.uid()
      and p.league_id = dance_assignments.league_id
      and p.role = 'commissioner'
  )
);

drop policy if exists "commissioner can update dance assignments" on public.dance_assignments;
create policy "commissioner can update dance assignments"
on public.dance_assignments for update to authenticated
using (
  exists (
    select 1 from public.players p
    where p.user_id = auth.uid()
      and p.league_id = dance_assignments.league_id
      and p.role = 'commissioner'
  )
)
with check (
  exists (
    select 1 from public.players p
    where p.user_id = auth.uid()
      and p.league_id = dance_assignments.league_id
      and p.role = 'commissioner'
  )
);

drop policy if exists "commissioner can delete dance assignments" on public.dance_assignments;
create policy "commissioner can delete dance assignments"
on public.dance_assignments for delete to authenticated
using (
  exists (
    select 1 from public.players p
    where p.user_id = auth.uid()
      and p.league_id = dance_assignments.league_id
      and p.role = 'commissioner'
  )
);

grant select, insert, update, delete on public.dance_assignments to authenticated;
