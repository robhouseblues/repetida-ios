import XCTest
@testable import Repetida

final class ExchangeShareHelperTests: XCTestCase {
    private let catalog = CatalogRepository()

    private func entry(code: String, count: Int) -> ExchangeShareStickerEntry {
        let sticker = catalog.sticker(forCode: code)!
        return ExchangeShareStickerEntry(
            sticker: sticker,
            team: catalog.team(for: sticker),
            duplicateCount: count
        )
    }

    private func item(code: String, count: Int) -> ExchangeStickerItem {
        let sticker = catalog.sticker(forCode: code)!
        return ExchangeStickerItem(sticker: sticker, status: .duplicate(count: count))
    }

    func testSortedByAlbumOrderIgnoresQuantity() {
        let items = [
            item(code: "FWC14", count: 3),
            item(code: "00", count: 2),
            item(code: "FWC1", count: 1),
        ]

        let sorted = ExchangeShareSortHelper.sortedByAlbumOrder(items)
        XCTAssertEqual(sorted.map(\.sticker.code), ["00", "FWC1", "FWC14"])
    }

    func testDiverseSubsetSpreadsTeamsBeforeRepeating() {
        let entries = [
            entry(code: "FWC1", count: 1),
            entry(code: "FWC2", count: 1),
            entry(code: "USA1", count: 1),
            entry(code: "BRA1", count: 1),
            entry(code: "ARG1", count: 1),
        ]

        let visible = ExchangeShareSelectionHelper.diverseSubset(entries, limit: 4)
        let teamCodes = Set(visible.compactMap(\.team?.code))

        XCTAssertEqual(visible.count, 4)
        XCTAssertGreaterThanOrEqual(teamCodes.count, 3)
        XCTAssertEqual(
            visible.map(\.sticker.code),
            visible.sorted { NormalizedSticker.compareByAlbumOrder($0.sticker, $1.sticker) }.map(\.sticker.code)
        )
    }

    func testDiverseSubsetReturnsAllWhenUnderLimit() {
        let entries = [entry(code: "FWC1", count: 1), entry(code: "USA1", count: 1)]
        let visible = ExchangeShareSelectionHelper.diverseSubset(entries, limit: 10)
        XCTAssertEqual(visible.map(\.sticker.code), ["FWC1", "USA1"])
    }
}
