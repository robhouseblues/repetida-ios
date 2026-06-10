import Foundation

enum ExchangeQuickFilter: Equatable {
    case all
    case shiny
    case twoOrMore
    case team(String)
}

struct ExchangeTeamChip: Identifiable, Hashable {
    let team: Team
    let duplicateCount: Int

    var id: String { team.id }
}

enum ExchangeFilterHelper {
    static func allDuplicateItems(
        catalog: CatalogRepository,
        collection: CollectionRepository
    ) -> [ExchangeStickerItem] {
        catalog.allStickers.compactMap { sticker -> ExchangeStickerItem? in
            let status = collection.status(for: sticker.code)
            guard status.duplicateCount > 0 else { return nil }
            return ExchangeStickerItem(sticker: sticker, status: status)
        }
    }

    static func teamChips(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: ExchangeSortOrder
    ) -> [ExchangeTeamChip] {
        groupedDuplicates(
            catalog: catalog,
            collection: collection,
            query: query,
            order: order,
            filter: .all
        )
        .map { group in
            let copies = group.stickers.reduce(0) { $0 + $1.duplicateCount }
            return ExchangeTeamChip(team: group.team, duplicateCount: copies)
        }
    }

    static func filteredItems(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: ExchangeSortOrder,
        filter: ExchangeQuickFilter
    ) -> [ExchangeStickerItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let items = allDuplicateItems(catalog: catalog, collection: collection)
            .filter { item in
                switch filter {
                case .all:
                    break
                case .shiny:
                    guard item.sticker.isShiny else { return false }
                case .twoOrMore:
                    guard item.duplicateCount >= 2 else { return false }
                case .team(let teamId):
                    guard catalog.team(for: item.sticker)?.id == teamId else { return false }
                }

                guard !trimmed.isEmpty else { return true }
                let team = catalog.team(for: item.sticker)
                let searchable = [
                    item.sticker.code,
                    item.sticker.name,
                    team?.name,
                    team?.code,
                ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .lowercased()
                return searchable.contains(trimmed)
            }

        return items
    }

    static func groupedDuplicates(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: ExchangeSortOrder,
        filter: ExchangeQuickFilter
    ) -> [(team: Team, stickers: [ExchangeStickerItem])] {
        let items = filteredItems(
            catalog: catalog,
            collection: collection,
            query: query,
            order: order,
            filter: filter
        )
        return ExchangeSortHelper.groupedByTeam(items, catalog: catalog, order: order)
    }
}
