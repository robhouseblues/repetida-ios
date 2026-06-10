# UX Review — Trocar Screen Iteration 2

**Status:** Shipped (TROCAR-01–08; TROCAR-06 skipped)  
**Context:** Envelope hero + contextual share landed. Triple representation and bottom dock remain.

**Prior review:** [`UX_REVIEW_TROCAR_ITERATION_1.md`](UX_REVIEW_TROCAR_ITERATION_1.md)

---

## Summary

This iteration is moving in the right direction.

The selected envelope is now much more visible and the sharing action finally feels connected to the envelope itself instead of being buried in the navigation bar.

However, Trocar still suffers from the same core issue:

> **Too much chrome, not enough stickers.**

The trading workflow is becoming clearer, but the screen still spends a lot of vertical space explaining itself instead of letting users work.

---

## What improved

### 1. Envelope context is much better

**Before:**

- Envelope selected in carousel
- No strong indication of current context
- Share button lived in top navigation

**After:**

```text
📩 goats
3 repetidas · 2 seleções · 0 brilhantes

[ Compartilhar envelope ]
```

This is much clearer. Users immediately understand which envelope they're viewing, what's inside, and what action is available.

**Keep this direction** — but compress it (see TROCAR-03).

---

### 2. Share is finally contextual

**Previously:**

```text
Trocar
[Compartilhar]
```

What are we sharing? The entire collection? An envelope? A screenshot? Not obvious.

**Now:**

```text
goats
[Compartilhar envelope]
```

The action is attached to the object. This follows iOS conventions much better.

---

### 3. Selected envelope is easier to understand

The highlighted envelope card plus header card create a stronger sense of scope. The user knows *"I am looking at envelope goats"* instead of *"I have an envelope called goats somewhere."*

Good improvement — but the header card is now redundant with the carousel selection (see below).

---

## Biggest problem — triple envelope representation

The screen shows the same envelope in **three places**:

| Where | What |
|-------|------|
| **A** | Large envelope hero — `📩 goats · 3 repetidas` |
| **B** | Selected card in **Organizar em** — `📩 goats · 3 repetidas` |
| **C** | Bottom drag sheet — `📩 goats` again |

The user already knows which envelope is active. The screen keeps repeating it.

### Recommendation

**Keep:** Organizar em carousel.  
**Keep:** Selected state on envelope card (gold border).  
**Remove:** Large hero card entirely.

**Replace with** a single compact row:

```text
Organizar em
[Na pilha][goats][+]

📩 goats · 3 repetidas                    Compartilhar
```

One line. Not an entire card.

→ **TROCAR-03**

---

## Biggest UX problem — bottom dock still dominates

Current layout:

```text
Grid
Bottom Dock
Tab Bar
```

The bottom dock is enormous — almost two rows of stickers.

### Why it feels wrong

Everything in the dock already exists elsewhere:

| Dock action | Already exists as |
|-------------|-------------------|
| Pilha | Carousel — Na pilha |
| goats | Carousel — selected envelope |
| Remover | Should be swipe (TROCAR-04) |
| Troquei | Should be swipe (TROCAR-04) |

The dock consumes prime real estate for duplicate actions.

### Recommendation

**Prioritize TROCAR-01 immediately.**

Remove Pilha / Envelope from dock — or preferably **remove the dock entirely**. The carousel already solved organize.

---

## Biggest opportunity — grid must become the hero

The product is not an **envelope manager**. It is a **sticker manager**.

The grid is where work happens. The grid should dominate the screen.

| Metric | Now | After cleanup |
|--------|-----|---------------|
| Visible stickers | ~6–8 | ~12–14 |

That's a huge usability improvement.

**Success criterion:** ≥70–80% of visible area should be stickers, not controls. Currently ~50%.

---

## Organizar em — destination chips

Current cards (Na pilha · goats · Novo envelope) work, but they visually compete with stickers.

### Recommendation

