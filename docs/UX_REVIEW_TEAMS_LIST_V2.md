# Team List UX Review — Iteration V1 → V2 → V3

## Overall

V2 introduced stronger IA (title, sort chip, grouped list, trophy). V3 restored breathing room and progress-bar balance from V1.

## Shipped (V3)

| ID | Change |
|----|--------|
| TEAMS-LIST-01 | Row vertical padding `4pt` → `12pt` |
| TEAMS-LIST-02 | Progress bar width `72pt` → `92pt` |
| TEAMS-LIST-03 | Trophy above metrics (status badge, not inline) |
| TEAMS-LIST-04 | Completed count uses muted text; gold on trophy + bar only |
| TEAMS-LIST-05 | `+8pt` below compact section headers |
| TEAMS-LIST-06 | Title / sort chip `firstTextBaseline` alignment |

## Kept from V2

- Screen title **Seleções**
- `DSSortChip`
- Grouped national team sections (`DSGroupedListRowBackground`)
- Trophy for completed teams

## Deferred

- TEAMS-LIST-04 long-term: *Completa* / *100%* copy instead of `5/5 · 100%`

## Files

- `DSTeamRow.swift`
- `TeamsView.swift`
- `DSSectionHeader.swift`
