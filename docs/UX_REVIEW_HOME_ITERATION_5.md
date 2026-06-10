# UX Review — Home Screen Iteration 5

**Status:** Implemented (HOME-20 through HOME-22)

## Summary

Iteration 4 fixed metric meaning but oversized the stat row and softened urgency with “restante(s)”. Iteration 5 restores information density and collector tone while keeping the meaningful two-metric direction.

## Issues addressed

### HOME-20 · Compact secondary stat cards `P0`

**Problem:** Stat cards rivaled the trade banner in visual weight.

**Shipped:**
- Replaced full `DSCard` wrapper with compact surface (`DSRadius.sm`, `DSSpacing.sm` padding)
- Value/title area heights reduced ~27% (44→32, 32→24)
- Display font 22→18; single-line labels
- Two cards remain side-by-side at equal width

### HOME-21 · “Falta/Faltam” wording `P0`

**Problem:** “1 restante” felt like inventory language.

**Shipped:** Badge copy is now **Falta 1** / **Faltam N**.

### HOME-22 · Above-the-fold density `P1`

**Problem:** Large hero cluster pushed first “Quase completa” below the fold.

**Shipped:**
- Progress + trade + stats grouped with tighter `heroClusterSpacing` (12pt)
- Section gaps reduced xl→lg (16pt)
- Progress ring slightly smaller on Home (108pt) with tighter internal spacing

## Unchanged (by design)

- Trade banner copy and behavior
- Two meaningful stats: Faltando · Times completos
- Quase completas two-line hierarchy (team → sticker)

## Deferred ideas

- Near-win badge accent (⭐/🏁) — low priority
- “3 Quase completos” as future stat replacement — explore later

## Files

- `HomeView.swift`
- `L10n.swift`, `Localizable.xcstrings`
- `docs/UX_ROADMAP.md`
