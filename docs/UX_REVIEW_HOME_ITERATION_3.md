# UX Review — Home Screen Iteration 3

**Status:** Implemented (HOME-13 through HOME-16)

## Summary

Iteration 3 made Home more proactive — trade activity and “Quase completas” answer *what should I do next?* The direction is correct; this pass simplifies noise and makes goals more actionable.

## What improved (keep)

- **Quase completas** — micro-goals by fewest missing stickers
- **Trade banner** — `N repetidas · M envelope(s) pronto(s)` → Trocar tab
- **Section order** — progress → trade → stats → quase completas → recent activity

## Issues addressed

### HOME-13 · Remove “Próxima meta” `P0`

**Problem:** Milestone under the ring (`Próxima meta: 735 · faltam 124`) felt arbitrary next to `62%` / `611/980`.

**Shipped:** Milestone line removed. Progress card shows ring + “Conclusão do álbum” (or “Álbum completo!” at 100%). `AlbumMilestoneHelper` removed.

### HOME-14 · Eliminate duplicate metrics `P1`

**Problem:** Duplicate count appeared in trade banner and middle stat card.

**Shipped:** Middle stat replaced with **Iniciadas** — national teams with at least one owned sticker. Tap → Seleções tab. Trade banner keeps duplicate + envelope context.

### HOME-15 · Normalize stat card heights `P1`

**Problem:** “Seleções concluídas” wrapped to two lines; uneven row.

**Shipped:** Label shortened to **Concluídas**. Fixed value and title area heights on all three stat cards.

### HOME-16 · Improve “Quase completas” actionability `P2`

**Problem:** Rows showed team + “faltam N” but not where to look in the album.

**Shipped:** FIFA code badge on team row; subtitle shows next missing sticker (`USA14 Christian Pulisic`). Chevron + `NavigationLink` → team detail pager (unchanged).

## Deferred / notes

- **Recent activity** — lower priority if Home gets crowded in future iterations
- **Celebrations (UX-14/15 in roadmap)** — still open; decoupled from removed milestone copy

## Files

- `HomeView.swift`
- `HomeCollectionInsights.swift`
- `L10n.swift`, `Localizable.xcstrings`
- `docs/UX_ROADMAP.md`
