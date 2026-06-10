import Foundation

enum StickerGroupSortOrder: String, CaseIterable, Identifiable {
    case albumPage
    case teamCode
    case name

    var id: String { rawValue }

    init(resolving raw: String) {
        if raw == "teamName" {
            self = .name
            return
        }
        self = StickerGroupSortOrder(rawValue: raw) ?? .albumPage
    }
}

enum StickerGroupSortHelper {
    static func compareTeams(_ lhs: Team, _ rhs: Team, order: StickerGroupSortOrder) -> Bool {
        switch order {
        case .albumPage:
            if lhs.firstAlbumPage != rhs.firstAlbumPage {
                return lhs.firstAlbumPage < rhs.firstAlbumPage
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        case .teamCode:
            return Team.compareByFifaCode(lhs, rhs)
        case .name:
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    static func sortStickersByAlbumOrder(_ stickers: [NormalizedSticker]) -> [NormalizedSticker] {
        stickers.sorted { NormalizedSticker.compareByAlbumOrder($0, $1) }
    }

    static func groupedCatalogStickers(
        catalog: CatalogRepository,
        query: String,
        order: StickerGroupSortOrder,
        includeSticker: (NormalizedSticker, Team) -> Bool = { _, _ in true }
    ) -> [(team: Team, stickers: [NormalizedSticker])] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var groups: [(team: Team, stickers: [NormalizedSticker])] = catalog.teams.compactMap { team in
            let stickers = catalog.stickers(forTeamId: team.id).filter { sticker in
                guard includeSticker(sticker, team) else { return false }
                guard !trimmed.isEmpty else { return true }
                let searchable = [
                    sticker.code,
                    sticker.name,
                    team.name,
                    team.code,
                ]
                .joined(separator: " ")
                .lowercased()
                return searchable.contains(trimmed)
            }
            guard !stickers.isEmpty else { return nil }
            return (team, sortStickersByAlbumOrder(stickers))
        }

        groups.sort { compareTeams($0.team, $1.team, order: order) }
        return groups
    }
}
