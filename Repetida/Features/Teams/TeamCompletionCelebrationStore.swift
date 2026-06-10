import Foundation

enum TeamCompletionCelebrationStore {
    private static let key = "teamCompletionCelebrationsShown"

    private static var shownTeamIds: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: key) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: key) }
    }

    static func shouldShow(for teamId: String) -> Bool {
        !shownTeamIds.contains(teamId)
    }

    static func markShown(for teamId: String) {
        var ids = shownTeamIds
        ids.insert(teamId)
        shownTeamIds = ids
    }

    static func clear(for teamId: String) {
        var ids = shownTeamIds
        ids.remove(teamId)
        shownTeamIds = ids
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    #endif
}
