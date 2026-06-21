# Standardized Photo-Bar Include — Design

**Date:** 2026-06-20
**Status:** Approved design, pending implementation plan

## Problem

Hosted photos (`/img/...`) are embedded in blog posts five different ways:

1. `{% include image.html %}` — single image, `url`/`description`/optional `height`
2. `{% include image-3.html %}` — 3-wide bar that breaks out to 150% width (1 post)
3. Markdown `![alt](/img/...)` — hosted photos written as markdown (teanaway)
4. Hand-written `<figure><img>` rows inside an inline flex `<div>` (2023–2025 race reports)
5. Bare `<img>` rows inside the same inline flex `<div>` (paella, niwots-2023/24)

Patterns 4 and 5 repeat the same `display:flex; flex-wrap:wrap; justify-content:center; gap:1em; margin:1em 0;` inline `<div>` on every photo group — a DRY violation copy-pasted across many posts. The goal is **exactly one way** to embed photos: a single include that renders a 1–3 photo bar in the current design system.

## Scope

Convert **hosted-photo** posts only. In scope:

- All `image.html` / `image-3.html` callers
- All hand-written flex `<figure>` / `<img>` rows pointing at `/img/`
- `2022-09-26-race-report-teanaway-country-100` — 5 hosted trail photos currently written as markdown `![](/img/...)`

Explicitly **out of scope** (left as plain markdown): external/inline images — giphy GIFs, GitHub raw screenshots, dead Instagram/akamaihd links, and the GT football screenshot sets. These are decorative/screenshot singles, not photo bars.

## Decisions

- **API:** one include call renders one full 1–3 photo bar.
- **Width:** 1 photo stays inside the 720px text column; 2–3 photos break out wider (capped ~1100px, centered).
- **Captions:** optional, per-photo (`cap1/2/3`) and/or one optional group caption (`caption`) under the whole bar.

## Components

### 1. `_includes/photos.html`

Call site:

```liquid
{% include photos.html
   img1="/img/niwots-2023/book-10.jpeg" cap1="Book 10 drainage"
   img2="/img/niwots-2023/book-11.jpeg" cap2="Onward" %}
```

Parameters:

| Param | Required | Purpose |
|---|---|---|
| `img1` | yes | First photo URL |
| `img2`, `img3` | no | Second/third photo URLs; presence determines bar width |
| `cap1`, `cap2`, `cap3` | no | Per-photo figcaption for the matching image |
| `caption` | no | Group caption rendered once, centered, under the whole bar |
| `height` | no | Max-height override in px (default 600) for portrait shots |

Behavior:

- Renders a root `<div class="photo-bar">`. When `img2` is present, add the `photo-bar--wide` modifier so the bar breaks out of the text column; with only `img1`, no modifier — it stays in-column.
- For each provided `imgN`, render a `<figure><img src="…" alt="…"></figure>`; if `capN` is present, append a `<figcaption>`. `alt` falls back to the matching `capN` (or empty).
- If `height` is provided, set inline `max-height` on each `<img>`; otherwise CSS supplies the 600px default.
- If `caption` is present, render one `<figcaption class="photo-bar__caption">` as the last child of the bar.
- Implemented as three explicit `img1/img2/img3` blocks (not a delimited array), keeping each caption adjacent to its photo at the call site. The mild repetition is contained inside this one small template.

### 2. CSS — `_sass/_layout.scss` (post-reading styles section)

```scss
.photo-bar {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1em;
  margin: 1.6em 0;

  figure { margin: 0; }
  img { max-height: 600px; width: auto; }
}

.photo-bar--wide {
  width: min(1100px, 94vw);
  position: relative;
  left: 50%;
  transform: translateX(-50%);
}

.photo-bar__caption {
  flex-basis: 100%;
  text-align: center;
  font-size: $small-font-size;
  color: $ink-soft;
  margin-top: 4px;
}
```

- Image borders are inherited from the existing `.post-content img { border: 1px solid $rule; }` rule — no new border declaration needed.
- Uses real palette/type vars (`$small-font-size`, `$ink-soft`), so the bar belongs to the "Desert ↔ Alpine" system rather than being a one-off.
- The `--wide` breakout centers relative to the column via `left:50%; translateX(-50%)`, capped at `min(1100px, 94vw)` so it never overflows narrow viewports.

### 3. Migration

| Current pattern | Posts | Becomes |
|---|---|---|
| `include image.html` | 2021 & 2020 year-in-review, niwots-2019/20/21, why-i-run, mile-78 | single-photo bar; `description` → `cap1` |
| `include image-3.html` | 2021 year-in-review | 3-photo bar; `description` → group `caption` |
| flex `<figure>` rows | utah-115, ring-the-springs, sd100-2024, barkley-2023, dark-divide-100, niwots-2023 | bars with `cap1/2/3` |
| bare `<img>` rows | paella, niwots-2023, niwots-2024 | bars, no captions |
| markdown `![](/img/…)` | teanaway-country-100 | bars (group the 5 trail photos into ≤3-photo bars) |

Rules:

- Bars longer than 3 photos (paella's 5, the 2020 review's 10 stacked singles) are split into consecutive bars of ≤3.
- A run of consecutive single `image.html` calls that are clearly one visual group may be combined into multi-photo bars at implementation discretion; when in doubt, preserve the original grouping (one bar per original call).
- After all callers are migrated, delete `_includes/image.html` and `_includes/image-3.html`.

## Verification

- `bundle exec jekyll build` succeeds with no Liquid errors.
- `grep -rn "include image.html\|include image-3.html" _posts/` returns nothing.
- Spot-check rendered output for a single-photo post, a 2-photo bar, a 3-photo bar, a group-caption bar (year-in-review), and teanaway.

## Out of Scope / YAGNI

- No lightbox, lazy-loading, srcset, or galleries — just static bars matching today's behavior.
- No conversion of external/screenshot markdown images.
- No change to the homepage Photographs section or `album-frame.html`.
