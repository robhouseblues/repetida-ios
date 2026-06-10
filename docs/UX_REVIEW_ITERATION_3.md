# UX Review — Team Screen Iteration 3

## Summary

Iteration 3 improved sticker hierarchy and filter UX but cluttered information architecture and weakened album identity.

**Iteration 3.1** targets the ideal combination:

- Iteration 3 sticker grid + segmented filter
- Iteration 1 **We Are…** album section title
- Single team identity (nav code + header title)
- Navigation row for movement only

---

## Shipped in Iteration 3.1

| Item | Change |
|------|--------|
| **UX-08** Album section identity | Restored `We Are Australia` + page range in team header |
| **UX-09** Remove duplication | Nav bar: `🇦🇺 AUS` only; header: section title + pages (no repeated name/code) |
| **UX-10** Simplify navigation | Row: `← Argentina` … `Austria →` — current team removed from pager |
| Nav visual weight | Lighter background, thinner border, smaller height |
| Segmented filter | Reduced selected-segment fill opacity |

---

## Information hierarchy (target)

1. **Nav bar** — `🇦🇺 AUS` (where you are)
2. **Pager** — `← prev` / `next →` (how to move) — visually quiet
3. **Header** — `We Are Australia` `36–37` + progress
4. **Filter** — `Todas` / `Faltando (8)`
5. **Grid** — hero content

---

## Deferred (low priority)

- Custom missing-slot icon (album semantics)
- Further pager polish

See [`UX_ROADMAP.md`](UX_ROADMAP.md) for next sprint items (Home motivation, envelope cards).
