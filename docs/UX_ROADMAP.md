# Repetida UX Roadmap

Companion for completing and trading a World Cup album — not a sticker database.

**Core identity:** Coleção → Repetidas → Compartilhar (envelopes removed Jun 2026; tab renamed **Repetidas**)

**Full narrative:** [`UX_REVIEW_GLOBAL.md`](UX_REVIEW_GLOBAL.md) (Jun 2026 global product review)

**App snapshot:** [`APP_SUMMARY.md`](APP_SUMMARY.md)

---

## Executive summary (Jun 2026)

The app is beyond MVP. Collection flow is strong:

```text
Seleções → marcar tenho
Faltando → descobrir o que falta
Repetidas → inventário de repetidas
```

Core flows are cohesive across tabs. Remaining work is post-launch (trade matching, sync, scanning) unless new iteration reviews surface polish items.

---

## Product grades

| Screen | Grade | Notes |
|--------|-------|-------|
| Home | 9/10 | Unified card surfaces; human activity feed |
| Seleções | 9.5/10 | Grouped list V3 density; trophy + progress bar |
| Detalhe equipe | 9/10 | Lean header; full grid; swipe hint |
| Faltando | 9/10 | Sort chip consistency |
| Adicionar repetida | 8.5/10 | — |
| Repetidas | 9/10 | Inventory-first; summary strip; swipe remove; share export |
| **Overall** | **9/10** | Roadmap complete |

---

## Current status

| Tier | Open | Done (v1) |
|------|------|-----------|
| **P0** | — | UX-01, UX-02, TROCAR-03, TROCAR-SIMPLIFY |
| **P1** | — | UX-03–06, UX-08–10, UX-12–13, UX-04, UX-05, UX-11, TEAMS-01, TEAMS-02, DETAIL-01, MISSING-01, DS-01, HOME-01, HOME-02 |
| **P2** | — | UX-14, UX-15, UX-16, DS-03 (Home), HOME-03, TEAMS-03, TEAMS-04, DS-02, DETAIL-02 ↩, DETAIL-03, Lookup decision, TEAMS-LIST-01–06 |
| **P3** | — | UX-17–20 (deferred), MISSING-02 |

> **ID note:** `TROCAR-01`–`05` in this roadmap are from the **Global Product Review**. Earlier Trocar iteration IDs (dock removal, compact scope, etc.) are **shipped** — see [Trocar Iteration 2](UX_REVIEW_TROCAR_ITERATION_2.md).

---

## Phased roadmap

### Phase 1 — Trading simplification ✅

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | TROCAR-SIMPLIFY | Remove envelopes; aggregated duplicate grid | ✅ |
| 2 | TROCAR-03 | Swipe actions: Troquei / Remover | ✅ |
| 3 | — | Share all repetidas from header | ✅ |

**Cancelled (envelope model removed):** TROCAR-01, TROCAR-02, TROCAR-04, TROCAR-05, ADD-01

**Outcome:** Trocar shows all repetidas in one grid — one card per sticker with copy count, like Seleções.

---

### Phase 2 — Navigation polish ✅

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | TEAMS-01 | Seleções screen header (title + search) | ✅ |
| 2 | TEAMS-02 | Sort control redesign (`DSSortChip`) | ✅ |
| 3 | DETAIL-01 | Simplify team detail top region | ✅ |
| 4 | MISSING-01 | Faltando sort consistency (`DSSortChip`) | ✅ |
| 5 | DS-01 | Unified sort control component | ✅ |
| 6 | DS-04 | Unified screen header (`DSScreenHeader`) | ✅ |

**Outcome:** App feels cohesive across tabs — title-first headers, shared sort chip, leaner team detail.

---

### Phase 3 — Information architecture ✅

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | HOME-01 | Reduce Home card variety (2–3 styles max) | ✅ |
| 2 | HOME-02 | Activity feed — human copy, not DB labels | ✅ |
| 3 | DS-03 | Card pattern audit (Home) | ✅ |

**Outcome:** Cleaner visual language — hero progress card + shared compact list surface; activity uses human phrases + relative time.

---

