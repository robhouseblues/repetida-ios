import Foundation

enum StickerStatus: Hashable {
    case missing
    case owned
    case duplicate(count: Int)
    case ownedWithDuplicates(count: Int)

    var isOwned: Bool {
        switch self {
        case .owned, .ownedWithDuplicates: return true
        default: return false
        }
    }

    var duplicateCount: Int {
        switch self {
        case .duplicate(let count), .ownedWithDuplicates(let count): return count
        default: return 0
        }
    }
}

struct TeamProgress: Hashable {
    let teamId: String
    let owned: Int
    let total: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(owned) / Double(total)
    }
}

struct AlbumProgress: Hashable {
    let owned: Int
    let total: Int
    let missing: Int
    let duplicateCount: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(owned) / Double(total)
    }
}

struct TeamsCompletionProgress: Hashable {
    let completed: Int
    let total: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}
