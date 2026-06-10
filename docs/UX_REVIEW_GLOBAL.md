# Repetida UX Roadmap — Global Product Review

> **Superseded (Jun 2026):** Envelope / Pilha concepts were removed. Trocar is now a single aggregated repetidas grid. See [`UX_ROADMAP.md`](UX_ROADMAP.md) · TROCAR-SIMPLIFY and [`APP_SUMMARY.md`](APP_SUMMARY.md).

## Executive Summary

The app is already beyond MVP quality.

The collection flow is strong:

```text
Seleções → marcar tenho
Faltando → descobrir o que falta
Trocar → organizar repetidas
```

The core problem today is not missing features.

The problem is:

> Some screens still feel like tools.
> They don't yet feel like a single cohesive product.

The biggest UX debt is concentrated in Trocar.

Everything else is mostly polish.

---

# Priority Overview

## P0 — Critical UX

### TROCAR
The entire trading experience

This is currently the weakest area of the app.

Reasons:

- unclear mental model
- envelope concept not obvious
- difficult duplicate lifecycle
- sharing not central enough
- removal/trade actions hidden

---

## P1 — Important Polish

### Team Detail
Header and pager clarity

### Team List
Visual hierarchy and section cards

### Home
Information architecture cleanup

### Faltando
Sort control consistency

---

## P2 — Nice To Have

### Lookup
Decide whether it becomes a tab or remains internal

### Minor design-system consistency
Buttons
Sort controls
Sheet headers
Badges

---

# TROCAR

## Current State

Trocar still feels like:

```text
Inventory manager
```

instead of:

```text
Prepare for a sticker meetup
```

The user journey isn't obvious.

---

# Main Problem

When opening Trocar, users don't immediately understand:

```text
What is a Pilha?
What is an Envelope?
Why should I create one?
When do I use it?
```

The UI exposes implementation concepts before teaching the workflow.

---

# Desired Mental Model

The app should teach:

```text
1. Open packs
2. Accumulate repetidas
3. Put interesting ones in envelopes
4. Share envelope
5. Go trade
6. Mark traded
```

That story is currently missing.

---

## TROCAR-01
Introduce Empty-State Education

When user has no envelopes:

```text
📩 Envelopes ajudam você a organizar trocas.

Crie um envelope para separar figurinhas para um encontro,
grupo de WhatsApp ou amigo específico.

[ Criar envelope ]
```

Current UI jumps straight into envelope mechanics.

Need onboarding.

Priority: P0

---

## TROCAR-02
Make Sharing First-Class

Current:

```text
Create envelope
Put stickers inside
Open menu
Share
```

Sharing is the reason envelopes exist.

The share affordance should feel central.

Recommendation:

Envelope scope:

```text
📩 goats · 24 repetidas

[ Compartilhar ]
```

Large primary action.

Priority: P0

---

## TROCAR-03
Sticker Swipe Actions

Current:

No obvious way to:

- remove duplicate
- mark traded

These are core actions.

Proposal:

Swipe left:

```text
Troquei
Remover
```

Priority: P0

---

## TROCAR-04
Envelope Naming Guidance

Current:

User creates:

```text
goats
```

or random names.

Consider placeholder suggestions:

```text
Grupo Curitiba
Troca Junho
Meetup Shopping
WhatsApp Futebol
```

Makes concept clearer.

Priority: P2

---

## TROCAR-05
Envelope Visual Identity

Current envelopes feel like:

```text
generic filter cards
```

Need stronger identity.

Possibilities:

- larger envelope icon
- subtle gold treatment
- count badge more prominent

User should instantly know:

```text
this is a package I'm preparing
```

Priority: P1

---

# HOME

## Current State

Mostly solved.

One of the strongest screens now.

---

# HOME-01
Reduce Card Variety

Current screen contains:

- Progress card
- Stat cards
- Almost complete cards
- Activity cards

Four visual card systems.

Feels slightly fragmented.

Goal:

Reduce to 2-3 card styles maximum.

Priority: P1

---

# HOME-02
Improve Activity Feed

Current:

```text
FWC18 Germany 2014

Marcada como tenho
Marcada como não tenho
```

Feels technical.

Not very meaningful.

---

Possible redesign:

```text
Você encontrou

FWC18 Germany 2014
há 2 minutos
```

or

```text
FWC18 Germany 2014
adicionada à coleção
```

Less database-like.

Priority: P1

---

# HOME-03
Clarify Completed Teams

Current:

```text
0/48 Times completos
```

Better than before but still abstract.

Possible copy:

```text
Seleções completas
0/48
```

or

```text
Concluídas
0/48 seleções
```

