# Repetida

SwiftUI iOS app for tracking your Panini FIFA World Cup 2026 sticker album — owned stickers, duplicates for exchange, and fast lookup. Interface in **Brazilian Portuguese** (`pt-BR`).

## Requirements

- Xcode 15+
- iOS 17+

## Open the project

```bash
cd repetida
xcodegen generate   # if Repetida.xcodeproj is missing
open Repetida.xcodeproj
```

Or open `Repetida.xcodeproj` directly after generation.

## Features

- **Home** — album completion, missing/duplicate stats, recently updated stickers
- **Lookup** — search by code, player name, or team; toggle owned / add duplicates
- **Teams** — browse by section with album page numbers; per-team sticker grid
- **Repetidas** — duplicate inventory (copy count per sticker) with share export

## Data

- `Repetida/Resources/panini-wc-2026-catalog.json` — 980-sticker standard edition catalog
- `Repetida/Resources/teams.json` — `Team` objects with `id`, `code`, `name`, `albumPages`

## Tests

```bash
xcodebuild -scheme Repetida -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' test
```
