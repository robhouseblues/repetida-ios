import Foundation
import SwiftData

enum ModelContainerFactory {
    private static let storeFileName = "Repetida.store"

    static var persistentStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: storeFileName)
    }

    static func make() throws -> ModelContainer {
        let schema = Schema([
            StickerEntry.self,
            DuplicateCopy.self,
            TradeCollection.self,
            CollectionActivity.self,
        ])

        let persistentConfig = ModelConfiguration(
            url: persistentStoreURL,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            #if DEBUG
            print("[SwiftData] Persistent store failed: \(error.localizedDescription)")
            #endif
        }

        deleteAllStoreFiles()

        do {
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            #if DEBUG
            print("[SwiftData] Persistent store failed after reset: \(error.localizedDescription)")
            #endif
        }

        #if DEBUG
        print("[SwiftData] Falling back to in-memory store.")
        #endif

        let memoryConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [memoryConfig])
    }

    static func deleteAllStoreFiles() {
        let fileManager = FileManager.default
        let basePath = persistentStoreURL.path
        let candidates = [
            persistentStoreURL,
            URL(fileURLWithPath: basePath + "-wal"),
            URL(fileURLWithPath: basePath + "-shm"),
        ]

        for candidate in candidates where fileManager.fileExists(atPath: candidate.path) {
            try? fileManager.removeItem(at: candidate)
        }

        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let legacyNames = ["default.store", "default.store-wal", "default.store-shm"]
            for name in legacyNames {
                let url = appSupport.appending(path: name)
                if fileManager.fileExists(atPath: url.path) {
                    try? fileManager.removeItem(at: url)
                }
            }
        }
    }
}
