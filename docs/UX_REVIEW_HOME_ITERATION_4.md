# UX Review — Home Screen Iteration 4

**Status:** Implemented (HOME-17 through HOME-19)

## Summary

Iteration 3 fixed noise but drifted toward a metrics dashboard. Iteration 4 refocuses Home as a **collection guide** — every element should help decide what sticker to hunt, what team to finish, or what trade to make.

## Issues addressed

### HOME-17 · Remove “Iniciadas” `P0`

**Problem:** “48 Iniciadas” is technically correct but drives no behavior.

**Shipped:** Middle stat card removed. Stat row reduced to two decision-oriented cards: **Faltando** and **Times completos**.

### HOME-18 · Clarify team completion metric `P0`

**Problem:** “Concluídas” was ambiguous (concluded what?).

**Shipped:** Label changed to **Times completos** with `0/48` value. VoiceOver keeps explicit accessibility string.

### HOME-19 · Redesign “Quase completas” cards `P1`

**Problem:** `USA USA` redundancy; missing count detached on the right.

**Shipped:**
- Line 1: flag + team name only (`🇺🇸 USA`)
- Line 2: next missing sticker as hero (`USA9 • Tanner Tessmann`)
- Goal badge: `1 restante` / `N restantes` (gold capsule)
- Tap → team detail pager (unchanged)

### Trade banner polish (low)

When envelope count is zero, copy is now **13 repetidas disponíveis** instead of implying zero envelopes.

## Home hierarchy (current)

1. Album progress ring
2. Trade banner (when duplicates or envelopes exist)
3. Stats: Faltando · Times completos
4. Quase completas
5. Recent activity

## Files

- `HomeView.swift`
- `HomeCollectionInsights.swift`
- `L10n.swift`, `Localizable.xcstrings`
- `docs/UX_ROADMAP.md`
