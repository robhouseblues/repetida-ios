# Repetida — App Summary

SwiftUI iOS app for tracking your **Panini FIFA World Cup 2026** sticker album. Interface in **Brazilian Portuguese** (`pt-BR`). Targets **iOS 17+**.

**Catalog:** 980-sticker standard edition (EU-only shiny variants ending in `s` excluded).

**Core workflow:** mark stickers as you open packs → see what's missing → track repetidas → share list before meetups.

---

## Navigation

Three bottom tabs (icon-only tab bar):

| Tab | Label | Icon |
|-----|-------|------|
| Home | Início | house |
| Teams | Seleções | flags |
| Repetidas | Repetidas | stacked squares |

App-wide overlays:
- **Album complete** banner when all 980 stickers are owned (once per completion cycle)
- Launch error screen with retry if SwiftData fails to load

---

## Início (Home)

**Background:** gradient atmospheric background (only screen that keeps it).

### Progress card
- Ring showing owned / total stickers (e.g. `611 / 980`)
- “Álbum completo!” when 100% done

### Stat cards (tap to navigate)
| Card | Goes to | Shows |
|------|---------|-------|
| Faltando | Seleções tab | Missing sticker count |
| Repetidas | Repetidas tab | Total duplicate copies |
| Seleções concluídas | Seleções tab (sorted by completion) | Completed national teams / 48 |

### Quase lá
- Hidden when the **album is complete** or when no national team has **5 or fewer** missing stickers
- Up to 3 closest national teams (by missing count)
- Each row: flag + name, next missing sticker, “faltam N” badge
- Tap opens that team in the team pager

### Atualizados recentemente
- Last 8 collection activities (read-only rows)
- Labels: “Marcada como tenho”, “Marcada como não tenho”, “Repetida adicionada”, “Trocou”
- Shows current sticker status badge

---

## Seleções (Teams)

**Background:** flat near-black.

### Team list
- Grouped by album section: Panini, Tournament, Hosts, History, National Teams
- Each row: flag, name, FIFA code, album pages, progress bar, owned/total
- **Search** by name, code, or “We Are …” title
- **Sort:** Página do álbum · Código FIFA · Nome (A–Z) · Conclusão (%)

### Team detail (pager)
Opened from list or Home “Quase lá”. Horizontal swipe between teams in current sort order.

**Toolbar**
- Center: current team flag + FIFA code → opens **Ir para seleção** bottom sheet
- Trailing: lock / unlock page

**Header**
- Team title + album page range
- Progress bar + owned/total

**Sticker grid** (4 columns)
- Tap: toggle tenho / não tenho
- Long press: add duplicate
- Context menu: toggle owned, add/remove duplicate
- Stickers ordered by album page within team

**Locking**
- Manual lock via toolbar
- **Auto-lock** when team reaches 100%
- Auto-unlock if a sticker is unmarked
- Locked state: banner, disabled interactions, muted actions

**Completion**
- Dismissible banner when team is completed for the first time (“Seção completa!”)
- Shown once per team until team becomes incomplete again

**Navigation aids**
- Swipe between teams; toolbar team picker; one-time swipe hint
- Dismissible swipe coach mark
- **Ir para seleção** sheet: 4-column grid of flag + FIFA code shortcuts (near-black, centered title)

**Removed:** bulk “Marcar todas” / “Limpar seleção” overflow menu.

---

## Repetidas

**Background:** flat near-black. Duplicate **inventory** — not a trading workflow.

### Summary strip
- `N repetidas · M figurinhas únicas · K brilhantes`

### Duplicate grid
- 3-column tiles grouped by team (section headers, no outer card)
- **One card per sticker** with copy count on the status badge (+N)
- **Drag** a card to reveal dock: **Remover repetida** · **Adicionar repetida** (no tap, no context menu)
- Chip filters: **Todas** · **Brilhantes** · **+2 ou mais** · team chips

### Sort options
Página do álbum · Código FIFA · Nome (A–Z) · Quantidade (sections by total copies; stickers always album order)

### Header actions
- **Share** — duplicate inventory (WhatsApp text, story/square images, plain export)
- **Adicionar** → full-screen grid picker (`ExchangeAddCopyView`)

### Add duplicate screen
- Same `DSScreenHeader` as other tabs (title + sort + search)
- Sort: Página do álbum · Código FIFA · Nome (A–Z)
- **Recentemente adicionadas** horizontal row (last 12 unique stickers from activity log)
- Searchable grid of all catalog stickers by team
- Tap adds one copy; stays on screen

### Share sheet
- WhatsApp text: “Tenho repetidas:” + per-team list + total
- Story/square image cards
- Copy to clipboard

---

## Orphan screen (not in tab bar)

**Lookup** (`LookupView`) — search stickers globally, toggle owned, add duplicates, sticker detail sheet. Built and in the project but **not wired to the tab bar** in the current app shell.

---

## Sticker interactions (global)

| Action | Effect |
|--------|--------|
| Tap owned tile | Mark as não tenho |
| Tap missing tile | Mark as tenho |
| Add duplicate | New `DuplicateCopy` in Pilha (or target envelope) |
| Remove duplicate | Deletes one copy |
| Mark traded (Troquei) | Removes one copy silently |

**Activity log** persists ownership changes, duplicate adds, and explicit duplicate removals for Home history.

---

## Celebrations

| Event | UI |
|-------|-----|
| Team 100% | `DSTeamCompletionBanner` on team screen (once) |
| Album 100% | `DSAlbumCompletionBanner` app-wide (once) |

---

## Data & persistence

**Local-first SwiftData** (`SwiftDataCollectionRepository`):

| Model | Purpose |
|-------|---------|
| `StickerEntry` | Owned flag, duplicate count sync, `updatedAt` |
| `DuplicateCopy` | Internal copy records (synced to `duplicateCount`; no envelopes) |
| `TradeCollection` | Legacy schema only — migrated away on launch |
| `CollectionActivity` | Recent activity feed |

**Bundled JSON:**
- `album-catalog.json` — stickers
- `teams.json` — teams with album pages and sections

**UserDefaults preferences:** sort orders, lock state, filter toggles, celebration flags, dismissed coach marks.

**Launch:** store recovery + in-memory fallback; error screen instead of crash on failure.

---

## Visual system

| Context | Background |
|---------|------------|
| Home | Gradient (`AtmosphericBackground`) |
| All other screens & sheets | Near-black (`ScreenBackground` / `#030304`) |

**Design language:** dark canvas, Brazilian green primary, gold foil secondary, owned/missing/duplicate sticker tile states, haptic feedback on key actions.

---

## Tests

Coverage includes catalog normalization, team/sort helpers, exchange sort, flag emoji mapping, completion/lock celebration stores, and trade repository behavior.

---

## Related docs

- [`UX_REVIEW_GLOBAL.md`](UX_REVIEW_GLOBAL.md) — global product review and phased roadmap (Jun 2026)
- [`UX_ROADMAP.md`](UX_ROADMAP.md) — earlier iteration backlog
- [`README.md`](../README.md) — setup and build instructions
