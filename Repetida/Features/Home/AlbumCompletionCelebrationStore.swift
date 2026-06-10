import Foundation

extension Notification.Name {
    static let albumDidComplete = Notification.Name("repetida.albumDidComplete")
}

enum AlbumCompletionCelebrationStore {
    private static let key = "albumCompletionCelebrationShown"

    static var shouldShow: Bool {
        !UserDefaults.standard.bool(forKey: key)
    }

    static func markShown() {
        UserDefaults.standard.set(true, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    #if DEBUG
    static func reset() {
        clear()
    }
    #endif
}
