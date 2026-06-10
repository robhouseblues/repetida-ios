# UX Review — Trocar Screen Iteration 1

**Status:** Superseded by [Iteration 2](UX_REVIEW_TROCAR_ITERATION_2.md) for priorities and acceptance criteria.  
**Context:** Post UX-11 (drag affordance) + UX-16 (envelope cards). User testing surfaced structural clutter.

---

## Summary

Trocar accumulated **three parallel ways to do the same job**:

1. **Organizar em** carousel (Na pilha · envelopes · Tudo)  
2. **Bottom action pile** (Pilha · envelope · Remover · Troquei)  
3. **Selecionar** mode + selection bar (bulk move / remove)

The screen no longer feels like one workflow. It feels like three tools stacked on top of each other.

The physical metaphor is right (**Pilha → Envelope → Meetup**). The UI needs to commit to **one primary gesture** and **one organize strip**.

---

## What Trocar should be

> **Pack repetidas into envelopes, then share or mark what you traded.**

Not a dashboard. Not a multi-mode editor.

| User question | Answer on this screen |
|---------------|----------------------|
| What do I have to trade? | Pilha / envelope counts |
| Where does this copy go? | Drag to **Organizar em** |
| How do I share a package? | Share on active envelope |
| This copy is gone | **Troquei** or **Remover** on the sticker |
| I need many at once | Rare — don’t optimize the whole screen for it |

**Primary action:** drag sticker → envelope card (or Na pilha).  
**Secondary actions:** share envelope, remove copy, mark traded.  
**Tertiary:** sort, filter shiny, traded history (⋯ menu).

---

## Diagnosis (current screen)

### 1. Duplicate organize targets

When dragging, the user sees:

- **Na pilha** / **goats** in the carousel (top)  
- **Pilha** / **goats** again in the bottom dock (bottom)

Same destinations, two places. The carousel already has drop zones (UX-11). The dock repeats it and eats ~30% of the viewport.

### 2. Selecionar mode is a parallel app

**Selecionar** swaps the entire bottom chrome:

- Normal: drag dock  
- Selection: selection bar (Remover · Colocar no envelope · Tirar do envelope)

That’s a second organization system. Users must learn:

- Drag **or** select-then-tap  
- Different bars for each mode  
- Tiles show checkmarks; drag is disabled in selection mode

For meetup use, **drag-to-envelope is faster and matches the metaphor**. Selection mode made sense before envelope cards were drop targets; it’s now redundant for the common path.

### 3. Envelope “hero card” is cluttered

When an envelope is selected, the screen shows:

1. Large **ExchangeEnvelopeHeader** (name, stats, note, share, ⋯)  
2. The same envelope again in **Organizar em** (highlighted card)  
3. Bottom dock still showing **goats**

Three representations of one envelope. Stats appear in header *and* insight line. Share is a full-width button inside a card inside a card stack.

### 4. Remover / Troquei are buried

Destructive / completion actions live behind:

- Dock **Mais** → expand → bottom row  
- **Or** Selecionar → selection bar

They are core trading outcomes but treated as advanced. Users report they feel “almost hidden.”

### 5. Header density

Four labeled actions (Selecionar · Adicionar · Compartilhar · ⋯) compete for attention. **Selecionar** is the weakest fit for the simplified model. **Compartilhar** could be contextual (envelope-only) rather than always visible.

### 6. Vertical budget

Typical stack before the grid:

- Header + insight  
- Envelope header (when scoped)  
- Pack tip banner (sometimes)  
- Organizar em carousel  
- Bottom dock / selection bar  
- Tab bar  

The sticker grid — the actual work surface — gets squeezed.

---

## Target experience

### Layout (proposed)

```
┌─────────────────────────────────────┐
│ Trocar                    [+] [⋯]   │  ← slim header
│ 10 repetidas · 2 seleções           │  ← one insight line
├─────────────────────────────────────┤
│ Organizar em                        │
│ [Na pilha][goats 3][+][Tudo] →scroll│  ← ONLY organize + drop targets
├─────────────────────────────────────┤
│ [If envelope selected: thin bar]    │  ← note preview + Share (not hero card)
│  📩 goats · 3 repetidas  [Share]    │
├─────────────────────────────────────┤
│ BRAZIL (24-25)                      │
│ [sticker grid — hero content]         │
│                                     │
│ swipe tile → Remover | Troquei      │
└─────────────────────────────────────┘
│ tab bar                             │
└─────────────────────────────────────┘

While dragging:
  - Carousel cards pulse (existing UX-11)
  - Optional: single line hint “Solte no envelope”
  - NO bottom Pilha/goats dock
```

