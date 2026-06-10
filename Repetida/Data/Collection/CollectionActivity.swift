import Foundation
import SwiftData

@Model
final class CollectionActivity {
    var id: UUID
    var stickerCode: String
    var kind: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        stickerCode: String,
        kind: RecentUpdateKind,
        createdAt: Date = .now
    ) {
        self.id = id
        self.stickerCode = stickerCode
        self.kind = kind.rawValue
        self.createdAt = createdAt
    }

    var updateKind: RecentUpdateKind {
        RecentUpdateKind(rawValue: kind) ?? .markedOwned
    }
}