Priority: P2

---

# SELEÇÕES LIST

## Current State

Good functionality.

Needs visual polish.

---

# TEAMS-01
Add Proper Screen Header

Current:

Search appears immediately.

Feels abrupt.

Recommendation:

```text
Seleções

[ Search ]
```

Same pattern as Trocar.

Priority: P1

---

# TEAMS-02
Redesign Sort Button

Current sort icon feels detached from design language.

Recommendation:

Use same chip treatment used elsewhere.

Visual consistency.

Priority: P1

---

# TEAMS-03
Section Grouping Cards

Current rounded cards look odd when stacked.

Feels like:

```text
Card
Card
Card
Card
```

instead of:

```text
Grouped list
```

Recommendation:

Explore grouped sections:

- top rounded
- middle flat
- bottom rounded

iOS Settings style.

Priority: P2

---

# TEAMS-04
Completed Icon Review

Current gold checkmark feels slightly ambiguous.

Question:

```text
Completed?
Special?
Verified?
```

Explore:

- trophy
- seal
- completion badge

Priority: P2

---

# TEAM DETAIL

## Current State

Body is excellent.

Header still feels awkward.

---

# DETAIL-01
Simplify Top Region

Current stack:

```text
Back
Code
Pager
Share

Title
Pages

Progress

Filter
```

Feels busy.

The content below is much cleaner.

Priority: P1

---

# DETAIL-02
Review Pager Design

Current previous/next hints are functional.

Not sure they're visually understood as navigation.

Need testing.

Priority: P2

---

# DETAIL-03
Evaluate Missing Filter

Current:

```text
Todas
Faltando (1)
```

Useful but maybe unnecessary.

Since all 20 stickers fit naturally in the grid.

Question:

Would users actually use it?

Collect feedback before removing.

Priority: P2

---

# FALTANDO

## Current State

Almost complete.

One of the strongest screens.

---

# MISSING-01
Sort Button Consistency

Same issue as Teams.

Feels bolted on.

Should use shared design component.

Priority: P1

---

# MISSING-02
Chip Hierarchy

Current chips work well.

Could slightly increase selected-state contrast.

Minor.

Priority: P3

---

# ADD DUPLICATE

## Current State

Good.

Almost done.

---

# ADD-01
Optional Sticky Context

If launched from envelope:

```text
Adicionando ao envelope:
📩 goats
```

Small scope indicator.

Not required.

Priority: P3

---

# DESIGN SYSTEM CLEANUP

## DS-01
Unified Sort Control

Currently appears in:

- Seleções
- Faltando

Potentially Trocar

Create:

```text
DSSortChip
```

single component.

Priority: P1

---

## DS-02
Unified Section Header

Current team headers appear in:

- Seleções
- Faltando
- Trocar
- Adicionar repetida

Worth consolidating.

Priority: P2

---

## DS-03
Card Audit

Current app contains too many card patterns.

Audit:

- progress cards
- stat cards
- activity cards
- envelope cards
- team cards

Try to reduce variants.

Priority: P2

---

# Suggested Roadmap

## Phase 1 — Finish Trading

Highest impact.

1. TROCAR-01 Empty-state education
2. TROCAR-02 Sharing-first workflow
3. TROCAR-03 Swipe actions
4. TROCAR-05 Envelope identity

Outcome:

```text
Users understand envelopes.
Users can trade confidently.
```

---

## Phase 2 — Navigation Polish

1. TEAMS-01 Header
2. TEAMS-02 Sort redesign
3. DETAIL-01 Top region cleanup
4. MISSING-01 Sort consistency

Outcome:

```text
The app feels cohesive.
```

---

## Phase 3 — Information Architecture

1. HOME-01 Card simplification
2. HOME-02 Activity redesign
3. DS-03 Card audit

Outcome:

```text
Cleaner visual language.
```

---

# Current Product Grade

| Screen | Grade |
|--------|-------|
| Home | 8.5/10 |
| Seleções | 8.5/10 |
| Detalhe equipe | 8/10 |
| Faltando | 9/10 |
| Adicionar dup. | 8.5/10 |
| Trocar | 6.5/10 |
| **Overall** | **8.2/10** |

The app no longer feels like a side project.

The remaining UX risk is almost entirely concentrated in Trocar. If Trocar reaches the same level of clarity as Faltando, Repetida will feel like a very polished, focused product.

---

## Related docs

- [`UX_ROADMAP.md`](UX_ROADMAP.md) — actionable backlog, acceptance criteria, sprint plan
- [`APP_SUMMARY.md`](APP_SUMMARY.md) — current screens & features
