import SwiftUI

struct ExchangeDragHint: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "hand.draw")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DSColors.primary.opacity(0.85))

            Text(L10n.exchangeDragHint)
                .font(DSTypography.caption())
                .foregroundStyle(DSColors.textMuted)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.textMuted)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.teamPagerDismissHint)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous)
                .fill(DSColors.surface.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous)
                        .strokeBorder(DSColors.primaryChrome.opacity(0.28), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
    }
}
