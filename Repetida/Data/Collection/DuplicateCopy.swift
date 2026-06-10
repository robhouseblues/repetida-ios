import Foundation
import SwiftData

@Model
final class DuplicateCopy {
    var id: UUID
    var stickerCode: String
    var collectionId: UUID?
    var sortIndex: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        stickerCode: String,
        collectionId: UUID? = nil,
        sortIndex: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.stickerCode = stickerCode
        self.collectionId = collectionId
        self.sortIndex = sortIndex
        self.createdAt = createdAt
    }
}
