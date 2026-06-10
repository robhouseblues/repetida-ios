import SwiftUI

struct DSStickerTile: View {
    let sticker: NormalizedSticker
    let status: StickerStatus
    var onTap: () -> Void
    var onAddDuplicate: () -> Void
    var onRemoveDuplicate: (() -> Void)?
    var onLongPress: (() -> Void)?
    var isInteractionDisabled: Bool = false
    var showsDuplicateCount: Bool = true
    var allowsRemoveDuplicate: Bool = false
    var showsToggleOwned: Bool = true
    var isTapEnabled: Bool = true
    var showsContextMenu: Bool = true
    var draggableCopyId: UUID?
    var showsQuickAdd: Bool = false
    var showsQuickRemove: Bool = false
    var isSelected: Bool = false
    var showsSelectionIndicator: Bool = false
    var isDragPreview: Bool = false

    @State private var suppressNextTap = false

    var body: some View {
        if isDragPreview {
            tileContent
                .allowsHitTesting(false)
        } else if draggableCopyId != nil {
            tileContent
                .contentShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                .onTapGesture {
                    guard !isInteractionDisabled else { return }
                    onTap()
                }
                .allowsHitTesting(!isInteractionDisabled)
                .modifier(OptionalStickerContextMenu(enabled: showsContextMenu) { contextMenuContent })
        } else if isTapEnabled {
            tileButton
        } else {
            tileContent
                .allowsHitTesting(!isInteractionDisabled)
        }
    }

    private var tileButton: some View {
        Button(action: {
            guard !isInteractionDisabled else { return }
            guard !suppressNextTap else {
                suppressNextTap = false
                return
            }
            onTap()
        }) {
            tileContent
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isInteractionDisabled)
        .modifier(LongPressDuplicateGesture(
            onLongPress: isInteractionDisabled ? nil : onLongPress,
            suppressNextTap: $suppressNextTap
        ))
        .modifier(OptionalStickerContextMenu(enabled: showsContextMenu) { contextMenuContent })
    }

    private var tileContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(sticker.code)
                    .font(DSTypography.stickerCode(11))
                    .foregroundStyle(codeTextColor)
                Spacer(minLength: 0)
                if sticker.isShiny {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundStyle(shinyAccentColor)
                }
            }

            Text(sticker.name)
                .font(DSTypography.caption(10))
                .foregroundStyle(nameTextColor)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            DSStickerStatusBadge(status: status, showsDuplicateCount: showsDuplicateCount)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(contentOpacity)
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 88, maxHeight: .infinity, alignment: .topLeading)
        .atmosphericCardSurface(
            cornerRadius: DSRadius.sm,
            tint: statusTint,
            strokeColor: borderColor,
            strokeLineWidth: borderLineWidth,
            strokeDash: borderDash,
            showScanlines: !isMissing,
            showsShadow: isAlive,
            glowColor: ownedGlowColor,
            dimOverlay: missingDimOverlay,
            innerGlowColor: ownedInnerGlow
        )
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        .overlay {
            if showsSelectionIndicator && isSelected {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .strokeBorder(DSColors.primary, lineWidth: 2.5)
            }
        }
        .overlay(alignment: .topLeading) {
            if showsSelectionIndicator {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? DSColors.primary : DSColors.textMuted.opacity(0.6))
                    .padding(6)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showsQuickAdd, !showsSelectionIndicator {
                Button(action: onAddDuplicate) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DSColors.primary)
                        .padding(4)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if showsQuickRemove,
               status.duplicateCount > 0,
               let onRemoveDuplicate,
               !showsSelectionIndicator {
                Button(action: onRemoveDuplicate) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.red.opacity(0.92))
                        .padding(4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.removeDuplicateShort)
            }
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        if !isInteractionDisabled {
            if showsToggleOwned {
                Button(L10n.toggleOwned) { onTap() }
            }
            Button(L10n.addDuplicate) { onAddDuplicate() }
            if let onRemoveDuplicate, status.duplicateCount > 0 || allowsRemoveDuplicate {
                Button(L10n.removeDuplicate, role: .destructive, action: onRemoveDuplicate)
            }
        }
    }

    private var isMissing: Bool {
        !status.isOwned && status.duplicateCount == 0
    }

    private var isAlive: Bool {
        !isMissing
    }

    private var contentOpacity: Double {
        isMissing ? 0.92 : 1.0
    }

    private var codeTextColor: Color {
        if isMissing {
            return sticker.isShiny ? DSColors.goldShimmer.opacity(0.9) : DSColors.textPrimary
        }
        return sticker.isShiny ? DSColors.goldShimmer : DSColors.textPrimary
    }

    private var nameTextColor: Color {
        isMissing ? DSColors.textMuted.opacity(0.85) : DSColors.textMuted
    }

    private var shinyAccentColor: Color {
        isMissing ? DSColors.goldFoil.opacity(0.55) : DSColors.goldFoil
    }

    private var statusTint: Color? {
        if status.isOwned {
            return DSColors.primaryMuted.opacity(0.12)
        }
        if status.duplicateCount > 0 {
            return DSColors.duplicate.opacity(0.12)
        }
        return nil
    }

    private var borderColor: Color {
        if status.isOwned {
            return DSColors.primaryChrome.opacity(0.62)
        }
        if status.duplicateCount > 0 {
            return DSColors.duplicate.opacity(0.65)
        }
        if isMissing {
            return sticker.isShiny
                ? DSColors.goldFoil.opacity(0.38)
                : DSColors.primaryChrome.opacity(0.42)
        }
        if sticker.isShiny {
            return DSColors.goldFoil.opacity(0.22)
        }
        return DSColors.textMuted.opacity(0.22)
    }

    private var borderLineWidth: CGFloat {
        if status.isOwned { return 1.5 }
        if isMissing { return 1.1 }
        return 1
    }

    private var borderDash: [CGFloat] {
        isMissing ? [4, 3] : []
    }

    private var missingDimOverlay: Color? {
        isMissing ? Color.black.opacity(0.22) : nil
    }

    private var ownedGlowColor: Color? {
        status.isOwned ? DSColors.primaryDeep.opacity(0.16) : nil
    }

    private var ownedInnerGlow: Color? {
        nil
    }
}

private struct OptionalStickerContextMenu<MenuContent: View>: ViewModifier {
    let enabled: Bool
    @ViewBuilder let content: () -> MenuContent

    func body(content view: Content) -> some View {
        if enabled {
            view.contextMenu { self.content() }
        } else {
            view
        }
    }
}

private struct LongPressDuplicateGesture: ViewModifier {
    let onLongPress: (() -> Void)?
    @Binding var suppressNextTap: Bool

    func body(content: Content) -> some View {
        if let onLongPress {
            content.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in
                        suppressNextTap = true
                        onLongPress()
                    }
            )
        } else {
            content
        }
    }
}
