-- Mirrorball Fantasy v17: change weekly Pick'ems from 5 questions to 4.
-- Run once in Supabase SQL Editor.

begin;

-- Remove the old fifth question from any week. This keeps the live database
-- consistent with the new 4-question format and removes any old Q5 picks/scores
-- through the foreign-key cascades.
delete from public.pickem_questions
where league_id = 'dwts-2026'
  and question_order = 5;

-- Allow the Commissioner to view all players' Pick'em answers so the
-- Commissioner Portal submission tracker can show who submitted and what they picked.
drop policy if exists "commissioner read all picks" on public.pickem_picks;
create policy "commissioner read all picks"
on public.pickem_picks
for select
to authenticated
using (
  exists (
    select 1
    from public.players p
    where p.id = pickem_picks.player_id
      and public.is_commissioner(p.league_id)
  )
);

commit;
