import SwiftUI

struct StickerResultRow: View {
    let sticker: NormalizedSticker
    let team: Team
    let status: StickerStatus
    var isCompact: Bool = false
    var isInteractive: Bool = true
    var updateLabel: String?
    var updateLabelColor: Color = DSColors.textMuted
    var onTap: () -> Void = {}
    var onAddDuplicate: () -> Void = {}

    var body: some View {
        Group {
            if isInteractive {
                Button(action: onTap) {
                    rowContent
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button {
                        onAddDuplicate()
                    } label: {
                        Label(L10n.addDuplicateShort, systemImage: "plus.circle")
                    }
                    .tint(DSColors.duplicate)
                }
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: isCompact ? DSSpacing.sm : DSSpacing.md) {
            VStack(alignment: .leading, spacing: isCompact ? 2 : DSSpacing.xs) {
                if isCompact {
                    HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xs) {
                        Text(sticker.code)
                            .font(DSTypography.stickerCode(12))
                            .foregroundStyle(sticker.isShiny ? DSColors.goldShimmer : DSColors.textPrimary)
                        
                        Text("·")
                            .font(DSTypography.body(13))
                            .foregroundStyle(DSColors.textPrimary)

                        Text(sticker.name)
                            .font(DSTypography.body(13))
                            .foregroundStyle(DSColors.textPrimary)
                            .lineLimit(1)

                        if sticker.isShiny {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundStyle(DSColors.goldFoil)
                        }
                    }
                } else {
                    HStack {
                        Text(sticker.code)
                            .font(DSTypography.stickerCode())
                            .foregroundStyle(sticker.isShiny ? DSColors.goldShimmer : DSColors.textPrimary)

                        if sticker.isShiny {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundStyle(DSColors.goldFoil)
                        }
                    }

                    Text(sticker.name)
                        .font(DSTypography.body(14))
                        .foregroundStyle(DSColors.textPrimary)
                        .lineLimit(1)
                }

                if let updateLabel {
                    Text(updateLabel)
                        .font(DSTypography.caption(11))
                        .foregroundStyle(updateLabelColor)
                }

                if !isCompact {
                    Text(team.albumPagesLabel.isEmpty ? team.name : "\(team.name) · \(team.albumPagesLabel)")
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.textMuted)
                }
            }

            Spacer()

            DSStickerStatusBadge(status: status)
        }
        .padding(isCompact ? DSSpacing.sm : DSSpacing.md)
        .atmosphericCardSurface(
            cornerRadius: isCompact ? DSRadius.sm : DSRadius.md,
            showScanlines: false,
            showsShadow: false
        )
    }
}
