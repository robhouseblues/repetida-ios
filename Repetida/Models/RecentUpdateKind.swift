import Foundation

enum RecentUpdateKind: String, CaseIterable {
    case markedOwned
    case markedMissing
    case duplicateAdded
    case duplicateRemoved
}

struct RecentActivity: Identifiable, Hashable {
    let id: UUID
    let stickerCode: String
    let kind: RecentUpdateKind
    let date: Date
}
