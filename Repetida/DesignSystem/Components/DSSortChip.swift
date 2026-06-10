import SwiftUI

struct DSSortChip<MenuContent: View>: View {
    let title: String
    var accessibilityLabel: String
    @ViewBuilder var menuContent: () -> MenuContent

    init(
        title: String,
        accessibilityLabel: String? = nil,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel ?? title
        self.menuContent = menuContent
    }

    var body: some View {
        Menu {
            menuContent()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 10, weight: .semibold))
                Text(title)
                    .font(DSTypography.caption(11))
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundStyle(DSColors.textMuted)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                Capsule(style: .continuous)
                    .fill(DSColors.surface.opacity(0.55))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(DSColors.cardBorder, lineWidth: 1)
                    )
            )
        }
        .compositingGroup()
        .accessibilityLabel(accessibilityLabel)
    }
}
