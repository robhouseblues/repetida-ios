import SwiftUI

struct DSTeamCompletionBanner: View {
    let owned: Int
    let total: Int
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(DSColors.goldFoil)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(L10n.teamCelebrationTitle)
                    .font(DSTypography.body())
                    .foregroundStyle(DSColors.textPrimary)

                Text(L10n.teamCelebrationProgress(owned, total))
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColors.textMuted)
                    .monospacedDigit()
            }

            Spacer(minLength: DSSpacing.sm)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DSColors.textMuted)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(DSColors.background.opacity(0.65))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.teamCelebrationDismiss)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .fill(DSColors.surface.opacity(0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                        .strokeBorder(DSColors.goldFoil.opacity(0.45), lineWidth: 1.5)
                )
        )
        .shadow(color: DSColors.goldFoil.opacity(0.18), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
    }
}