### Interaction model

| Gesture | Result |
|---------|--------|
| **Drag tile → Na pilha / envelope card** | Move copy (primary) |
| **Tap envelope card** | Change scope (view that package) |
| **Swipe tile left/right** | Remover · Troquei |
| **Long-press tile** | Quick actions sheet (optional) |
| **+** | Add repetida |
| **Share** (envelope scope only) | WhatsApp / export |
| **⋯** | Sort, shiny filter, traded history |

**Remove:** persistent bottom action pile for organize.  
**Remove or hide:** Selecionar mode (see roadmap options).

---

## Roadmap

| ID | Title | Priority | Effort |
|----|-------|----------|--------|
| **TROCAR-01** | Remove duplicate organize dock | **P0** | M |
| **TROCAR-02** | Retire Selecionar mode (or demote to ⋯) | **P0** | M |
| **TROCAR-03** | Slim envelope scope UI | **P1** | M |
| **TROCAR-04** | Tile swipe: Remover + Troquei | **P1** | S |
| **TROCAR-05** | Slim header actions | **P1** | S |
| **TROCAR-06** | Drag-only outcome strip (optional) | **P2** | S |
| **TROCAR-07** | Reduce insight / tip redundancy | **P2** | S |
| **TROCAR-08** | Organizar em destination chips (−15–20% height) | **P1** | S |

*Priorities refined in [Iteration 2](UX_REVIEW_TROCAR_ITERATION_2.md).*

---

### TROCAR-01 · Remove duplicate organize dock `P0`

**Problem:** Bottom dock duplicates Na pilha + envelope targets from carousel.

**Proposal:**
- Delete persistent `ExchangeDragDock` for organize (Pilha / envelope row).
- Keep drop zones on **Organizar em** carousel only (already wired).
- While dragging: optional floating hint text only (no duplicate buttons).
- Remover / Troquei move to TROCAR-04 (swipe), not dock.

**Acceptance criteria**
- [ ] No Pilha/envelope buttons at bottom during normal use
- [ ] Drag-to-carousel still works for all envelopes + Na pilha
- [ ] Grid gains visible rows (reduce bottom padding)

**Files:** `ExchangeView.swift`, `ExchangeDragDock.swift` (remove or repurpose)

---

### TROCAR-02 · Retire Selecionar mode `P0`

**Problem:** Second organization UX; confusing with drag.

**Proposal (recommended):** Remove selection mode entirely.

- Remove **Selecionar** header button and `ExchangeSelectionBar`.
- Remove selection checkmarks on tiles.
- Bulk edge case: defer or add later as “Select…” inside ⋯ if needed.

**Alternative (lighter):** Keep bulk select only in ⋯ → “Selecionar várias…” for power users; never a top-level labeled button.

**Acceptance criteria**
- [ ] One obvious path to move copies: drag to Organizar em
- [ ] No mode switch that replaces bottom UI
- [ ] Header has ≤3 visible actions

**Files:** `ExchangeView.swift`, `ExchangeViewModel.swift`, `ExchangeSelectionBar.swift`, `DSStickerTile.swift`

---

### TROCAR-03 · Compact envelope scope row `P1`

**Problem:** Hero card + carousel selection + dock = triple envelope chrome (confirmed Iteration 2).

**Proposal:**
- **Remove** large `ExchangeEnvelopeHeader` card entirely.
- Replace with one row when envelope scoped:
  - `📩 goats · 3 repetidas` — trailing **Compartilhar**
- Selected state in carousel remains the visual anchor (gold border).
- Rename/delete via ⋯ on scope row or envelope card context menu.

**Acceptance criteria**
- [ ] No hero card; exactly one compact scope row below Organizar em
- [ ] Share remains one tap (contextual to envelope)
- [ ] Rename/delete still available

*Visual spec: [Iteration 2](UX_REVIEW_TROCAR_ITERATION_2.md).*

**Files:** `ExchangeEnvelopeHeader.swift`, `ExchangeView.swift`

---

