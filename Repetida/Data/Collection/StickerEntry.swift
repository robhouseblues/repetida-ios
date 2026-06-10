import Foundation
import SwiftData

@Model
final class StickerEntry {
    @Attribute(.unique) var code: String
    var isOwned: Bool
    var duplicateCount: Int
    var updatedAt: Date

    init(code: String, isOwned: Bool = false, duplicateCount: Int = 0, updatedAt: Date = .now) {
        self.code = code
        self.isOwned = isOwned
        self.duplicateCount = duplicateCount
        self.updatedAt = updatedAt
    }
}
