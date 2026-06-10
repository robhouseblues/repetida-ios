import SwiftUI

struct DSTeamSectionHeader: View {
    let team: Team
    var showsBackground: Bool = true

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
            if let flagEmoji = team.flagEmoji {
                Text(flagEmoji)
                    .font(.system(size: 15))
            }

            Text(team.name)
                .font(DSTypography.body(15))
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textPrimary)
                .lineLimit(1)

            Text(team.code)
                .font(DSTypography.stickerCode(12))
                .foregroundStyle(DSColors.goldFoil)

            if !team.albumPagesLabel.isEmpty {
                Text("·")
                    .font(DSTypography.caption(11))
                    .foregroundStyle(DSColors.textMuted.opacity(0.45))

                Text(team.albumPagesLabel)
                    .font(DSTypography.caption(11))
                    .foregroundStyle(DSColors.textMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, showsBackground ? DSSpacing.md : 0)
        .padding(.vertical, showsBackground ? DSSpacing.sm : 0)
        .background {
            if showsBackground {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .fill(DSColors.surface.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                            .strokeBorder(DSColors.cardBorder, lineWidth: 1)
                    )
            }
        }
    }
}
