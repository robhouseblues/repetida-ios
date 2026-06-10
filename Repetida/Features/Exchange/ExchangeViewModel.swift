import Foundation

@Observable
final class ExchangeViewModel {
    var sortOrder: ExchangeSortOrder = .albumPage

    func allDuplicateItems(
        catalog: CatalogRepository,
        collection: CollectionRepository
    ) -> [ExchangeStickerItem] {
        ExchangeFilterHelper.allDuplicateItems(catalog: catalog, collection: collection)
    }

    func groupedSections(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        filter: ExchangeQuickFilter
    ) -> [(team: Team, stickers: [ExchangeStickerItem])] {
        ExchangeFilterHelper.groupedDuplicates(
            catalog: catalog,
            collection: collection,
            query: query,
            order: sortOrder,
            filter: filter
        )
    }

    func teamChips(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String
    ) -> [ExchangeTeamChip] {
        ExchangeFilterHelper.teamChips(
            catalog: catalog,
            collection: collection,
            query: query,
            order: sortOrder
        )
    }

    func insightText(
        catalog: CatalogRepository,
        collection: CollectionRepository
    ) -> String {
        let items = allDuplicateItems(catalog: catalog, collection: collection)
        let totalCopies = items.reduce(0) { $0 + $1.duplicateCount }
        let uniqueStickers = items.count
        let shiny = items.filter(\.sticker.isShiny).reduce(0) { $0 + $1.duplicateCount }
        return L10n.exchangeInsight(totalCopies, uniqueStickers, shiny)
    }

    func whatsAppText(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        filter: ExchangeQuickFilter
    ) -> String {
        let groups = groupedSections(
            catalog: catalog,
            collection: collection,
            query: query,
            filter: filter
        )
        let totalCopies = groups
            .flatMap(\.stickers)
            .reduce(0) { $0 + $1.duplicateCount }
        return ExchangeWhatsAppExporter.format(groups: groups, totalCopies: totalCopies)
    }

    func sharePayload(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        filter: ExchangeQuickFilter
    ) -> ExchangeSharePayload {
        let items = ExchangeFilterHelper.filteredItems(
            catalog: catalog,
            collection: collection,
            query: query,
            order: .albumPage,
            filter: filter
        )
        let sorted = ExchangeShareSortHelper.sortedByAlbumOrder(items)
        let totalCopies = sorted.reduce(0) { $0 + $1.duplicateCount }

        return ExchangeSharePayload(
            totalCopies: totalCopies,
            stickers: sorted.map { item in
                ExchangeShareStickerEntry(
                    sticker: item.sticker,
                    team: catalog.team(for: item.sticker),
                    duplicateCount: item.duplicateCount
                )
            }
        )
    }
}
