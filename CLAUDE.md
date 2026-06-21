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
- `races/` — Race-specific standalone pages

Post categories used: `programming`, `running`, `misc`, `sports`, `bikes`, `recipes`, `philosophy`. A post sets a single `categories:` value in frontmatter; the category drives which feed page surfaces it.

The home page (`index.html`) uses the `default` layout. It is a two-section landing — **Photographs** (4 albums) and **Writing** (the 6 most recent posts) — not a full post list. The Photographs section shows the albums listed in `_data/featured.yaml` first (in order), then fills remaining slots (up to 4) with the newest albums from `_data/photos.yaml`; each album is rendered by `_includes/album-frame.html`. Category feed pages (`running.html`, `programming.html`) use the `feed-page` layout: it reads `page.category`, pulls `site.categories[category]`, displays the first post prominently via `_includes/preview.html`, then lists the rest via `_includes/post-list.html`.

### Photos integration

The homepage features real album covers from the separate **photos.joneisen.me** site (a sibling repo, served at `joneisen.me/photos/`, deep-linked via hash routes `…/photos/#/album/<id>`). Cover URLs are absolute (Cloudflare R2), so nothing is copied into this repo.

`rake photos` (plain `rake`, not `bundle exec` — the task is stdlib-only and rake isn't in the Jekyll bundle) writes the recent-album pool to `_data/photos.yaml`. It reads `PHOTOS_JSON` if set, else the sibling repo's `../photos.joneisen.me/src/data/photos.json`. It accepts either shape — albums with a full `photos` array (local export) or with a `count` (the CI summary) — so one implementation serves both. Filter/size knobs (`MIN_PHOTOS`, `MAX_ALBUMS`) live at the top of the `Rakefile`. To curate which albums lead, edit `_data/featured.yaml` (pinned ids), not `_data/photos.yaml`.

**Automated refresh:** `.github/workflows/sync-photos.yml` listens for a `repository_dispatch` (`photos-updated`) from the photos repo. The photos repo's `deploy.yml` (which is the source of the dispatch) builds its album data, then sends a compact `{id,name,count,cover}` summary as the dispatch `client_payload`; this workflow writes that to a temp file, runs `rake photos`, and commits `_data/photos.yaml` (the commit triggers the Pages build). The photos repo needs a `BLOG_DISPATCH_TOKEN` secret — a PAT with write access to *this* repo — for the dispatch call. `photos.json` is gitignored in the photos repo, which is why the data travels in the dispatch payload rather than being fetched.

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
