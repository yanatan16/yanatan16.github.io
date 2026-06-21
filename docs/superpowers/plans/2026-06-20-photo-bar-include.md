# Photo-Bar Include Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the five different ways hosted photos are embedded in blog posts with a single `{% include photos.html %}` that renders a 1–3 photo bar in the current design system.

**Architecture:** One new Liquid include (`_includes/photos.html`) drives all photo embeds. Inline flex `<div>` styling is replaced by `.photo-bar` classes in `_sass/_layout.scss`. Single photos stay inside the 720px text column; 2–3 photo bars break out wider. Then ~16 hosted-photo posts are migrated and the legacy `image.html` / `image-3.html` includes are deleted. There is no test suite — `bundle exec jekyll build` plus `grep` checks are the verification steps.

**Tech Stack:** Jekyll 4.2.2, Liquid, SCSS.

## Global Constraints

- Convert **hosted-photo** posts only (`/img/...`, incl. teanaway's markdown photos). Leave external/inline markdown images (giphy, GitHub raw, Instagram/akamaihd, GT football screenshots) as plain markdown.
- A photo bar holds **1–3 photos**. Split any larger group into consecutive ≤3-photo bars.
- Captions are optional: per-photo `cap1/cap2/cap3` and/or one group `caption`.
- Image borders come from the existing `.post-content img { border: 1px solid $rule; }` — do not add per-image borders.
- Use existing palette/type vars (`$small-font-size`, `$ink-soft`) — no hardcoded colors.
- Verification command: `bundle exec jekyll build` (must succeed with no Liquid errors).

---

### Task 1: Create the `photos.html` include and `.photo-bar` styles

**Files:**
- Create: `_includes/photos.html`
- Modify: `_sass/_layout.scss` (insert after the `.post-content { … }` block, which ends at line ~275)

**Interfaces:**
- Produces: `{% include photos.html img1=… [img2=…] [img3=…] [cap1=…] [cap2=…] [cap3=…] [caption=…] [height=…] %}` — `img1` required; `img2`/`img3` optional and trigger the wide breakout; `capN` optional per-photo figcaption; `caption` optional group figcaption; `height` optional max-height px override (default 600 via CSS).

- [ ] **Step 1: Write the include**

Create `_includes/photos.html` with exactly this content:

```liquid
{%- if include.img2 or include.img3 -%}
  {%- assign bar_class = "photo-bar photo-bar--wide" -%}
{%- else -%}
  {%- assign bar_class = "photo-bar" -%}
{%- endif -%}
{%- if include.height -%}{%- assign img_style = "max-height: " | append: include.height | append: "px;" -%}{%- endif -%}
<div class="{{ bar_class }}">
{%- if include.img1 %}
  <figure><img src="{{ include.img1 }}" alt="{{ include.cap1 }}"{% if img_style %} style="{{ img_style }}"{% endif %}>{% if include.cap1 %}<figcaption>{{ include.cap1 }}</figcaption>{% endif %}</figure>
{%- endif -%}
{%- if include.img2 %}
  <figure><img src="{{ include.img2 }}" alt="{{ include.cap2 }}"{% if img_style %} style="{{ img_style }}"{% endif %}>{% if include.cap2 %}<figcaption>{{ include.cap2 }}</figcaption>{% endif %}</figure>
{%- endif -%}
{%- if include.img3 %}
  <figure><img src="{{ include.img3 }}" alt="{{ include.cap3 }}"{% if img_style %} style="{{ img_style }}"{% endif %}>{% if include.cap3 %}<figcaption>{{ include.cap3 }}</figcaption>{% endif %}</figure>
{%- endif -%}
{%- if include.caption %}
  <figcaption class="photo-bar__caption">{{ include.caption }}</figcaption>
{%- endif %}
</div>
```

- [ ] **Step 2: Add the styles**

In `_sass/_layout.scss`, immediately after the closing `}` of the `.post-content { … }` rule, add:

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

- [ ] **Step 3: Smoke-test the include against a temp page**

Create `_test-photos.html` at the repo root:

```html
---
layout: post
title: Photo bar smoke test
---
Single (in column):
{% include photos.html img1="/img/why-i-run.jpeg" cap1="Solo caption" %}

Two (wide):
{% include photos.html img1="/img/niwots-2023/book-10.jpeg" cap1="A" img2="/img/niwots-2023/book-11.jpeg" cap2="B" %}

Three with group caption:
{% include photos.html img1="/img/2021-year-in-review/james-pk-with-mandy.jpeg" img2="/img/2021-year-in-review/audubon-with-mandy.jpeg" img3="/img/2021-year-in-review/heart-lake-with-mandy.jpeg" caption="A high-country summer." %}
```

- [ ] **Step 4: Build and verify**

Run: `bundle exec jekyll build`
Expected: build succeeds. Then run `grep -o 'class="photo-bar[^"]*"' _site/_test-photos.html` and expect three matches: `photo-bar`, `photo-bar photo-bar--wide`, `photo-bar photo-bar--wide`.

- [ ] **Step 5: Remove the temp page and commit**

```bash
rm _test-photos.html
git add _includes/photos.html _sass/_layout.scss
git commit -m "Add photos.html include and .photo-bar styles"
```

---

## Migration reference (applies to Tasks 2–5)

Each migration replaces an old embed with one or more `photos.html` calls. The source line already contains the URL and caption — copy them into the matching slot. Apply these per-shape rules:

**A. Single `{% include image.html url=U description=D %}`** (any order, optional `height=H`) →
```liquid
{% include photos.html img1="U" cap1="D" %}
```
Drop the `height` unless the original set one; if it did, keep `height="H"`. If two/three `image.html` calls sit on consecutive lines as one visual group, combine into one bar (`img1/img2/img3`). When unsure, keep them as separate single bars.

**B. `{% include image-3.html img1=A img2=B img3=C description=D %}`** →
```liquid
{% include photos.html img1="A" img2="B" img3="C" caption="D" %}
```

**C. Hand-written flex `<div>` of `<figure><img …><figcaption>CAP</figcaption></figure>` rows** → one bar; each figure's `src` → `imgN`, its figcaption text → `capN`. Split into consecutive bars if >3 figures. Example:
```html
<div style="display: flex; …">
  <figure><img style="max-height: 600px;" src="/img/x/a.jpeg"/><figcaption>Climbing.</figcaption></figure>
  <figure><img style="max-height: 600px;" src="/img/x/b.jpeg"/><figcaption>Canyon.</figcaption></figure>
</div>
```
becomes
```liquid
{% include photos.html img1="/img/x/a.jpeg" cap1="Climbing." img2="/img/x/b.jpeg" cap2="Canyon." %}
```

**D. Hand-written flex `<div>` of bare `<img …>` rows (no figcaption)** → one bar, no captions. Split if >3. Example:
```html
<div style="display: flex; …">
  <img style="max-height: 400px; max-width: 100%;" src="/img/x/1.jpg"/>
  <img … src="/img/x/2.jpg"/>
</div>
```
becomes
```liquid
{% include photos.html img1="/img/x/1.jpg" img2="/img/x/2.jpg" %}
```

**E. Markdown `![ALT](/img/…)`** (hosted only) → `{% include photos.html img1="/img/…" cap1="ALT" %}`. If ALT is empty, omit `cap1`.

After editing each post, leave any surrounding blank lines so Markdown still parses paragraphs correctly (an include needs a blank line before/after if it was between paragraphs).

---

### Task 2: Migrate the two year-in-review posts

**Files:**
- Modify: `_posts/2021-12-31-running-year-in-review.markdown` (rules A + B)
- Modify: `_posts/2020-12-31-2020-running-year-in-review.markdown` (rule A, lines ~45–54: ten consecutive `image.html` singles)

**Interfaces:**
- Consumes: the include from Task 1.

- [ ] **Step 1: Migrate `2021-12-31-running-year-in-review.markdown`**

Replace the two `image.html` singles (greys-and-torreys, sjs) per rule A and all `image-3.html` calls per rule B. The `description` on each becomes the group `caption`. Keep each bar where its original call sat.

- [ ] **Step 2: Migrate `2020-12-31-2020-running-year-in-review.markdown`**

Lines ~45–54 are ten consecutive single `image.html` calls forming one photo recap. Group them into consecutive 3-photo bars (3+3+3+1): keep each photo's `description` as its `cap`. Use:
```liquid
{% include photos.html img1="/img/2020-year-in-review/disney-marathon.jpeg" cap1="Finishing the Walt Disney World Marathon" img2="/img/2020-year-in-review/isaquah.jpeg" cap2="Running in Isaquah, WA" img3="/img/2020-year-in-review/antelope-canyon.jpeg" cap3="Horseshoe bend in the Colorado River during Antelope Canyon 100" %}
```
…and so on for niwots-training/old-train-bridge/apple-running, then mountain/shavano/skyline, then last-skyline alone.

- [ ] **Step 3: Build and verify**

Run: `bundle exec jekyll build`
Expected: succeeds. Then `grep -rn "include image" _posts/2021-12-31-running-year-in-review.markdown _posts/2020-12-31-2020-running-year-in-review.markdown` returns nothing.

- [ ] **Step 4: Commit**

```bash
git add _posts/2021-12-31-running-year-in-review.markdown _posts/2020-12-31-2020-running-year-in-review.markdown
git commit -m "Migrate year-in-review posts to photos.html"
```

---

### Task 3: Migrate the remaining `image.html` posts

**Files (all rule A):**
- Modify: `_posts/2021-04-21-niwots-challenge-2021.markdown` — 9 singles, each standalone → keep as single bars
- Modify: `_posts/2020-06-01-race-report-niwots-challenge-2020.markdown` — singles at ~108, ~158–161 (four consecutive: make 3+1 or 2+2), and ~116–117 (two consecutive with `height="600"` → one 2-photo bar with `height="600"`)
- Modify: `_posts/2020-06-09-why-i-run.markdown` — 1 single
- Modify: `_posts/2019-02-20-mile-78.markdown` — 2 singles (non-adjacent)
- Modify: `_posts/2019-04-30-niwots-challenge-race-report.markdown` — 4 singles (non-adjacent)

- [ ] **Step 1: Migrate all five posts** per rule A. For adjacent groups, combine into one bar (≤3); keep `height="600"` where the original had it.

- [ ] **Step 2: Build and verify**

Run: `bundle exec jekyll build`
Expected: succeeds. Then `grep -rln "include image" _posts/2021-04-21-niwots-challenge-2021.markdown _posts/2020-06-01-race-report-niwots-challenge-2020.markdown _posts/2020-06-09-why-i-run.markdown _posts/2019-02-20-mile-78.markdown _posts/2019-04-30-niwots-challenge-race-report.markdown` returns nothing.

- [ ] **Step 3: Commit**

```bash
git add _posts/2021-04-21-niwots-challenge-2021.markdown _posts/2020-06-01-race-report-niwots-challenge-2020.markdown _posts/2020-06-09-why-i-run.markdown _posts/2019-02-20-mile-78.markdown _posts/2019-04-30-niwots-challenge-race-report.markdown
git commit -m "Migrate remaining image.html posts to photos.html"
```

---

### Task 4: Migrate the flex-`<figure>` race reports (rule C)

**Files:**
- Modify: `_posts/2025-05-22-utah-115.markdown` — multiple 2-photo `<figure>` bars
- Modify: `_posts/2023-12-20-ring-the-springs.markdown` — multiple 2-photo `<figure>` bars
- Modify: `_posts/2025-09-12-dark-divide-100.markdown` — the live `<figure>` bar(s); **leave HTML comment blocks (`<!-- … -->`) untouched**
- Modify: `_posts/2024-06-10-san-diego-100-2024.markdown` — mix: bare `<img>` singles (~28, 44, 68) use rule D; `<figure>` rows (~91–92, 101–102, 113, 154, 196, 208–216, 246) use rule C

- [ ] **Step 1: Migrate the four posts** per rules C (and D where noted). Each `<div style="display:flex…">…</div>` block becomes one `photos.html` call (split if >3 figures). Preserve any HTML-commented-out blocks verbatim.

- [ ] **Step 2: Build and verify**

Run: `bundle exec jekyll build`
Expected: succeeds. Then `grep -rln "display: flex" _posts/2025-05-22-utah-115.markdown _posts/2023-12-20-ring-the-springs.markdown _posts/2025-09-12-dark-divide-100.markdown _posts/2024-06-10-san-diego-100-2024.markdown` returns only `dark-divide-100` (its commented-out block) — verify utah-115, ring-the-springs, sd100 return nothing.

- [ ] **Step 3: Commit**

```bash
git add _posts/2025-05-22-utah-115.markdown _posts/2023-12-20-ring-the-springs.markdown _posts/2025-09-12-dark-divide-100.markdown _posts/2024-06-10-san-diego-100-2024.markdown
git commit -m "Migrate flex-figure race reports to photos.html"
```

---

### Task 5: Migrate bare-`<img>` rows and teanaway markdown (rules D + E)

**Files:**
- Modify: `_posts/2023-12-18-paella-recipe.markdown` — one bare-`<img>` `<div>` of 5 → split 3+2 (rule D)
- Modify: `_posts/2023-05-10-niwots-challenge-2023.markdown` — bare-`<img>` `<div>`s (book-5 single; book-10/11 pair; abram-and-i; finish-with-abram; mylar-baloon) per rule D; note the book-10/11 imgs use `max-width:49%` — drop that, the bar handles layout
- Modify: `_posts/2024-05-25-niwots-challenge-2024.markdown` — 4 bare-`<img>` `<div>` singles (rule D)
- Modify: `_posts/2022-09-26-race-report-teanaway-country-100.markdown` — 5 standalone markdown images (rule E): first_climb, esmerelda_pass, alpine_pass, ranier, finish

- [ ] **Step 1: Migrate the four posts** per rules D and E.

- [ ] **Step 2: Build and verify**

Run: `bundle exec jekyll build`
Expected: succeeds. Then:
- `grep -rln "display: flex" _posts/2023-12-18-paella-recipe.markdown _posts/2023-05-10-niwots-challenge-2023.markdown _posts/2024-05-25-niwots-challenge-2024.markdown` returns nothing.
- `grep -rn '!\[.*\](/img/teanaway' _posts/2022-09-26-race-report-teanaway-country-100.markdown` returns nothing.

- [ ] **Step 3: Commit**

```bash
git add _posts/2023-12-18-paella-recipe.markdown _posts/2023-05-10-niwots-challenge-2023.markdown _posts/2024-05-25-niwots-challenge-2024.markdown _posts/2022-09-26-race-report-teanaway-country-100.markdown
git commit -m "Migrate bare-img rows and teanaway markdown to photos.html"
```

---

### Task 6: Delete legacy includes and final verification

**Files:**
- Delete: `_includes/image.html`
- Delete: `_includes/image-3.html`
- Modify: `CLAUDE.md` (the Layouts & Includes line that mentions `image.html`/`image-3.html`)

- [ ] **Step 1: Confirm no remaining callers**

Run: `grep -rn "include image.html\|include image-3.html" _posts/ _drafts/ races/`
Expected: no output. If any remain, migrate them per the reference rules before continuing.

- [ ] **Step 2: Delete the legacy includes**

```bash
git rm _includes/image.html _includes/image-3.html
```

- [ ] **Step 3: Update CLAUDE.md**

In the `_includes/` bullet under "Layouts & Includes," replace the `image.html`/`image-3.html` mention with `photos.html` (1–3 photo bars).

- [ ] **Step 4: Final build + grep sweep**

Run: `bundle exec jekyll build`
Expected: succeeds. Then `grep -rln "display: flex; flex-wrap" _posts/` should list only `2025-09-12-dark-divide-100.markdown` (commented-out block). Confirm no live photo `<div>`s remain.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Delete legacy image includes; document photos.html"
```

---

## Self-Review

- **Spec coverage:** include (Task 1) ✓; CSS classes + breakout (Task 1) ✓; per-photo + group captions (Task 1 include) ✓; all five source patterns migrated (Tasks 2–5, rules A–E) ✓; teanaway in scope (Task 5) ✓; >3-photo split (paella, 2020 review — Tasks 2 & 5) ✓; legacy includes deleted (Task 6) ✓; verification via build + grep (every task) ✓.
- **Excluded correctly:** external/screenshot markdown (giphy, GitHub, Instagram, GT football) left untouched; dark-divide commented block preserved.
- **Type consistency:** include param names (`img1/img2/img3`, `cap1/cap2/cap3`, `caption`, `height`) and CSS class names (`photo-bar`, `photo-bar--wide`, `photo-bar__caption`) are identical across Task 1 and the migration reference.
