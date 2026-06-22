# High Lonesome 100 highlight on the homepage — design

**Date:** 2026-06-21
**Status:** Approved design, pending implementation plan

## Goal

Add a fourth homepage highlight: a first-class feature for **High Lonesome 100**,
a 100-mile mountain race in Colorado's Sawatch Range, foregrounding Jon's
volunteer leadership role (**Communications & Runner Tracking Director**) and
linking out to `highlonesome100.com`. It is an evergreen feature — stable
content, no dates that go stale.

## Context

The homepage (`index.html`) is a stack of numbered highlight sections:
`01 Photographs`, `02 Writing`, and `03 Podcast` (the last added concurrently —
already documented in `CLAUDE.md`). This is `04 High Lonesome 100`, placed after
the Podcast section.

The first three sections are **data-feed-driven**: each surfaces a list of items
(albums, posts, episodes) from a `_data/*.yaml` file kept fresh by a `rake` task
and a GitHub Action, rendered as repeated rows/frames. **This highlight is
deliberately different.** It is a single, stable, hand-authored block with no
external source to sync — structurally closer to the hero banner / masthead
(which are inlined directly in `index.html`) than to the feeds. So it ships with
**no data file, no include, and no sync workflow** (YAGNI). If a second "role"
highlight ever appears, extract a shared partial then — not now (DRY: don't
abstract until the second use).

## Approach

Chosen presentation: **editorial split** — a two-column block under the standard
`04 High Lonesome 100` section header. A landscape course photo on the left
carries the place; a text column on the right carries the role, a one-sentence
description, an evergreen stat line, and a link to the race. It reuses the
existing `.sec` / `.sec-head` machinery so it matches the page's
`01 / 02 / 03` rhythm, and reads as distinct from the wide hero banner at the top
of the page (no second full-bleed photo band).

Rejected alternatives: a cinematic wide photo band with the role overlaid (risks
competing with the top hero banner) and a stacked text-forward variant with a
thin photo strip (too understated for a leadership highlight). A "you on course"
portrait and a combined scenic-plus-inset treatment were also mocked; the plain
scenic landscape was chosen for fit with the site's photography voice.

## Content (final copy)

- **Section header:** index `04`, title `High Lonesome 100`, `more` link
  **"Visit the race →"** → `https://highlonesome100.com`.
- **Role label** (uppercase, salt-flat blue): `Communications & Runner Tracking
  Director`.
- **Description:** "A 100-mile mountain race through the **Sawatch Range** above
  Nathrop, Colorado. Each July I run communications and live runner tracking for
  the event." (`<b>` on "Sawatch Range" per the `.blurb` treatment.)
- **Stat line** (three items; evergreen — no race date, which changes yearly):
  - `100` — **Miles**
  - `23,500′` — **Climb**
  - `13,150′` — **High point**
  - Value in ink, label in desert coral uppercase (mirrors the `.sec-head .idx`
    coral accent).
- **Text CTA link:** `highlonesome100.com →` → `https://highlonesome100.com`.

Facts confirmed from `highlonesome100.com`: 100 miles, 23,500′ vertical gain,
13,150′ high point, Sawatch Range out of Nathrop, CO.

## Photo

One scenic landscape: a lone runner on singletrack below the Sawatch wall
(source file `HighLonesome1002024-JC-09147.jpg`, ~3:2, carries a small
"High Lonesome 100" logo mark bottom-right — kept as-is). Unlike the Photographs
section's album covers (remote Cloudflare R2 URLs), this is a **local repo
asset**, like `img/banner.jpg`: committed to `img/highlonesome.jpg`, downscaled
to ~1600px on the long edge for web. The photo is wrapped in a link to the race
site and rendered with the existing `.frame .img` image treatment (cover-fit,
slight desaturation, subtle hover scale, hairline inset border).

## Components

### 1. Homepage section (`index.html`)

Appended after the Podcast section's closing `</section>`:

