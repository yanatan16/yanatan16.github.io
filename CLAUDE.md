# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Site

```bash
bundle exec jekyll serve    # Local development server (http://localhost:4000)
bundle exec jekyll build    # Build static site to _site/
```

Ruby 2.7.4 is pinned via `.ruby-version`. There is no test suite; `jekyll build` is the verification step.

## Architecture

This is a personal blog for Jon Eisen (joneisen.me), built with **Jekyll 4.2.2** and hosted on GitHub Pages with a custom domain via `CNAME`. Active plugins (`_config.yml`): `jemoji`, `jekyll-redirect-from` (use `redirect_from:` frontmatter to preserve old URLs), and `jekyll-sitemap`.

### Content

- `_posts/` — Blog posts in `YYYY-MM-DD-title.markdown` format with YAML frontmatter
- `_drafts/` — Unpublished posts
- `_data/beer.yaml` — Structured homebrewing data (beer recipes with style, ABV, IBU, SRM)
- `_data/srm.yaml` — SRM-to-hex color lookup table used to render beer colors
- `_data/photos.yaml` — Album snapshot (id/name/count/cover) feeding the homepage Photographs section. **Generated, do not hand-maintain** — see Photos integration below.
- `_data/podcast.yaml` — Recent "Running with Problems" episodes feeding the homepage Podcast section. **Generated, do not hand-maintain** — see Podcast integration below.
- `_data/results.yaml` — Hand-authored race results feeding the homepage Runner section and the `/results/` ledger. **Hand-maintained** (unlike photos/podcast) — see Runner integration below.
- `races/` — Race-specific standalone pages

Post categories used: `programming`, `running`, `misc`, `sports`, `bikes`, `recipes`, `philosophy`. A post sets a single `categories:` value in frontmatter; the category drives which feed page surfaces it.

The home page (`index.html`) uses the `default` layout. It is a stack of numbered highlight sections — **01 Runner** (recent races + stat strip), **02 Photographs** (4 albums), **03 Writing** (the 6 most recent posts), **04 Podcast** (latest episodes), and **05 High Lonesome 100** — not a full post list. The first four are data-driven (each renders a list from a `_data/*.yaml` file); **05** is a single static, hand-authored "role" feature (no data file, no sync) — see High Lonesome 100 highlight below. The Photographs section shows the albums listed in `_data/featured.yaml` first (in order), then fills remaining slots (up to 4) with the newest albums from `_data/photos.yaml`; each album is rendered by `_includes/album-frame.html`. Category feed pages (`running.html`, `programming.html`) use the `feed-page` layout: it reads `page.category`, pulls `site.categories[category]`, displays the first post prominently via `_includes/preview.html`, then lists the rest via `_includes/post-list.html`.

### Photos integration

The homepage features real album covers from the separate **photos.joneisen.me** site (a sibling repo, served at `joneisen.me/photos/`, deep-linked via hash routes `…/photos/#/album/<id>`). Cover URLs are absolute (Cloudflare R2), so nothing is copied into this repo.

