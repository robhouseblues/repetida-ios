# UX Review — Home Screen Iteration 6

**Status:** Implemented (HOME-23 through HOME-25)

## Summary

Iteration 5 optimized collection density but trading lost pillar status. Iteration 6 rebalances: **inventory in stats, action in banner**.

## Issues addressed

### HOME-23 · Restore Repetidas stat `P1`

**Problem:** Duplicate count invisible on Home; trading felt secondary.

**Shipped:** Three compact stat cards:

`Faltando` · `Repetidas` · `Times completos`

Repetidas taps → Trocar tab (primary green accent).

### HOME-24 · Action-focused trade banner `P1`

**Problem:** Banner repeated duplicate inventory already shown in stats.

**Shipped:** Banner communicates trading readiness only:

| State | Copy |
|-------|------|
| Envelope ready | `1 envelope pronto para troca` / `N envelopes prontos para troca` |
| Duplicates, no envelope | `Nenhum envelope pronto` (nudge to organize) |
| No duplicates | Hidden |

Principle: **stats = inventory, banner = action**.

### HOME-25 · Lighter recent activity `P2`

**Problem:** Recent rows visually heavy vs collection goals.

**Shipped:** `StickerResultRow(isCompact: true)` on Home — smaller padding, tighter type, no team subtitle line.

## Home hierarchy (current)

1. Album progress
2. Trade action banner (when trading-relevant)
3. Stats: Faltando · Repetidas · Times completos
4. Quase completas
5. Recent activity (compact)

## Deferred

- Near-win badge accent (🏁/⭐) on quase completas — low priority
- “Seleções completas” wording tweak — optional later

## Files

- `HomeView.swift`
- `StickerResultRow.swift`
- `L10n.swift`, `Localizable.xcstrings`
- `docs/UX_ROADMAP.md`