### Phase 4 — Visual polish ✅

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | HOME-03 | Clarify completed teams stat | ✅ |
| 2 | TEAMS-03 | Settings-style grouped sections | ✅ |
| 3 | TEAMS-04 | Completed icon → trophy | ✅ |
| 4 | DS-02 | Unified section header | ✅ |
| 5 | MISSING-02 | Chip selected contrast | ✅ |

**Deferred:** DETAIL-03 (needs usage data) · Lookup (keep internal, no tab)

**Cancelled:** DETAIL-02 — neighbor hints removed; one-time swipe hint shipped instead

**Outcome:** Clearer Home stat, cohesive list grouping, stronger completion affordance.

---

### Phase 5 — Team list & detail refinement ✅

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | TEAMS-LIST-01 | Row breathing room (+12pt padding) | ✅ |
| 2 | TEAMS-LIST-02 | Wider progress bars (92pt) | ✅ |
| 3 | TEAMS-LIST-03 | Trophy as status badge above metrics | ✅ |
| 4 | TEAMS-LIST-04 | Reduce gold emphasis on completed count | ✅ |
| 5 | TEAMS-LIST-05 | Section header bottom spacing | ✅ |
| 6 | TEAMS-LIST-06 | Title / sort baseline alignment | ✅ |
| 7 | DETAIL-03 | Remove redundant missing filter | ✅ |

**Outcome:** Seleções rows breathe; progress bars dominate comparison; team detail is grid-only (Faltando tab owns missing discovery).

**Review:** [`UX_REVIEW_TEAMS_LIST_V2.md`](UX_REVIEW_TEAMS_LIST_V2.md)

---

## Active backlog (detail)

### TROCAR-SIMPLIFY · Remove envelopes `P0` ✅

**Decision (Jun 2026):** Drop Pilha / Envelope / scope picker entirely.

**Shipped**
- [x] Single grid of all stickers with `duplicateCount > 0`
- [x] One `DSStickerTile` per sticker (badge shows copy count)
- [x] `adjustDuplicates` / `markStickerTraded` for +/- and trade
- [x] Migration flattens existing envelope copies and deletes `TradeCollection` rows
- [x] Share button in header for full repetidas list

**Removed:** `ExchangeCollectionPicker`, envelope sheets, drag-to-organize, scope bar

---

### TROCAR-03 · Swipe actions `P0` ✅

**Problem:** Remove duplicate and mark traded are hidden (context menu only).

**Proposal:** Swipe left on duplicate tile → **Troquei** · **Remover**

**Acceptance**
- [x] Swipe reveals both actions on Pilha and envelope grids
- [x] Troquei uses existing `markCopyTraded` flow
- [x] Remover uses existing `removeDuplicateCopy`

**Files:** `ExchangeSwipeableTile.swift`, `ExchangeView.swift`

---

### HOME-01 · Reduce card variety `P1` ✅

Four card systems on Home (progress, stats, quase lá, activity). Target 2–3 shared styles.

**Shipped:** Hero `DSCard` for progress; `homeSecondaryCard()` (compact atmospheric) for stats, quase-completas, and activity rows.

**Files:** `HomeView.swift`

---

### HOME-02 · Activity feed redesign `P1` ✅

Replace technical labels (*Marcada como tenho*) with human copy (*adicionada à coleção*, relative time).

**Shipped:** `recentActivityDescription(kind:date:)` — e.g. *adicionada à coleção · há 2 min*; section title → *Atividade recente*. Trades excluded from feed; duplicate removals logged as *removida das repetidas*.

**Files:** `HomeView.swift`, `L10n.swift`, `Localizable.xcstrings`

---

### HOME-03 · Clarify completed teams stat `P2` ✅

Copy options: *Seleções completas 0/48* or *Concluídas · 0/48 seleções*

**Shipped:** Value `0/48`; label *Seleções concluídas*; accessibility *Seleções completas, X de Y*.

**Files:** `HomeView.swift`, `L10n.swift`

---

### TEAMS-01 · Screen header `P1` ✅

Match Trocar pattern: **Seleções** title, then search — not search-first.

**Files:** `TeamsView.swift`

---

### TEAMS-02 · Sort button redesign `P1` ✅

Replace detached sort icon with chip treatment (see DS-01).

**Files:** `TeamsView.swift`, `DSSortChip.swift`

---

### TEAMS-03 · Section grouping `P2` ✅