`rake photos` (plain `rake`, not `bundle exec` — the task is stdlib-only and rake isn't in the Jekyll bundle) writes the recent-album pool to `_data/photos.yaml`. It reads `PHOTOS_JSON` if set, else the sibling repo's `../photos.joneisen.me/src/data/photos.json`. It accepts either shape — albums with a full `photos` array (local export) or with a `count` (the CI summary) — so one implementation serves both. Filter/size knobs (`MIN_PHOTOS`, `MAX_ALBUMS`) live at the top of the `Rakefile`. To curate which albums lead, edit `_data/featured.yaml` (pinned ids), not `_data/photos.yaml`.

**Automated refresh:** `.github/workflows/sync-photos.yml` listens for a `repository_dispatch` (`photos-updated`) from the photos repo. The photos repo's `deploy.yml` (which is the source of the dispatch) builds its album data, then sends a compact `{id,name,count,cover}` summary as the dispatch `client_payload`; this workflow writes that to a temp file, runs `rake photos`, and commits `_data/photos.yaml` (the commit triggers the Pages build). The photos repo needs a `BLOG_DISPATCH_TOKEN` secret — a PAT with write access to *this* repo — for the dispatch call. `photos.json` is gitignored in the photos repo, which is why the data travels in the dispatch payload rather than being fetched.

### Podcast integration

The homepage `03 Podcast` section features Jon's podcast **Running with Problems** (`runningwithproblems.run`, hosted on Buzzsprout). `rake podcast` (plain `rake`, stdlib-only like `rake photos`) fetches the Buzzsprout RSS (`https://rss.buzzsprout.com/2437656.rss`, override with `PODCAST_FEED`), parses the channel + latest items, and writes `_data/podcast.yaml` (`title`/`tagline`/`link`/`cover` + `episodes`). `MAX_EPISODES` at the top of the `Rakefile` controls how many are kept (homepage shows 3).

Episode rows deep-link to custom-domain episode pages: `https://www.runningwithproblems.run/2437656/episodes/<id>-<slug>`, where `<id>` comes from the item `guid` (`Buzzsprout-<id>`) and `<slug>` is the title downcased with apostrophes dropped and non-alphanumeric runs collapsed to hyphens (Buzzsprout's slug rule).

**Automated refresh:** `.github/workflows/sync-podcast.yml` runs `rake podcast` on a daily cron (Buzzsprout can't `repository_dispatch` like the photos repo, so it polls; `workflow_dispatch` allows manual runs) and commits `_data/podcast.yaml` only if changed, which triggers the Pages build.

### Runner integration

The homepage `01 Runner` section and the standalone `/results/` page (`results.html`, `default` layout) are driven by **hand-authored** `_data/results.yaml` — there is no rake task or sync workflow (unlike photos/podcast). The file holds a `headline` (editorial achievement string) plus a `races` array; each race carries `date`, `race`, `distance` (freeform display label like `100M`/`50K`/`6hr`), `miles` (numeric, summed for the total), optional `vert` (feet), `result` (freeform — finish time, `DNF @ 71`, `2 loops in 27:10`, timed mileage…), optional `note`, and optional `report` (path to a `running`-category post, e.g. `/running/2025/09/12/dark-divide-100.html`).

Both surfaces share `_includes/result.html`, which renders one `.entry.result` row (date · race+note · distance·vert · result) and becomes a link to `report` when present. The note nests inside the race-name cell so a wrapping `result` can't shove it out of alignment. The homepage passes no `show_note`; `/results/` passes `show_note=true` and groups races by year via `group_by_exp`. Stat figures (race count, total miles, total vert) are computed in Liquid from the data, so they self-update. Numbers are comma-formatted by `_includes/commafy.html` (and `_includes/feet.html`, which wraps it and appends a prime mark for vert).

### High Lonesome 100 highlight

The homepage `04 High Lonesome 100` section features Jon's volunteer role (labeled **Comms Director**, short for Communications & Runner Tracking Director) at the [High Lonesome 100](https://highlonesome100.com), a 100-mile race in Colorado's Sawatch Range. Unlike the three sections above it, this is **static and hand-authored** — there is nothing to sync, so it has no `_data` file, `rake` task, or workflow. The section is inlined directly in `index.html` (an editorial split: photo + role/blurb/stats/link), styled by the `.role-*` rules in `_sass/_layout.scss` (the photo reuses the `.frame .img` treatment via a shared selector group). The image is a local repo asset, `img/highlonesome.jpg` (like `img/banner.jpg`) — not a remote URL. To change the copy, stats, photo, or link, edit `index.html` directly.

### Layouts & Includes

- `_layouts/default.html` — Base layout (wraps all others)
- `_layouts/feed-page.html` — Category feed listing (see Content above)
- `_layouts/page.html` — Generic standalone page
- `_layouts/post.html` — Blog post with prev/next navigation
- `_layouts/race.html` — Race report layout with `_includes/race-header.html`
- `_includes/` — Reusable partials (head, header, footer, post-list, preview, scripts, `photos.html` (1–3 photo bars), `hire-me.html`)

### Styling

SCSS lives in `_sass/` and is compiled through `css/main.scss`. Syntax highlighting is handled by Rouge (server-side) plus `js/highlight.pack.js` (client-side).

Design system ("Desert ↔ Alpine", neo-grotesque): all palette/type variables are defined at the top of `css/main.scss`. One typeface — **Schibsted Grotesk** (loaded in `_includes/head.html`), used at varied weights. Palette is a cold-meets-warm complementary pair: bleached-bone ground, alpine navy-black ink, **salt-flat blue** (`$blue`) as the interactive accent, **desert coral** (`$coral`) as a sparing warm accent on numerals/indices. Legacy variable aliases (`$brand-color`, `$grey-color*`, etc.) are kept mapped to the new palette so `_syntax-highlighting.scss` and `_races.scss` still compile. `_base.scss` holds typography/reset/utilities; `_layout.scss` holds the topbar, masthead, section grids, photo frames, the reusable `.entry` writing-index row, post-reading styles, and footer.

### RSS Feed

`feed.xml` is a hand-written Liquid template (not generated by `jekyll-feed`, despite that gem being in the Gemfile). It shows the 10 most recent posts; each post's description is truncated at `<!--break-->`. The same `<!--break-->` marker splits the preview from the body in `preview.html`, so every post should include it.
