# UX Review — Repetidas (Post-Envelope Simplification)

> **Status:** Sprint A + B + C (partial) implemented (Jun 2026)

## Product pillar

The screen answers: **Which stickers do I have duplicated right now?**

It is an **inventory** screen, not a trading workflow. Envelopes, piles, and trade packaging are gone.

---

## Shipped

| ID | Item | Priority |
|----|------|----------|
| Rename | Tab, title, strings: **Trocar → Repetidas** | P0 |
| DUP-01 | Remove trading language from active UI (Troquei swipe, mark traded, “para troca” share copy) | P0 |
| DUP-02 | Quantity-first tiles (+N badge per sticker type) | P0 |
| DUP-04 | Remove permanent red minus; **swipe-only** “Remover repetida” | P0 |
| DUP-03 | Summary strip: `N repetidas · M figurinhas únicas · K brilhantes` | P1 |
| DUP-06 | Share export: “Tenho repetidas:” intro + per-team list + total | P1 |
| DUP-08 | Team sections match Faltando (header + grid, no outer card) | P1 |
| DUP-05 | “Recentemente adicionadas” row in Add Duplicate picker | P2 |
| DUP-07 | **+2 ou mais** quantity filter chip | P3 |
| — | Removed `markStickerTraded` API and Troquei tile affordances | cleanup |

## Kept as-is

| ID | Item |
|----|------|
| DUP-09 | Search — core feature, no changes |
| DUP-10 | Brilhantes filter — prominent chip |

## Deferred

| ID | Item | Priority |
|----|------|----------|
| DUP-07 | More filters (mais recentes, seleção, etc.) | P3 |
| DUP-11 | Revisit dedicated activity/history model | P3 |

---

## Target screen structure (v1)

```
Repetidas
[Search]
129 repetidas · 87 figurinhas únicas · 13 brilhantes
[Todas] [Brilhantes] [CAN] [CZE] [KOR]

🇨🇦 Canada
[Tiles]

🇧🇦 Bosnia
[Tiles]
```

## Success criteria

1. How many duplicates do I have?
2. Which duplicates do I have?
3. How many copies of each sticker?
4. How can I share my duplicate list?

Users should **not** need to understand envelopes, piles, or trade packaging.
