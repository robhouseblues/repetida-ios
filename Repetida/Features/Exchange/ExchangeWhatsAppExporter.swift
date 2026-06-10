import Foundation

enum ExchangeWhatsAppExporter {
    static func format(
        groups: [(team: Team, stickers: [ExchangeStickerItem])],
        totalCopies: Int
    ) -> String {
        var lines = [L10n.exchangeShareWhatsAppHeader, ""]
        for group in groups {
            guard !group.stickers.isEmpty else { continue }
            let flagPrefix = group.team.flagEmoji.map { "\($0) " } ?? ""
            lines.append("\(flagPrefix)\(group.team.code)")
            for item in group.stickers.sorted(by: { $0.sticker.code < $1.sticker.code }) {
                let quantity = item.duplicateCount > 1 ? " ×\(item.duplicateCount)" : ""
                lines.append("\(item.sticker.code) \(item.sticker.name)\(quantity)")
            }
            lines.append("")
        }
        lines.append(L10n.exchangeShareTotal(totalCopies))
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
