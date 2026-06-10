import SwiftUI

struct DSToolbarIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var foregroundColor: Color = DSColors.textMuted
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
