import SwiftUI

struct DSTeamPagerNeighborHint: View {
    enum Edge {
        case leading
        case trailing
    }

    let team: Team
    let edge: Edge
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if edge == .leading {
                    chevron("chevron.left")
                }

                Text(team.name)
                    .font(DSTypography.caption(10))
                    .foregroundStyle(DSColors.textMuted.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if edge == .trailing {
                    chevron("chevron.right")
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .frame(minHeight: 28)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func chevron(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(DSColors.primaryChrome.opacity(0.75))
    }

    private var accessibilityLabel: String {
        switch edge {
        case .leading:
            L10n.teamPagerPrevious(teamName: team.name, teamCode: team.code)
        case .trailing:
            L10n.teamPagerNext(teamName: team.name, teamCode: team.code)
        }
    }
}