Reduce card height by **~15–20%**. Think **destination chips**, not content cards.

```text
Current visual weight:  ██████████
Desired:                ██████
```

Still tappable. Much less dominant.

→ **TROCAR-08** (new)

---

## Selecionar should be removed

Roadmap is correct.

**Current top bar:** Selecionar · Adicionar · Compartilhar · ⋯

The first action a user sees is the least important one.

**Real hierarchy:** `[+]` · `[⋯]` — that's it.

Bulk selection is an edge case. Trading individual duplicates is the main workflow. Do not optimize the entire screen around bulk actions.

→ **TROCAR-02** + **TROCAR-05**

---

## Troquei is more important than Remover

Current dock gives equal weight to Remover and Troquei. From a product perspective, **Troquei** is the success state.

### Recommendation

When swipe actions arrive:

```text
Swipe left:  Troquei  ·  Remover
```

**Troquei** visually emphasized (gold / primary). **Remover** secondary (destructive, smaller or trailing).

The app should celebrate successful trades, not deletion.

→ **TROCAR-04** (updated)

---

## Information hierarchy

**Current:**

```text
Title
Envelope hero
Organizar em
Grid
Dock
Tab bar
```

**Desired:**

```text
Title
Insight
Organizar em
Envelope scope row (if needed)
Grid
Tab bar
```

Everything else should disappear.

---

## Updated roadmap priorities

### P0 — ship first

| ID | Title |
|----|-------|
| **TROCAR-01** | Remove duplicate organize dock (prefer: remove entirely) |
| **TROCAR-02** | Remove Selecionar mode |

These two changes alone will make the screen feel dramatically lighter.

### P1 — complete the model

| ID | Title |
|----|-------|
| **TROCAR-03** | Replace envelope hero with compact scope row |
| **TROCAR-04** | Swipe actions — Troquei emphasized, then Remover |
| **TROCAR-05** | Slim nav bar — `[+]` `[⋯]` only |
| **TROCAR-08** | Organizar em: destination chips (−15–20% height) |

#### TROCAR-03 target

**Current:**

```text
╔════════════════════╗
║ 📩 goats           ║
║ 3 repetidas        ║
║ Compartilhar       ║
╚════════════════════╝
```

**Target:**

```text
📩 goats · 3 repetidas      Compartilhar
```

#### TROCAR-04 target

```text
Swipe left →  [ Troquei ]  [ Remover ]
              (emphasized)   (secondary)
```

### P2 — polish

| ID | Title |
|----|-------|
| **TROCAR-07** | Reduce insight / tip redundancy |
| **TROCAR-06** | Drag-only outcome strip — only if swipe feels insufficient |

---

## Success criteria

When opening Trocar, users should immediately understand:

1. What duplicates they have
2. Which envelope they're viewing
3. Where stickers can be dragged
4. How to share an envelope

And most importantly:

> **At least 70–80% of the visible area should be stickers, not controls.**

---

## Suggested implementation order

### Sprint A — De-clutter `P0`
1. TROCAR-01 — Remove dock  
2. TROCAR-02 — Remove Selecionar  

**Outcome:** ~4–6 more sticker rows visible; one organize system.

### Sprint B — Grid as hero `P1`
3. TROCAR-03 — Compact scope row (kill hero card)  
4. TROCAR-08 — Destination chips  
5. TROCAR-05 — Slim header  
6. TROCAR-04 — Swipe Troquei / Remover  

**Outcome:** Sticker-first screen; trading outcomes discoverable.

### Sprint C — Polish `P2`
7. TROCAR-07 — Insight redundancy  
8. TROCAR-06 — Only if needed  

---

## Related docs

- Iteration 1 diagnosis: [`UX_REVIEW_TROCAR_ITERATION_1.md`](UX_REVIEW_TROCAR_ITERATION_1.md)
- Master roadmap: [`UX_ROADMAP.md`](UX_ROADMAP.md)