iOS Settings–style grouped sections (top/middle/bottom radius) instead of stacked individual cards.

**Shipped:** `DSGroupedListRowBackground` in Seleções list.

**Files:** `TeamsView.swift`, `DSGroupedListRowBackground.swift`

---

### TEAMS-04 · Completed icon review `P2` ✅

Gold checkmark may read as ambiguous. Explore trophy / seal / completion badge.

**Shipped:** `trophy.fill` for completed team rows.

**Files:** `DSTeamRow.swift`

---

### DETAIL-01 · Simplify top region `P1` ✅

Toolbar + title + pages + progress + filter feels busy. Reduce vertical stack; body grid is already strong.

**Shipped:** Removed pager neighbor hints + swipe coach mark; compact title/progress header.

**Note:** Bulk ⋯ menu (Marcar todas / Limpar) **removed** Jun 2026 — aligns with this item.

**Files:** `TeamDetailPagerView.swift`, `TeamDetailView` in `TeamsView.swift`

---

### DETAIL-02 · Pager design review `P2` ↩

Previous/next neighbor hints — validate comprehension with users.

**Superseded:** Neighbor row removed (DETAIL-01); `TeamPagerNavigationHint` teaches swipe + picker instead.

**Files:** `TeamDetailPagerView.swift`, `TeamPagerNavigationHint.swift`

---

### DETAIL-03 · Evaluate missing filter `P2` ✅

*Todas | Faltando (N)* — collect usage data before removing.

**Decision (Jun 2026):** Removed. Dedicated **Faltando** tab covers missing discovery; ~20 stickers fit in the grid without filtering. Deleted `DSSegmentedFilter`.

**Files:** `TeamDetailView` in `TeamsView.swift`

---

### MISSING-01 · Sort consistency `P1` ✅

Same detached sort icon issue as Seleções. Use `DSSortChip`.

**Shipped:** Title-first header (matches Seleções/Trocar); sort chip in title row.

**Files:** `MissingStickersView.swift`

---

### MISSING-02 · Chip selected contrast `P3` ✅

Minor increase in selected-state contrast on team chips.

**Shipped:** Stronger gold fill + border on selected Faltando team chips.

**Files:** `MissingTeamChipBar.swift`

---

### DS-01 · Unified sort control `P1` ✅

Single `DSSortChip` for Seleções, Faltando, and Trocar (moved out of overflow menu).

**Files:** `DSSortChip.swift`, `TeamsView.swift`, `MissingStickersView.swift`, `ExchangeView.swift`

---

### DS-04 · Unified screen header `P1` ✅

Single `DSScreenHeader` for title + trailing actions (sort, share, etc.) + search + optional subtitle.

**Styles:** `.inline` (Faltando, Repetidas, Adicionar repetida) · `.pinned` (Seleções `safeAreaInset`) · pushed screens use `pushedNavigationChrome()` for system back

**Files:** `DSScreenHeader.swift`, `TeamsView.swift`, `MissingStickersView.swift`, `ExchangeView.swift`, `ExchangeAddCopyView.swift`

---

### DS-02 · Unified section header `P2` ✅

Consolidate team headers across Seleções, Faltando, Trocar, Adicionar repetida.

**Shipped:** `DSSectionHeader(compact:)` backs `DSCompactSectionHeader`; team grids keep `DSTeamSectionHeader`.

---

### DS-03 · Card audit `P2` ✅ (Home)

Reduce variants: progress, stat, activity, envelope, team cards.

**Shipped (Home):** Two surfaces — hero `DSCard` + `homeSecondaryCard()`. Envelope cards removed with TROCAR-SIMPLIFY.

---

### Lookup · Tab or internal `P2` ✅

`LookupView` exists but is not in tab bar.

**Decision (Jun 2026):** Keep **internal** — four tabs cover core flows; Lookup remains in project for future deep link or dev access. No fifth tab.

---

## Deferred (post-launch)

| ID | Title |
|----|-------|
| UX-17 | Trade matching |
| UX-18 | Reserved stickers (“promised to João”) |
| UX-19 | Cloud sync |
| UX-20 | Barcode / pack scanning |

---

## Shipped — v1 iterations ✅

Historical work through Jun 2026. Detailed write-ups in linked review docs.

