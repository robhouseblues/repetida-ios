import SwiftData
import XCTest
@testable import Repetida

@MainActor
final class TradeRepositoryTests: XCTestCase {
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
        UserDefaults.standard.set(true, forKey: "envelopesRemovedV2")
        repository = SwiftDataCollectionRepository(
            modelContext: container.mainContext,
            catalog: catalog
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "duplicateCopiesMigrated")
        UserDefaults.standard.removeObject(forKey: "envelopesRemovedV2")
    }

    func testAdjustDuplicatesSyncsCount() {
        guard let sticker = catalog.allStickers.first else {
            XCTFail("Missing catalog stickers")
            return
        }

        repository.adjustDuplicates(by: 2, for: sticker.code)
        XCTAssertEqual(repository.status(for: sticker.code).duplicateCount, 2)

        repository.adjustDuplicates(by: -1, for: sticker.code)
        XCTAssertEqual(repository.status(for: sticker.code).duplicateCount, 1)
    }

    func testRecentActivitiesLogExplicitDuplicateRemoval() {
        guard let sticker = catalog.allStickers.first else {
            XCTFail("Missing catalog stickers")
            return
        }

        repository.adjustDuplicates(by: 1, for: sticker.code)
        repository.adjustDuplicates(by: -1, for: sticker.code)

        let activities = repository.recentActivities(limit: 10)
        XCTAssertTrue(activities.contains { $0.kind == .duplicateRemoved })
    }

    func testMigrationCreatesCopiesFromDuplicateCount() {
        UserDefaults.standard.set(false, forKey: "duplicateCopiesMigrated")
        UserDefaults.standard.set(false, forKey: "envelopesRemovedV2")
        guard let sticker = catalog.allStickers.first else {
            XCTFail("Missing catalog stickers")
            return
        }

        let entry = StickerEntry(code: sticker.code, isOwned: true, duplicateCount: 3)
        container.mainContext.insert(entry)
        try? container.mainContext.save()

        let migrated = SwiftDataCollectionRepository(
            modelContext: container.mainContext,
            catalog: catalog
        )
        XCTAssertEqual(migrated.status(for: sticker.code).duplicateCount, 3)
    }
}
