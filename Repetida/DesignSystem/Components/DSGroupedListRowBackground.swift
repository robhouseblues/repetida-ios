import SwiftUI

enum DSGroupedRowPosition {
    case single
    case first
    case middle
    case last

    static func at(index: Int, count: Int) -> DSGroupedRowPosition {
        if count <= 1 { return .single }
        if index == 0 { return .first }
        if index == count - 1 { return .last }
        return .middle
    }
}

struct DSGroupedListRowBackground: View {
    let position: DSGroupedRowPosition

    var body: some View {
        switch position {
        case .single:
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(DSColors.cardSurface)
        case .first:
            UnevenRoundedRectangle(
                topLeadingRadius: DSRadius.sm,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: DSRadius.sm,
                style: .continuous
            )
            .fill(DSColors.cardSurface)
        case .middle:
            Rectangle()
                .fill(DSColors.cardSurface)
        case .last:
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: DSRadius.sm,
                bottomTrailingRadius: DSRadius.sm,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(DSColors.cardSurface)
        }
    }
}
