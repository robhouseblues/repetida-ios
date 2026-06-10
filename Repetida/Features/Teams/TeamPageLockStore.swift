import Foundation

enum TeamPageLockStore {
    static let storageKey = "lockedTeamPageIds"

    static func lockedIds(in raw: String) -> Set<String> {
        Set(raw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    static func serialize(_ ids: Set<String>) -> String {
        ids.sorted().joined(separator: ",")
    }

    static func isLocked(teamId: String, in raw: String) -> Bool {
        lockedIds(in: raw).contains(teamId)
    }

    static func lock(teamId: String, in raw: String) -> String {
        var ids = lockedIds(in: raw)
        ids.insert(teamId)
        let result = serialize(ids)
        UserDefaults.standard.set(result, forKey: storageKey)
        return result
    }

    static func unlock(teamId: String, in raw: String) -> String {
        var ids = lockedIds(in: raw)
        ids.remove(teamId)
        let result = serialize(ids)
        UserDefaults.standard.set(result, forKey: storageKey)
        return result
    }

    static func toggle(teamId: String, in raw: String) -> String {
        if isLocked(teamId: teamId, in: raw) {
            return unlock(teamId: teamId, in: raw)
        }
        return lock(teamId: teamId, in: raw)
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    #endif
}
