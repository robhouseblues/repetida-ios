# UX Review — Iteration 1 (Home + Team Screen)

## Summary

Iteration 1 successfully addressed the two highest-priority issues (Home stat clarity, missing sticker visibility). This document captures review findings, follow-up actions, and status.

**Overall:** ✅ Successful first UX pass. Direction is correct.

---

## UX-01 · Home stat — ✅ Shipped

| Before | After |
|--------|-------|
| `0%` / `0/48` / Seleções | `0/48` / Seleções concluídas |

**Follow-up (shipped in Iteration 1.1):** Removed redundant `%` line — count alone is clearer.

**Optional (deferred):** Label as "Times completos" when `completed > 0`.

---

## UX-02 · Missing sticker visibility — ✅ Shipped

Dashed green border + readable text. Major improvement over pre-iteration state.

**Follow-up (shipped in Iteration 1.1):** Brighter missing tile interior (`primaryMuted` tint ~16%, inner glow, no scanlines on missing).

**Optional (deferred):** Dedicated missing glyph instead of dashed ring icon.

---

## Iteration 1.1 — Shipped from review

| Item | Status |
|------|--------|
| Remove `%` from Home teams stat | ✅ |
| Brighter missing tile surface | ✅ |
| Bulk actions → ⋯ menu (team detail) | ✅ |
| Team pager: name + stronger affordance | ✅ |
| Team progress: `11/20 · 55%` | ✅ |
| "Todas \| Faltando" filter on team detail | ✅ |

---

## Open items (by priority)

### P1 — Next sprint

| ID | Item | Source |
|----|------|--------|
| UX-08 | Home: "Quase completas" section | Review + Roadmap |
| UX-07 | Home progress card: next milestone | Review + Roadmap |
| UX-10 | Team list search | Roadmap |
| UX-16 | Envelope cards (trade package UI) | Review + Roadmap |

### P2 — Polish & emotion

| ID | Item | Source |
|----|------|--------|
| UX-03 | Team row completion % on list | Roadmap |
| UX-12 | Lighter team section headers | Roadmap |
| UX-14 | Team completion celebration | Review |
| UX-15 | Album milestone celebrations | Review |

### Deferred

- Missing state icon redesign
- "Times completos" copy variant on Home
- Trade matching, cloud, barcode (see `UX_ROADMAP.md`)

---

## Principles check

Next gains come from:

1. **Reducing cognitive load** — bulk actions moved, Home stat simplified
2. **Improving collection workflows** — missing filter on team detail
3. **Making trading feel special** — envelope cards (next)
4. **Celebration moments** — milestones (planned)

---

## Related

- Full ranked backlog: [`UX_ROADMAP.md`](UX_ROADMAP.md)
