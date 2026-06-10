import Foundation

enum ExchangeSortOrder: String, CaseIterable, Identifiable {
    case albumPage
    case teamCode
    case name
    case quantity

    var id: String { rawValue }

    init(resolving raw: String) {
        switch raw {
        case "team", "albumPage":
            self = .albumPage
        case "teamCode":
            self = .teamCode
        case "name", "code":
            self = .name
        case "quantity":
            self = .quantity
        default:
            self = ExchangeSortOrder(rawValue: raw) ?? .albumPage
        }
    }
}

struct ExchangeStickerItem: Identifiable, Hashable {
    let sticker: NormalizedSticker
    let status: StickerStatus

    var id: String { sticker.code }

    var duplicateCount: Int { status.duplicateCount }
}

enum ExchangeSortHelper {
    static func groupedByTeam(
        _ items: [ExchangeStickerItem],
        catalog: CatalogRepository,
        order: ExchangeSortOrder
    ) -> [(team: Team, stickers: [ExchangeStickerItem])] {
        var byTeam: [String: [ExchangeStickerItem]] = [:]
        for item in items {
            guard let team = catalog.team(for: item.sticker) else { continue }
            byTeam[team.id, default: []].append(item)
        }

        var groups = catalog.teams.compactMap { team -> (team: Team, stickers: [ExchangeStickerItem])? in
            guard let stickers = byTeam[team.id], !stickers.isEmpty else { return nil }
            return (team, stickersInAlbumOrder(stickers))
        }

        groups.sort { compareGroups($0, $1, order: order) }
        return groups
    }

    private static func stickersInAlbumOrder(_ items: [ExchangeStickerItem]) -> [ExchangeStickerItem] {
        items.sorted { NormalizedSticker.compareByAlbumOrder($0.sticker, $1.sticker) }
    }

    private static func compareGroups(
        _ lhs: (team: Team, stickers: [ExchangeStickerItem]),
        _ rhs: (team: Team, stickers: [ExchangeStickerItem]),
        order: ExchangeSortOrder
    ) -> Bool {
        switch order {
        case .albumPage:
            return StickerGroupSortHelper.compareTeams(lhs.team, rhs.team, order: .albumPage)
        case .teamCode:
            return StickerGroupSortHelper.compareTeams(lhs.team, rhs.team, order: .teamCode)
        case .name:
            return StickerGroupSortHelper.compareTeams(lhs.team, rhs.team, order: .name)
        case .quantity:
            let leftTotal = lhs.stickers.reduce(0) { $0 + $1.duplicateCount }
            let rightTotal = rhs.stickers.reduce(0) { $0 + $1.duplicateCount }
            if leftTotal != rightTotal { return leftTotal > rightTotal }
            return StickerGroupSortHelper.compareTeams(lhs.team, rhs.team, order: .albumPage)
        }
    }
}
