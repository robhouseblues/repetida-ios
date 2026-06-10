import SwiftUI

struct TeamPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let teams: [Team]
    let currentTeamId: String
    let onSelect: (Team) -> Void

    private static let cellHeight: CGFloat = 52

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DSSpacing.sm),
        count: 4
    )

    private var sortedTeams: [Team] {
        Team.sorted(teams, by: .albumPage)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                    ForEach(sortedTeams) { team in
                        teamCell(team)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.lg)
            }
        }
        .background(DSColors.screenBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DSColors.screenBackground)
    }

    private var header: some View {
        Text(L10n.teamPickerTitle.uppercased())
            .font(DSTypography.display(18))
            .fontWeight(.semibold)
            .foregroundStyle(DSColors.textPrimary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DSSpacing.lg)
            .padding(.top, DSSpacing.xxl)
            .padding(.bottom, DSSpacing.xl)
    }

    private func teamCell(_ team: Team) -> some View {
        let isSelected = team.id == currentTeamId

        return Button {
            onSelect(team)
            dismiss()
            HapticFeedback.light()
        } label: {
            VStack(spacing: 3) {
                Group {
                    if let flagEmoji = team.flagEmoji {
                        Text(flagEmoji)
                            .font(.system(size: 17))
                    }
                }
                .frame(height: 20)

                Text(team.code)
                    .font(DSTypography.stickerCode(10))
                    .foregroundStyle(isSelected ? DSColors.goldFoil : DSColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Self.cellHeight)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .fill(isSelected ? DSColors.goldFoil.opacity(0.12) : DSColors.surface.opacity(0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                            .strokeBorder(
                                isSelected ? DSColors.goldFoil.opacity(0.7) : DSColors.cardBorder.opacity(0.35),
                                lineWidth: isSelected ? 1.5 : 0.75
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(team.name)
    }
}
