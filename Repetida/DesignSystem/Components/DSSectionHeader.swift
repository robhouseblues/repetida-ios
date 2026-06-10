import SwiftUI

struct DSSectionHeader: View {
    let title: String
    var compact: Bool = false

    var body: some View {
        Text(title.uppercased())
            .font(compact ? DSTypography.caption(10) : DSTypography.caption())
            .foregroundStyle(DSColors.primary.opacity(compact ? 0.9 : 1))
            .tracking(compact ? 0.8 : 1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, compact ? DSSpacing.xs : DSSpacing.sm)
            .padding(.bottom, compact ? DSSpacing.sm : 0)
    }
}
