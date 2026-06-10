import SwiftUI

struct DSStickerStatusBadge: View {
    let status: StickerStatus
    var showsDuplicateCount: Bool = true

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            if showsDuplicateCount, status.duplicateCount > 0 {
                Text("+\(status.duplicateCount)")
                    .font(DSTypography.caption(11))
                    .foregroundStyle(DSColors.duplicate)
            }

            statusIcon
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var statusIcon: some View {
        if status.isOwned {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DSColors.owned)
        } else if case .missing = status {
            Image(systemName: "square.dashed")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DSColors.textMuted.opacity(0.75))
        } else {
            Image(systemName: "xmark.circle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DSColors.textMuted)
        }
    }

    private var accessibilityLabel: String {
        switch status {
        case .missing: return L10n.statusMissing
        case .owned: return L10n.statusOwned
        case .duplicate(let count): return L10n.statusDuplicate(count)
        case .ownedWithDuplicates(let count): return L10n.statusOwnedWithDuplicates(count)
        }
    }
}
