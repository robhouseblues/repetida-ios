import XCTest
@testable import Repetida

final class ExchangeSortHelperTests: XCTestCase {
    private let catalog = CatalogRepository()

    private func item(code: String, count: Int) -> ExchangeStickerItem {
        let sticker = catalog.sticker(forCode: code)!
        return ExchangeStickerItem(
            sticker: sticker,
            status: .duplicate(count: count)
        )
    }

    func testGroupByTeamCodeOrdersSections() {
        let items = [item(code: "USA1", count: 1), item(code: "BRA1", count: 1)]
        let groups = ExchangeSortHelper.groupedByTeam(items, catalog: catalog, order: .teamCode)
        guard groups.count >= 2 else { return }
        let codes = groups.map(\.team.code)
        XCTAssertEqual(codes, codes.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        })
    }

    func testStickersWithinSectionAlwaysFollowAlbumOrder() {
        guard let alg7 = catalog.sticker(forCode: "ALG7"),
              let alg11 = catalog.sticker(forCode: "ALG11") else {
            XCTFail("Expected ALG stickers in catalog")
            return
        }
        let items = [
            ExchangeStickerItem(sticker: alg11, status: .duplicate(count: 5)),
            ExchangeStickerItem(sticker: alg7, status: .duplicate(count: 1)),
        ]
        for order in [ExchangeSortOrder.albumPage, .teamCode, .name, .quantity] {
            let groups = ExchangeSortHelper.groupedByTeam(items, catalog: catalog, order: order)
            guard let algGroup = groups.first(where: { $0.team.code == "ALG" }) else {
                XCTFail("Expected ALG group for order \(order)")
                continue
            }
            XCTAssertEqual(
                algGroup.stickers.map(\.sticker.code),
                ["ALG7", "ALG11"],
                "Stickers should stay in album order for \(order)"
            )
        }
    }

    func testSortByQuantityOrdersSectionsByTotalCopies() {
        let braLow = item(code: "BRA2", count: 1)
        let braHigh = item(code: "BRA1", count: 3)
        let usa = item(code: "USA1", count: 2)
        let groups = ExchangeSortHelper.groupedByTeam(
            [braLow, braHigh, usa],
            catalog: catalog,
            order: .quantity
        )
        guard groups.count >= 2 else { return }
        let totals = groups.map { $0.stickers.reduce(0) { $0 + $1.duplicateCount } }
        XCTAssertEqual(totals, totals.sorted(by: >))
        XCTAssertEqual(groups.first?.team.code, "BRA")
        XCTAssertEqual(groups.first?.stickers.map(\.sticker.code), ["BRA1", "BRA2"])
    }
}
