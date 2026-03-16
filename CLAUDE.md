# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Site

```bash
bundle exec jekyll serve    # Local development server (http://localhost:4000)
bundle exec jekyll build    # Build static site to _site/
```

## Architecture

This is a personal blog for Jon Eisen (joneisen.me), built with **Jekyll 4.2.2** and hosted on GitHub Pages with a custom domain via `CNAME`.

### Content

- `_posts/` — Blog posts in `YYYY-MM-DD-title.markdown` format with YAML frontmatter
- `_drafts/` — Unpublished posts
- `_data/beer.yaml` — Structured homebrewing data (beer recipes with style, ABV, IBU, SRM)
- `races/` — Race-specific standalone pages

Post categories used: `programming`, `running`, `misc`, `sports`, `bikes`, `recipes`, `philosophy`.

Feed pages (`index.html`, `running.html`, `programming.html`) use the `feed-page` layout, which displays the first post prominently via `_includes/preview.html` then lists the rest via `_includes/post-list.html`.

### Layouts & Includes

- `_layouts/default.html` — Base layout (wraps all others)
- `_layouts/post.html` — Blog post with prev/next navigation
- `_layouts/race.html` — Race report layout with `_includes/race-header.html`
- `_includes/` — Reusable partials (head, header, footer, post-list, preview, scripts)

### Styling

SCSS lives in `_sass/` and is compiled through `css/main.scss`. Syntax highlighting is handled by Rouge (server-side) plus `js/highlight.pack.js` (client-side).

### RSS Feed

`feed.xml` shows the 10 most recent posts. Posts are truncated at `<!--break-->` in the feed.
