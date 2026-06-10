import SwiftData
import XCTest
@testable import Repetida

@MainActor
final class HomeCollectionInsightsTests: XCTestCase {
    private var container: ModelContainer!
    private var catalog: CatalogRepository!
    private var repository: SwiftDataCollectionRepository!

    override func setUp() async throws {
        let schema = Schema([
            StickerEntry.self,
            DuplicateCopy.self,
            TradeCollection.self,
            CollectionActivity.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        catalog = CatalogRepository()
        UserDefaults.standard.set(true, forKey: "duplicateCopiesMigrated")
        repository = SwiftDataCollectionRepository(
            modelContext: container.mainContext,
            catalog: catalog
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "duplicateCopiesMigrated")
    }

    func testClosestTeamsEmptyWhenAlbumComplete() {
        for sticker in catalog.allStickers {
            repository.setOwned(true, for: sticker.code)
        }

        let closest = HomeCollectionInsights.closestTeams(
            catalog: catalog,
            collection: repository
        )
        XCTAssertTrue(closest.isEmpty)
    }

    func testClosestTeamsOnlyIncludesTeamsWithAtMostFiveMissing() {
        guard let team = catalog.teams.first(where: { $0.section == .national }),
              let sticker = catalog.stickers(forTeamId: team.id).first else {
            XCTFail("Need a national team sticker")
            return
        }

        for teamSticker in catalog.stickers(forTeamId: team.id) {
            repository.setOwned(true, for: teamSticker.code)
        }
        repository.setOwned(false, for: sticker.code)

        let closest = HomeCollectionInsights.closestTeams(
            catalog: catalog,
            collection: repository
        )
        XCTAssertEqual(closest.count, 1)
        XCTAssertEqual(closest.first?.missing, 1)
    }
}
