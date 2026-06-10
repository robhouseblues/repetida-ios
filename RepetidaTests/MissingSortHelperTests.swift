import SwiftData
import XCTest
@testable import Repetida

@MainActor
final class MissingSortHelperTests: XCTestCase {
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

    func testSortByTeamName() {
        let groups = MissingSortHelper.groupedMissing(
            catalog: catalog,
            collection: repository,
            query: "",
            order: .name
        )
        guard groups.count >= 2 else { return }
        let names = groups.map(\.team.name)
        XCTAssertEqual(names, names.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        })
    }

    func testSortByTeamCode() {
        let groups = MissingSortHelper.groupedMissing(
            catalog: catalog,
            collection: repository,
            query: "",
            order: .teamCode
        )
        guard groups.count >= 2 else { return }
        let codes = groups.map(\.team.code)
        XCTAssertEqual(codes, codes.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        })
    }

    func testFocusedTeamFilter() {
        guard let team = catalog.teams.first else {
            XCTFail("Need a team")
            return
        }
        for sticker in catalog.stickers(forTeamId: team.id) {
            repository.setOwned(false, for: sticker.code)
        }

        let groups = MissingFilterHelper.groupedMissing(
            catalog: catalog,
            collection: repository,
            query: "",
            order: .teamCode,
            focusedTeamId: team.id
        )
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.team.id, team.id)
    }

    func testStickersSortByAlbumOrderNotLexicographic() {
        guard let alg7 = catalog.sticker(forCode: "ALG7"),
              let alg11 = catalog.sticker(forCode: "ALG11") else {
            XCTFail("Expected ALG stickers in catalog")
            return
        }
        let sorted = StickerGroupSortHelper.sortStickersByAlbumOrder([alg11, alg7])
        XCTAssertEqual(sorted.map(\.code), ["ALG7", "ALG11"])
    }

}
