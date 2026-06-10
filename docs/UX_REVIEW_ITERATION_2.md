# UX Review — Team Screen Iteration 2

## Summary

Iteration 2 improved discoverability (navigation, progress %, missing filter, overflow menu) but regressed **scanability** — owned and missing stickers looked too similar.

**Iteration 2.1** combines the best of both:

- Iteration 1 ownership hierarchy (dark missing / green owned)
- Iteration 2 navigation, progress, filter, and menu improvements

---

## UX-06 · Restore sticker state hierarchy — ✅ Shipped (2.1)

**Owned:** Filled green tint, stronger border, glow, checkmark.

**Missing:** Dark interior (dim overlay), dashed border only, no green fill, white code, gray name, muted slot icon.

**Goal:** Pattern scanning — green blocks vs dark gaps.

---

## Segmented filter — ✅ Shipped (2.1)

Replaced native `Picker(.segmented)` with `DSSegmentedFilter` matching app tokens (surface, chrome border, capsule segments).

**Faltando** shows count: `Faltando (8)`.

---

## Team navigation — ✅ Shipped (2.1)

Continuous row in one bar:

`◀ Argentina` · `🇦🇺 Australia / AUS` · `Austria ▶`

Reduced dead space; center team anchors the row.

---

## Team header — ✅ Shipped (2.1)

Title-first: **flagged team name** hero, `AUS · Pages 36–37` secondary.

Progress `12/20 · 60%` unchanged.

---

## Open (from review)

| ID | Item | Priority |
|----|------|----------|
| UX-07 | Further pager layout polish | P1 |
| — | Dedicated missing glyph exploration | Optional |
| UX-08+ | Home motivation, envelope cards | P1 |

See [`UX_ROADMAP.md`](UX_ROADMAP.md).
