import SwiftUI

struct DSSearchField: View {
    @Binding var text: String
    var placeholder: String = L10n.searchPlaceholder
    var showsClearButton: Bool = true

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColors.primary)

            TextField(placeholder, text: $text)
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if showsClearButton, !text.isEmpty {
                Button {
                    text = ""
                    HapticFeedback.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColors.textMuted)
                }
                .accessibilityLabel(L10n.clearSearch)
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(DSColors.pitchDeep.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(
                            text.isEmpty ? DSColors.cardBorder : DSColors.primaryChrome.opacity(0.45),
                            lineWidth: 1.5
                        )
                )
        )
    }
}
