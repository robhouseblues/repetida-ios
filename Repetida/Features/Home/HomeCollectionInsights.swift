import Foundation

struct ClosestTeamInsight: Hashable {
    let team: Team
    let missing: Int
    let nextSticker: NormalizedSticker?
}

enum HomeCollectionInsights {
    static let quaseCompletaMaxMissing = 5

    static func closestTeams(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        maxMissing: Int = quaseCompletaMaxMissing,
        limit: Int = 3
    ) -> [ClosestTeamInsight] {
        let album = collection.albumProgress()
        guard album.total > 0, album.owned < album.total else { return [] }

        return catalog.teams
            .filter { $0.section == .national }
            .compactMap { team -> ClosestTeamInsight? in
                let progress = collection.progress(for: team.id)
                let missing = progress.total - progress.owned
                guard missing > 0, missing <= maxMissing else { return nil }
                let nextSticker = catalog.stickers(forTeamId: team.id).first { sticker in
                    !collection.status(for: sticker.code).isOwned
                }
                return ClosestTeamInsight(team: team, missing: missing, nextSticker: nextSticker)
            }
            .sorted { $0.missing < $1.missing }
            .prefix(limit)
            .map { $0 }
    }

    static func nationalTeamsInPagerOrder(catalog: CatalogRepository) -> [Team] {
        catalog.teamsInListOrder(sortBy: .albumPage, completionFraction: nil)
            .filter { $0.section == .national }
    }
}
