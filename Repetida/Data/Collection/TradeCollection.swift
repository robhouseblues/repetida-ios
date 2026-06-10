import Foundation
import SwiftData

@Model
final class TradeCollection {
    var id: UUID
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var note: String?

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int = 0,
        createdAt: Date = .now,
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.note = note
    }
}
