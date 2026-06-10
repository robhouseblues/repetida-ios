import Foundation

typealias MissingSortOrder = StickerGroupSortOrder

enum MissingSortHelper {
    static func groupedMissing(
        catalog: CatalogRepository,
        collection: CollectionRepository,
        query: String,
        order: MissingSortOrder
    ) -> [(team: Team, stickers: [NormalizedSticker])] {
        MissingFilterHelper.groupedMissing(
            catalog: catalog,
            collection: collection,
            query: query,
            order: order,
            focusedTeamId: nil
        )
    }
}
