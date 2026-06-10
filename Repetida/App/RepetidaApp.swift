import SwiftUI

@main
struct RepetidaApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

private struct CollectionRepositoryKey: EnvironmentKey {
    static let defaultValue: CollectionRepository? = nil
}

extension EnvironmentValues {
    var collectionRepository: CollectionRepository? {
        get { self[CollectionRepositoryKey.self] }
        set { self[CollectionRepositoryKey.self] = newValue }
    }
}
