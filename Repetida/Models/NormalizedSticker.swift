import Foundation

struct NormalizedSticker: Identifiable, Hashable {
    let code: String
    let name: String
    let teamId: String
    let kind: StickerKind
    let isShiny: Bool
    let sortIndex: Int

    var id: String { code }

    static func compareByAlbumOrder(_ lhs: NormalizedSticker, _ rhs: NormalizedSticker) -> Bool {
        if lhs.sortIndex != rhs.sortIndex { return lhs.sortIndex < rhs.sortIndex }
        return lhs.code.localizedCaseInsensitiveCompare(rhs.code) == .orderedAscending
    }
}

struct CatalogEntry: Codable {
    let code: String
    let name: String
    let team: String
}

struct RawCatalog: Codable {
    let stickers: [CatalogEntry]
}