### Core UX (UX-01 – UX-20)

| ID | Title | Tier |
|----|-------|------|
| UX-01 | Clarify “Seleções” / Times completos stat | P0 ✅ |
| UX-02 | Brighter missing sticker tiles | P0 ✅ |
| UX-03 | Team row completion % | P1 ✅ |
| UX-04 | Trocar action labels / hierarchy | P1 ✅ |
| UX-05 | Repetidas stat → Trocar | P1 ✅ |
| UX-06 | Team detail Faltando filter | P1 ✅ |
| UX-07 | Home milestone (removed via HOME-13) | — |
| UX-08 | Home Quase completas | P1 ✅ |
| UX-09 | Faltando tab + grid (was Grid\|List) | P1 ✅ |
| UX-10 | Team list search | P1 ✅ |
| UX-11 | Trocar drag-drop affordance | P2 ✅ |
| UX-12 | Compact section headers | P1 ✅ |
| UX-13 | Bulk ⋯ menu (later **removed** — DETAIL-01) | P1 ✅→↩ |
| UX-14 | Team completion celebration + auto-lock | P2 ✅ |
| UX-15 | Album complete celebration | P2 ✅ |
| UX-16 | Envelope cards (carousel) | P2 ✅ |

### Trocar iteration 2 (shipped — different IDs from Global Review)

Grid-first layout, compact scope row, destination chips, slim header, swipe in iteration plan. See [`UX_REVIEW_TROCAR_ITERATION_2.md`](UX_REVIEW_TROCAR_ITERATION_2.md).

### Other shipped (post-review docs)

- Faltando as dedicated tab; team chips; album-page sort
- Near-black backgrounds (all screens except Home)
- Team picker sheet polish; auto-lock on team complete
- Activity log (tenho / não tenho / repetida / trocou)
- Ir para seleção bottom sheet

---

## Historical sprints

| Sprint | Focus | Status |
|--------|-------|--------|
| 1 | Missing & clarity (UX-01–03, 12–13) | ✅ |
| 2 | Completion motivation (UX-06, 08, 09) | ✅ |
| 3 | Trading identity (UX-04, 05, 11, 16) | ✅ |
| 4 | Emotional layer (UX-14, 15) | ✅ |
| 5 | Trocar simplification (Iteration 2) | ✅ |
| **6** | **Trocar simplification (no envelopes)** | **✅** |
| 7 | Navigation polish (Phase 2) | ✅ |
| 8 | Information architecture (Phase 3) | ✅ |
| 9 | Visual polish (Phase 4) | ✅ |
| 10 | Team list & detail refinement (Phase 5) | ✅ |

---

## Success check

Before adding any new item, ask:

1. Does it improve **progress** visibility?
2. Does it make **missing** stickers easier to find?
3. Does it strengthen **trading** workflow?
4. Does it **celebrate** achievement?

If none of the above → defer.

---

## Related docs

| Doc | Purpose |
|-----|---------|
| [`UX_REVIEW_GLOBAL.md`](UX_REVIEW_GLOBAL.md) | Global product review (source of active backlog) |
| [`APP_SUMMARY.md`](APP_SUMMARY.md) | Current screens & features |
| [`UX_REVIEW_TROCAR_ITERATION_2.md`](UX_REVIEW_TROCAR_ITERATION_2.md) | Shipped Trocar simplification |
| [`UX_REVIEW_REPETIDAS.md`](UX_REVIEW_REPETIDAS.md) | Repetidas inventory pivot (post-envelope) |
| [`UX_REVIEW_ITERATION_1.md`](UX_REVIEW_ITERATION_1.md) … [`UX_REVIEW_ITERATION_4.md`](UX_REVIEW_ITERATION_4.md) | Team screen iterations |
| [`UX_REVIEW_TEAMS_LIST_V2.md`](UX_REVIEW_TEAMS_LIST_V2.md) | Seleções grouped list V2→V3 |
| [`UX_REVIEW_HOME_ITERATION_3.md`](UX_REVIEW_HOME_ITERATION_3.md) … [`UX_REVIEW_HOME_ITERATION_6.md`](UX_REVIEW_HOME_ITERATION_6.md) | Home iterations |
| [`README.md`](../README.md) | Setup & build |
