import SwiftUI

struct ExchangeFilterChipBar: View {
    let teamChips: [ExchangeTeamChip]
    @Binding var quickFilter: ExchangeQuickFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                filterChip(
                    title: L10n.exchangeFilterAll,
                    isSelected: quickFilter == .all
                ) {
                    quickFilter = .all
                    HapticFeedback.light()
                }

                filterChip(
                    title: L10n.exchangeFilterShiny,
                    isSelected: quickFilter == .shiny
                ) {
                    quickFilter = quickFilter == .shiny ? .all : .shiny
                    HapticFeedback.light()
                }

                filterChip(
                    title: L10n.exchangeFilterTwoOrMore,
                    isSelected: quickFilter == .twoOrMore
                ) {
                    quickFilter = quickFilter == .twoOrMore ? .all : .twoOrMore
                    HapticFeedback.light()
                }

                ForEach(teamChips) { chip in
                    filterChip(
                        title: chipLabel(for: chip),
                        isSelected: quickFilter == .team(chip.team.id)
                    ) {
                        if quickFilter == .team(chip.team.id) {
                            quickFilter = .all
                        } else {
                            quickFilter = .team(chip.team.id)
                        }
                        HapticFeedback.light()
                    }
                }
            }
            .padding(.horizontal, DSSpacing.lg)
        }
    }

    private func chipLabel(for chip: ExchangeTeamChip) -> String {
        if let flag = chip.team.flagEmoji {
            return "\(flag) \(L10n.exchangeFilterTeamChip(chip.team.code, chip.duplicateCount))"
        }
        return L10n.exchangeFilterTeamChip(chip.team.code, chip.duplicateCount)
    }

    private func filterChip(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.caption(11))
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? DSColors.textPrimary : DSColors.textMuted)
                .lineLimit(1)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? DSColors.goldFoil.opacity(0.24) : DSColors.surface.opacity(0.55))
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(
                                    isSelected ? DSColors.goldFoil.opacity(0.9) : DSColors.cardBorder,
                                    lineWidth: isSelected ? 1.5 : 1
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
