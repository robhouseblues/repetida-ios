import SwiftUI

struct DSTeamRow: View {
    let team: Team
    let progress: TeamProgress

    private enum Layout {
        static let progressBarWidth: CGFloat = 92
        static let verticalPadding = DSSpacing.md
    }

    private var isComplete: Bool {
        progress.owned == progress.total && progress.total > 0
    }

    var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    if let flagEmoji = team.flagEmoji {
                        Text(flagEmoji)
                            .font(DSTypography.body())
                    }

                    Text(team.name)
                        .font(DSTypography.body())
                        .foregroundStyle(DSColors.textPrimary)
                }

                HStack(spacing: DSSpacing.sm) {
                    Text(team.code)
                        .font(DSTypography.stickerCode(11))
                        .foregroundStyle(DSColors.goldFoil)

                    Text(team.albumPagesLabel)
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.textMuted)
                }
            }

            Spacer(minLength: DSSpacing.sm)

            progressBlock
        }
        .padding(.vertical, Layout.verticalPadding)
    }

    private var progressBlock: some View {
        VStack(alignment: .trailing, spacing: DSSpacing.xs) {
            if isComplete {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColors.goldFoil)
            }

            Text(L10n.teamProgressLabel(progress.owned, progress.total))
                .font(DSTypography.caption())
                .foregroundStyle(isComplete ? DSColors.textMuted : DSColors.textPrimary)
                .monospacedDigit()

            ProgressView(value: progress.fraction)
                .tint(isComplete ? DSColors.goldFoil : DSColors.primary)
                .frame(width: Layout.progressBarWidth)
        }
        .frame(width: Layout.progressBarWidth, alignment: .trailing)
    }
}
