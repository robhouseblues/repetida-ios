import SwiftUI

struct ExchangeAddCopyView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @State private var query = ""
    @AppStorage("exchangeAddCopySortOrder") private var sortOrderRaw = StickerGroupSortOrder.albumPage.rawValue

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)
    private let recentStickerLimit = 12

    private var sortOrder: StickerGroupSortOrder {
        StickerGroupSortOrder(resolving: sortOrderRaw)
    }

    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var groupedStickers: [(team: Team, stickers: [NormalizedSticker])] {
        StickerGroupSortHelper.groupedCatalogStickers(
            catalog: catalog,
            query: query,
            order: sortOrder
        )
    }

    private var recentlyAddedStickers: [NormalizedSticker] {
        guard let collection else { return [] }

        var seen = Set<String>()
        var stickers: [NormalizedSticker] = []

        for activity in collection.recentActivities(limit: 40) {
            guard activity.kind == .duplicateAdded else { continue }
            guard seen.insert(activity.stickerCode).inserted else { continue }
            guard let sticker = catalog.sticker(forCode: activity.stickerCode) else { continue }
            stickers.append(sticker)
            if stickers.count >= recentStickerLimit { break }
        }

        return stickers
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: DSSpacing.md) {
                DSScreenHeader(
                    title: L10n.exchangeAddCopy,
                    searchText: $query,
                    searchPlaceholder: L10n.exchangeAddCopySearchPlaceholder
                ) {
                    sortChip
                }

                if groupedStickers.isEmpty {
                    Text(L10n.noStickersFound)
                        .font(DSTypography.body())
                        .foregroundStyle(DSColors.textMuted)
                        .frame(maxHeight: .infinity)
                } else {
                    stickerGrid
                }
            }
        }
        .pushedNavigationChrome()
    }

    private var sortChip: some View {
        DSSortChip(title: L10n.sortLabel(for: sortOrder), accessibilityLabel: L10n.exchangeAddCopySort) {
            ForEach(StickerGroupSortOrder.allCases) { order in
                Button {
                    sortOrderRaw = order.rawValue
                    HapticFeedback.light()
                } label: {
                    if sortOrder == order {
                        Label(L10n.sortLabel(for: order), systemImage: "checkmark")
                    } else {
                        Text(L10n.sortLabel(for: order))
                    }
                }
            }
        }
    }

    private var stickerGrid: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DSSpacing.lg) {
                if let collection, !isSearching, !recentlyAddedStickers.isEmpty {
                    recentSection(collection: collection)
                }

                if let collection {
                    ForEach(groupedStickers, id: \.team.id) { group in
                        VStack(alignment: .leading, spacing: DSSpacing.md) {
                            DSTeamSectionHeader(team: group.team)

                            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                                ForEach(group.stickers) { sticker in
                                    addCopyTile(sticker: sticker, collection: collection)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
    }

    private var gridTileWidth: CGFloat {
        let contentWidth = UIScreen.main.bounds.width - (DSSpacing.lg * 2)
        let columnSpacing = DSSpacing.sm * CGFloat(columns.count - 1)
        return (contentWidth - columnSpacing) / CGFloat(columns.count)
    }

    private func recentSection(collection: CollectionRepository) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader(title: L10n.exchangeAddCopyRecent, compact: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    ForEach(recentlyAddedStickers) { sticker in
                        addCopyTile(sticker: sticker, collection: collection)
                            .frame(width: gridTileWidth)
                    }
                }
            }
        }
    }

    private func addCopyTile(
        sticker: NormalizedSticker,
        collection: CollectionRepository
    ) -> some View {
        DSStickerTile(
            sticker: sticker,
            status: collection.status(for: sticker.code),
            onTap: {
                collection.adjustDuplicates(by: 1, for: sticker.code)
                HapticFeedback.light()
            },
            onAddDuplicate: {
                collection.adjustDuplicates(by: 1, for: sticker.code)
                HapticFeedback.light()
            },
            showsToggleOwned: false
        )
    }
}