### TROCAR-04 · Tile swipe: Troquei + Remover `P1`

**Problem:** Core outcomes hidden behind dock “Mais” or selection mode.

**Proposal:**
- Swipe left on `DSStickerTile` in Trocar: **Troquei** first (gold, emphasized — success state), **Remover** second (destructive, secondary).
- Matches iOS patterns; always discoverable from grid.
- Keep mark-traded affordance on tile if swipe is insufficient (accessibility).

**Acceptance criteria**
- [ ] Troquei and Remover reachable in ≤2 gestures from any tile
- [ ] Troquei visually primary; Remover secondary
- [ ] No dependency on bottom dock or Selecionar
- [ ] Confirmation on Remover if needed

**Files:** `ExchangeView.swift`, `DSStickerTile.swift`

---

### TROCAR-05 · Slim header actions `P1`

**Problem:** Four labeled header controls crowd the title row.

**Proposal:**
- Default: **Adicionar** + **⋯** only.
- **Compartilhar** moves to envelope scope bar (TROCAR-03) or ⋯ when scope = envelope.
- Remove **Selecionar** (TROCAR-02).

**Acceptance criteria**
- [ ] Header fits on SE width without wrapping
- [ ] Primary actions obvious: add copy, more options

**Files:** `ExchangeView.swift`, `L10n.swift`

---

### TROCAR-06 · Drag-only outcome strip (optional) `P2`

**Problem:** After TROCAR-01, some users may still want drag-to-delete while dragging.

**Proposal:** Only if swipe testing feels weak — show **thin** bottom strip **while dragging only**:

`[ Remover ] [ Troquei ]` — no Pilha, no envelope.

**Acceptance criteria**
- [ ] Strip appears only during active drag
- [ ] Does not duplicate carousel organize targets

**Files:** `ExchangeView.swift`, new `ExchangeDragOutcomeStrip.swift`

---

### TROCAR-07 · Reduce insight / tip redundancy `P2`

**Problem:** Pack tip banner + insight line + envelope stats repeat the same coaching.

**Proposal:**
- Show pack tip once per user (existing flag), auto-dismiss.
- Single insight line rule: global **or** envelope-specific, never both large blocks.

**Acceptance criteria**
- [ ] At most one secondary text row below title in normal use

**Files:** `ExchangeView.swift`, `ExchangeViewModel.swift`

---

## Suggested implementation order

### Sprint A — De-clutter (P0)
1. **TROCAR-01** Remove organize dock  
2. **TROCAR-02** Retire Selecionar  

**Outcome:** One organize system; grid is the hero.

### Sprint B — Grid as hero (P1)
3. **TROCAR-03** Compact scope row (remove hero card)  
4. **TROCAR-08** Destination chips  
5. **TROCAR-05** Slim header  
6. **TROCAR-04** Swipe Troquei / Remover  

**Outcome:** ~12–14 stickers visible; trading outcomes discoverable.

### Sprint C — Polish (P2)
6. **TROCAR-07** Insight redundancy  
7. **TROCAR-06** Only if drag-outcomes still needed  

---

### TROCAR-08 · Organizar em destination chips `P1`

**Problem:** Carousel cards compete visually with the sticker grid.

**Proposal:**
- Reduce card height ~15–20%; chip-like density, still tappable drop targets.
- Visual weight: destination chips, not content cards.

**Acceptance criteria**
- [ ] Carousel row noticeably shorter than current UX-16 cards
- [ ] Drop targets and selection state unchanged

**Files:** `ExchangeCollectionPicker.swift`

---

## Success check

Before adding anything to Trocar, ask:

1. Does it support **packing** repetidas into envelopes?  
2. Is it the **same** action as something already on screen? → remove duplicate.  
3. Can the user **see stickers** without scrolling past chrome? (**Target: 70–80% of viewport = grid**)  
4. Are **Troquei** (primary) and **Remover** obvious without opening “Mais”?

---

## Related docs

- Iteration 2 refinements: [`UX_REVIEW_TROCAR_ITERATION_2.md`](UX_REVIEW_TROCAR_ITERATION_2.md)  
- Shipped: UX-04 (header labels), UX-11 (drag affordance), UX-16 (envelope cards)  
- Product pillar: `UX_ROADMAP.md` — Pilha → Envelope → Meetup → Trade
