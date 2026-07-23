import Foundation

@Observable
final class ExchangeViewModel {
    var sortOrder: ExchangeSortOrder = .albumPage

    private(set) var allItems: [ExchangeStickerItem] = []
    private(set) var groups: [(team: Team, stickers: [ExchangeStickerItem])] = []
    private(set) var teamChips: [ExchangeTeamChip] = []
    private(set) var insightText = ""

    private var isLoaded = false
    private var lastChangeToken = -1
    private var lastQuery = ""
    private var lastFilter: ExchangeQuickFilter = .all
    private var lastSortOrder: ExchangeSortOrder = .albumPage

    func refresh(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        filter: ExchangeQuickFilter
    ) {
        let changeToken = collection.changeToken
        guard !isLoaded
            || changeToken != lastChangeToken
            || query != lastQuery
            || filter != lastFilter
            || sortOrder != lastSortOrder
        else { return }

        isLoaded = true
        lastChangeToken = changeToken
        lastQuery = query
        lastFilter = filter
        lastSortOrder = sortOrder

        allItems = ExchangeFilterHelper.allDuplicateItems(catalog: catalog, collection: collection)

        let totalCopies = allItems.reduce(0) { $0 + $1.duplicateCount }
        let shiny = allItems.filter(\.sticker.isShiny).reduce(0) { $0 + $1.duplicateCount }
        insightText = L10n.exchangeInsight(totalCopies, allItems.count, shiny)

        let chipItems = ExchangeFilterHelper.filtered(
            allItems,
            catalog: catalog,
            query: query,
            filter: .all
        )
        teamChips = ExchangeSortHelper.groupedByTeam(chipItems, catalog: catalog, order: sortOrder)
            .map { group in
                let copies = group.stickers.reduce(0) { $0 + $1.duplicateCount }
                return ExchangeTeamChip(team: group.team, duplicateCount: copies)
            }

        let filtered = ExchangeFilterHelper.filtered(
            allItems,
            catalog: catalog,
            query: query,
            filter: filter
        )
        groups = ExchangeSortHelper.groupedByTeam(filtered, catalog: catalog, order: sortOrder)
    }

    func whatsAppText(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        filter: ExchangeQuickFilter
    ) -> String {
        refresh(catalog: catalog, collection: collection, query: query, filter: filter)
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
