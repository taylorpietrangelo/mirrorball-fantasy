-- Mirrorball Fantasy: allow multiple dance assignments per couple in one week.
-- This migration preserves all existing assignment rows and RLS policies.
-- It removes only the one-assignment-per-couple/week uniqueness rule.

alter table public.dance_assignments
  drop constraint if exists dance_assignments_league_week_couple_key;

create index if not exists dance_assignments_league_week_couple_idx
  on public.dance_assignments (league_id, week, couple_id);

