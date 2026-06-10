import SwiftUI

struct DSActionCapsuleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.body(15))
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textPrimary)
                .textCase(.uppercase)
                .padding(.horizontal, DSSpacing.xl)
                .padding(.vertical, DSSpacing.md)
                .background(
                    Capsule(style: .continuous)
                        .fill(DSColors.primaryMuted.opacity(0.35))
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(DSColors.primaryChrome, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
