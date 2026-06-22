# Podcast highlight on the homepage — design

**Date:** 2026-06-21
**Status:** Approved design, pending implementation plan

## Goal

Add a fun, first-class highlight for Jon's podcast **Running with Problems**
(`runningwithproblems.run`) to the homepage (`index.html`). It links to the show
and surfaces the most recent episodes, kept current automatically from the
podcast's RSS feed.

## Approach

Mirror the existing **Photos integration** pattern: a stdlib-only `rake` task
parses an external source into a `_data/*.yaml` file, a GitHub Action keeps that
file fresh, and the homepage renders from the data file. Podcast feeds typically
block browser fetches (CORS), so data is materialized at build time, not fetched
client-side.

Homepage presentation is **Option A**: a numbered `03 Podcast` section that
reuses the existing `.entry` row machinery (DRY) so it matches the page's
`01 Photographs` / `02 Writing` rhythm.

## Data source

- **Feed:** `https://rss.buzzsprout.com/2437656.rss` (Buzzsprout).
- **Podcast id:** `2437656` (the numeric segment of the feed URL; used to build
  episode-page links).
- Per-item fields available and used: `title`, `pubDate`, `itunes:duration`
  (seconds), `itunes:season`, `itunes:episode`, `guid` (`Buzzsprout-<id>`).
  Channel fields used: `title`, `description` (tagline), channel `itunes:image`
  / `image` (cover art), channel `link`.
- **Note:** items have **no** `<link>` element; the episode id comes from `guid`.

### Episode-page link construction

Episode pages live on the Buzzsprout custom domain:

```
https://www.runningwithproblems.run/2437656/episodes/<episodeId>-<slug>
```

- `episodeId` = `guid` with the `Buzzsprout-` prefix stripped (e.g. `19329076`).
- `slug` = title, transformed: downcase → remove apostrophes/single-quotes →
  replace every run of non-`[a-z0-9]` characters with a single `-` → strip
  leading/trailing `-`.
  - Verified: `"Hot Take: Hanes & Canaday Doping Debacle Explained"` →
    `hot-take-hanes-canaday-doping-debacle-explained` (matches the real URL).
  - This is a documented approximation of Buzzsprout's slug rule; because the
    data file is regenerated daily, a mismatched title is cheap to correct.

## Components

### 1. `rake podcast` task (`Rakefile`)

- Stdlib only: `net/http`, `rexml/document`, `yaml` (consistent with `rake
  photos` being stdlib-only and run as plain `rake`, not `bundle exec`).
- Knobs at top of `Rakefile`, alongside the photos knobs:
  - `PODCAST_FEED` — defaults to the Buzzsprout feed URL; `ENV` override for
    testing (parallels `PHOTOS_JSON`).
  - `MAX_EPISODES` — default `6` (homepage shows 3; keep a few spare in data).
- Fetches the feed over HTTPS, parses the channel + items, maps each item to:
  `{ title, season, episode, date (YYYY-MM-DD), minutes (rounded from seconds),
  link }`, takes the first `MAX_EPISODES`, and writes `_data/podcast.yaml`.
- Prints a short summary (parallel to the photos task output).

### 2. `_data/podcast.yaml` (generated; do not hand-maintain)

```yaml
title: Running with Problems
tagline: A podcast about the lives of runners and the problems we face.
link: https://runningwithproblems.run
cover: https://storage.buzzsprout.com/<key>.jpg
episodes:
- title: "Hot Take: Hanes & Canaday Doping Debacle Explained"
  season: 5
  episode: 8
  date: 2026-06-11
  minutes: 60
  link: https://www.runningwithproblems.run/2437656/episodes/19329076-hot-take-hanes-canaday-doping-debacle-explained
```

Seeded by running `rake podcast` once during implementation so the section
renders immediately.

### 3. `_includes/show.html` (partial, parallels `album-frame.html`)

Renders one episode as a reused `.entry` row. Takes `include.show` (an episode
hash) and `include.index` (1-based, for the `.n` numeral):

- `.n` → `S{season}·E{episode}` (coral index)
- `.date` → `date` formatted `%b %-d, %Y`
- `.cat` → `{minutes} MIN` (blue uppercase slot)
- `.ttl` → episode `title`
- `.go` → arrow; the row's `href` is the episode `link`

### 4. Homepage section (`index.html`)

Guarded by `{% if site.data.podcast.episodes %}`, placed after the Writing
section:

- `sec-head`: `idx` `03`, `h2` `Podcast`, `more` link "Listen to all →" to
  `site.data.podcast.link`.
- `.show-intro`: cover-art thumbnail (`site.data.podcast.cover`) + the tagline.
- `.shows` list: the 3 most recent episodes via `_includes/show.html`.

### 5. Masthead identity touches (`index.html`)

- Identity line: add **Podcaster** → `Runner · Engineer · Photographer ·
  Podcaster`.
- Blurb: add a podcast nod, e.g. "…and take photographs along the way. I also
  host the **Running with Problems** podcast. Enjoy my writing, photography, and
  shows."

### 6. Styles (`_sass/_layout.scss`)

Minimal additions; reuse `.sec`, `.sec-head`, `.entry`:

- `.shows .entry` — leading numeral column tweak mirroring `.writing .entry`
  (so `.n` shows).
- `.show-intro` — flex row: square cover thumbnail (~72–96px, rounded to match
  `.frame` treatment) + tagline text. Responsive collapse consistent with the
  existing mobile `.entry` rules.

### 7. Refresh workflow (`.github/workflows/sync-podcast.yml`)

- Trigger: **daily `schedule` cron** (Buzzsprout cannot `repository_dispatch` to
  this repo the way the sibling photos repo does, so we poll). Include
  `workflow_dispatch` for manual runs.
- Steps mirror `sync-photos.yml`: checkout → `ruby/setup-ruby@v1` (3.3) →
  `rake podcast` → commit `_data/podcast.yaml` only if changed → push (the commit
  triggers the Pages build).
- `permissions: contents: write`.

### 8. Docs (`CLAUDE.md`)

Add a "Podcast integration" subsection paralleling "Photos integration": the
feed, `rake podcast`, the generated `_data/podcast.yaml`, the episode-link
transform, and the daily `sync-podcast.yml` cron.

## Data flow

```
Buzzsprout RSS ──(rake podcast)──▶ _data/podcast.yaml ──(Liquid)──▶ 03 Podcast section
        ▲                                   ▲
   daily cron (sync-podcast.yml) ───────────┘ (commit if changed → Pages build)
```

## Out of scope (YAGNI)

- No inline audio player or embeds — rows deep-link to episode pages.
- No transcripts, chapters, or per-episode artwork on the homepage.
- No episode archive page on this site; "Listen to all" goes to the podcast site.

## Verification

`bundle exec jekyll build` is the project's verification step (no test suite).
Confirm the build succeeds and the `03 Podcast` section renders with three
episodes and working episode links.
