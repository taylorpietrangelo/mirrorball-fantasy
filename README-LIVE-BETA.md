# Mirrorball Fantasy — Live Beta

This package is the next step from the local HTML build: the website is static, while Supabase handles shared data and authentication.

## 1. Supabase
Open your existing Supabase project's SQL Editor and run **supabase-live-beta.sql**.

The migration:
- upgrades Pick'ems to exactly 5 points each;
- seeds the 2026 league, 16 couples, 7 teams, and the official rosters;
- creates league settings;
- adds commissioner-only write policies;
- keeps the browser on the publishable key only.

## 2. Create the team accounts

Players do **not** enter an email on the website. Supabase still uses an internal email-style login behind the scenes so we can keep its secure password authentication.

In Supabase Dashboard → Authentication → Users, create these 7 users with the following internal login names:

| Team | Internal Auth login |
|---|---|
| Lauren | `lauren@mirrorball.invalid` |
| Nick | `nick@mirrorball.invalid` |
| Morgan | `morgan@mirrorball.invalid` |
| Justin | `justin@mirrorball.invalid` |
| Taylor | `taylor@mirrorball.invalid` |
| Gabby | `gabby@mirrorball.invalid` |
| Brianna | `brianna@mirrorball.invalid` |

The `.invalid` domain is intentionally reserved; these are **not real email addresses** and are never shown to players. Use the password you want each team to have.

After each Auth account exists, copy its Auth user UUID and run this in SQL Editor:

```sql
update public.players
set user_id = 'AUTH-USER-UUID-HERE'
where league_id = 'dwts-2026' and team_name = 'Taylor';
```

Replace `Taylor` with the correct team for each account.

For the commissioner account, also run:

```sql
update public.players
set role = 'commissioner'
where league_id = 'dwts-2026' and team_name = 'Taylor';
```

Use the commissioner team's row for the commissioner account. A commissioner is still a normal fantasy team.

## 3. Auth setting for beta

Because these are internal/non-email logins, turn **off email confirmation** in Supabase Authentication settings. The site does not use email verification or send player emails.

## 4. Website files
Keep these three files together:
- index.html
- config.js
- supabase-live-beta.sql (not required by the browser, but keep it with the project for setup)

The browser uses only the Supabase Project URL and publishable key in `config.js`. Never add the secret/service-role key.

## 5. GitHub / Netlify
Upload `index.html` and `config.js` to your GitHub repository. If you use Netlify, connect the repository and publish the folder containing those files.

The site should then open to a Sign In screen. Each friend signs in and sees only the team attached to their Auth account. The commissioner gets the Commissioner Portal.

## 6. Beta testing order
1. Commissioner signs in.
2. Confirm the 7 rosters and Wildcards.
3. Have one player sign in from a phone.
4. Submit a Pick'em and verify it appears in Supabase.
5. Commissioner enters a test dance score.
6. Check standings from another device.
7. Delete any test score/pick before the first real episode.


## Week History
The app now includes a Week History page. Each week remains stored in Supabase and can be selected later to review that week's fantasy points, Pick'em points, dance scores, bonuses, and eliminations. Nothing is overwritten when you move to the next week.


## v12 testing fix
If your Supabase project was created with the earlier `elimination_picks` migration using `pick_number`/`couple_id`, run `supabase-live-beta-elimination-picks.sql` once before testing elimination Pick’ems. It migrates the table to the `pick_1`/`pick_2` structure used by the app.


## v14 update
- Week selectors now include Weeks 1–11 for the full DWTS season.
- Week 1 data/results are unchanged.
- Weeks 2–11 are available for testing and weekly entry.
- Commissioner can publish five Pick'em questions for any week, then lock picks and record results.
- Corrected the packaged elimination-pick RLS migration to map `elimination_picks.player_id` to `players.user_id` correctly.
- No database migration is required just to make Weeks 2–11 appear in the app.

## v17 Pick'em update
- Weekly Pick'ems now use 4 questions at 5 points each (20 max per week).
- The Commissioner Portal includes a Pick'em submission tracker showing submitted/not submitted status and each player's answers.
- Run `mirrorball-v17-pickem-migration.sql` once in Supabase SQL Editor before publishing v17.