```liquid
<section class="sec">
  <div class="sec-head reveal d4">
    <span class="idx">04</span>
    <h2>High Lonesome 100</h2>
    <a class="more meta" href="https://highlonesome100.com" target="_blank" rel="noopener">Visit the race <span class="arr">&rarr;</span></a>
  </div>
  <div class="role-feature reveal d4">
    <a class="role-photo" href="https://highlonesome100.com" target="_blank" rel="noopener" aria-label="High Lonesome 100 course in the Sawatch Range">
      <span class="img"><img loading="lazy" src="{{ "/img/highlonesome.jpg" | prepend: site.baseurl }}" alt="A runner on singletrack below the Sawatch Range, High Lonesome 100"></span>
    </a>
    <div class="role-body">
      <p class="role-tag">Communications &amp; Runner Tracking Director</p>
      <p class="role-blurb">A 100-mile mountain race through the <b>Sawatch Range</b> above Nathrop, Colorado. Each July I run communications and live runner tracking for the event.</p>
      <ul class="role-stats">
        <li><span class="v">100</span><span class="k">Miles</span></li>
        <li><span class="v">23,500&prime;</span><span class="k">Climb</span></li>
        <li><span class="v">13,150&prime;</span><span class="k">High point</span></li>
      </ul>
      <a class="role-link" href="https://highlonesome100.com" target="_blank" rel="noopener">highlonesome100.com <span class="arr">&rarr;</span></a>
    </div>
  </div>
</section>
```

No `{% if %}` guard — the content is static, not data-driven, so it always
renders. Reuses `.sec`, `.sec-head`, `.idx`, `.more`, `.arr`, `.reveal` and the
`.img` photo treatment; adds the `.role-*` classes styled in Component 2.

The `.reveal d4` delay matches the Writing section; the Podcast section (also
`d4`) and this one share the same reveal tier, which is fine — the stagger is a
nicety, not a strict order.

### 2. Styles (`_sass/_layout.scss`)

A new `.role-feature` block, added after the existing section blocks. Reuses the
`.frame .img` rules already in the file for the photo (so the cover-fit /
hover-scale / inset-border treatment is shared, not duplicated):

- `.role-feature` — two-column grid, photo ~1.35fr / text ~1fr, generous gap,
  `align-items: center`.
- `.role-photo .img` — share the existing photo treatment by **adding
  `.role-photo .img`, `.role-photo .img img`, `.role-photo:hover .img img`, and
  `.role-photo .img::after` to the existing `.frame …` selector groups** (one
  comma-extended rule set, not a copy), then add a single `.role-photo .img`
  override for the `16 / 10` aspect ratio (the frames use `4 / 5`).
- `.role-tag` — uppercase, letter-spaced, `$blue`, small — mirrors the role
  label weight/spacing used elsewhere.
- `.role-blurb` — reuse `.blurb` sizing/color (`$ink-soft`, `<b>` → `$ink`).
- `.role-stats` — flex row, gap; each `li` stacks a bold `.v` (`$ink`,
  tabular-nums) over a small uppercase `.k` (`$coral`). Mirrors the
  `.sec-head .idx` coral accent.
- `.role-link` — `$blue`, hover darken, with the same `.arr` translate-on-hover
  behavior as `.sec-head .more`.
- **Mobile:** collapse `.role-feature` to a single column (photo above text) in
  the existing homepage media query, consistent with how `.frames` / `.entry`
  collapse.

### 3. Photo asset (`img/highlonesome.jpg`)

Commit the downscaled scenic shot. No code, just the binary asset referenced by
Component 1.

### 4. Docs (`CLAUDE.md`)

The homepage description currently says the landing is "two-section"
(Photographs + Writing). The Podcast work updates that for `03`; this work
extends it to note the `04 High Lonesome 100` highlight — a **static,
hand-authored** feature (contrast with the data-driven sections), inlined in
`index.html` with `.role-feature` styles and the `img/highlonesome.jpg` asset, no
data file or sync. Keep the edit small and merge cleanly with the Podcast doc
change.

## Out of scope (YAGNI)

- No `_data/*.yaml`, `rake` task, or sync workflow — nothing to sync.
- No live race-weekend tracking link or countdown — evergreen only.
- No reusable "role feature" include — there is exactly one.
- No masthead identity-line / blurb change — that block is being edited by the
  concurrent Podcast work; staying out of it avoids a merge conflict.

## Isolation from concurrent Podcast work

Changes are confined to: an appended section in `index.html`, a new `.role-*`
style block in `_sass/_layout.scss`, the `img/highlonesome.jpg` asset, and a
small `CLAUDE.md` note. The masthead is untouched. The only shared files are
`index.html` (append-only, after the Podcast section) and `CLAUDE.md`
(additive) — both low-conflict.

## Verification

`bundle exec jekyll build` is the project's verification step (no test suite).
Confirm the build succeeds and the `04 High Lonesome 100` section renders with
the photo, role label, description, three stats, and working race links.
