import Foundation

struct MissingTeamChip: Identifiable, Hashable {
    let team: Team
    let missingCount: Int

    var id: String { team.id }
}

enum MissingFilterHelper {
    static func teamChips(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: MissingSortOrder
    ) -> [MissingTeamChip] {
        groupedMissing(
            catalog: catalog,
            collection: collection,
            query: query,
            order: order,
            focusedTeamId: nil
        )
        .map { MissingTeamChip(team: $0.team, missingCount: $0.stickers.count) }
    }

    static func groupedMissing(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: MissingSortOrder,
        focusedTeamId: String?
    ) -> [(team: Team, stickers: [NormalizedSticker])] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var groups: [(team: Team, stickers: [NormalizedSticker])] = catalog.teams.compactMap { team in
            if let focusedTeamId, team.id != focusedTeamId { return nil }

            let stickers = catalog.stickers(forTeamId: team.id).filter { sticker in
                guard !collection.status(for: sticker.code).isOwned else { return false }
                guard !trimmed.isEmpty else { return true }
                let searchable = [
                    sticker.code,
                    sticker.name,
                    team.name,
                    team.code,
                ].joined(separator: " ").lowercased()
                return searchable.contains(trimmed)
            }
            guard !stickers.isEmpty else { return nil }
            return (team, StickerGroupSortHelper.sortStickersByAlbumOrder(stickers))
        }

        groups.sort { lhs, rhs in
            StickerGroupSortHelper.compareTeams(lhs.team, rhs.team, order: order)
        }

        return groups
    }
}
