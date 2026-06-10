import SwiftUI

struct DSScreenHeader<Trailing: View>: View {
    enum Style {
        case inline
        case pinned
    }

    let title: String
    @Binding var searchText: String
    var searchPlaceholder: String
    var subtitle: String?
    var showsSearch: Bool
    var titleFontSize: CGFloat
    var style: Style
    @ViewBuilder var trailing: () -> Trailing

    init(
        title: String,
        searchText: Binding<String>,
        searchPlaceholder: String = L10n.searchPlaceholder,
        subtitle: String? = nil,
        showsSearch: Bool = true,
        titleFontSize: CGFloat = 22,
        style: Style = .inline,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self._searchText = searchText
        self.searchPlaceholder = searchPlaceholder
        self.subtitle = subtitle
        self.showsSearch = showsSearch
        self.titleFontSize = titleFontSize
        self.style = style
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(alignment: .bottom, spacing: DSSpacing.sm) {
                Text(title)
                    .font(DSTypography.display(titleFontSize))
                    .foregroundStyle(DSColors.textPrimary)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                trailing()
                    .fixedSize(horizontal: true, vertical: false)
            }

            if showsSearch {
                DSSearchField(text: $searchText, placeholder: searchPlaceholder)
            }

            if let subtitle {
                Text(subtitle)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColors.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.md)
        .padding(.bottom, style == .pinned ? DSSpacing.sm : 0)
        .background {
            if style == .pinned {
                DSColors.screenBackground.opacity(0.95)
            }
        }
    }
}

extension DSScreenHeader where Trailing == EmptyView {
    init(
        title: String,
        searchText: Binding<String>,
        searchPlaceholder: String = L10n.searchPlaceholder,
        subtitle: String? = nil,
        showsSearch: Bool = true,
        titleFontSize: CGFloat = 22,
        style: Style = .inline
    ) {
        self.init(
            title: title,
            searchText: searchText,
            searchPlaceholder: searchPlaceholder,
            subtitle: subtitle,
            showsSearch: showsSearch,
            titleFontSize: titleFontSize,
            style: style,
            trailing: { EmptyView() }
        )
    }
}
