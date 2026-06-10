import SwiftUI

struct MissingTeamChipBar: View {
    let teamChips: [MissingTeamChip]
    @Binding var focusedTeamId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                teamChip(
                    title: L10n.missingFilterAll,
                    isSelected: focusedTeamId == nil
                ) {
                    focusedTeamId = nil
                    HapticFeedback.light()
                }

                ForEach(teamChips) { chip in
                    teamChip(
                        title: chipLabel(for: chip),
                        isSelected: focusedTeamId == chip.team.id
                    ) {
                        if focusedTeamId == chip.team.id {
                            focusedTeamId = nil
                        } else {
                            focusedTeamId = chip.team.id
                        }
                        HapticFeedback.light()
                    }
                }
            }
            .padding(.horizontal, DSSpacing.lg)
        }
    }

    private func chipLabel(for chip: MissingTeamChip) -> String {
        if let flag = chip.team.flagEmoji {
            return "\(flag) \(L10n.missingFilterTeamChip(chip.team.code, chip.missingCount))"
        }
        return L10n.missingFilterTeamChip(chip.team.code, chip.missingCount)
    }

    private func teamChip(
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
