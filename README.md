# Mirrorball Fantasy — Sharable Beta

## What this is
This is the first shared-ready build of the DWTS fantasy league. GitHub Pages can host the
HTML/CSS/JavaScript, while Supabase provides the shared database and authentication.

## Current league rules carried forward
- 7 fantasy teams / players total, including the commissioner.
- 16 couples.
- Each team drafts 3 couples.
- There are 5 Wildcard picks.
- A Wildcard may duplicate a couple already drafted by another team.
- A Wildcard disappears when that couple is eliminated.
- A team stays in the fantasy league even if it has no active couples left.
- Teams continue earning Weekly Pick'em points through the finale.
- Weekly Pick'ems support up to 5 questions.
- Pick'em values are currently 3, 4, or 6 points.

## Next setup step
1. Create a free Supabase project.
2. Open SQL Editor and run `supabase-schema.sql`.
3. Copy your Supabase Project URL and Publishable Key into `config.js`.
4. Create the 7 player accounts and identify the commissioner.
5. Connect the existing site data/functions to the shared tables.
6. Put the finished site in a GitHub repository and enable GitHub Pages.

GitHub Pages is static hosting, so it hosts the site while Supabase handles shared data/auth.
Supabase's browser client can be loaded from a CDN, which keeps this project simple.

Do not place a Supabase service-role/secret key in `config.js`.
