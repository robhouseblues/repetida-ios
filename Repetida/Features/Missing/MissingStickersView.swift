import SwiftUI

struct MissingStickersView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @State private var query = ""
    @State private var focusedTeamId: String?
    @AppStorage("missingSortOrder") private var sortOrderRaw = MissingSortOrder.albumPage.rawValue

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)

    private var sortOrder: MissingSortOrder {
        MissingSortOrder(resolving: sortOrderRaw)
    }

    private var groupedMissing: [(team: Team, stickers: [NormalizedSticker])] {
        guard let collection else { return [] }
        return MissingFilterHelper.groupedMissing(
            catalog: catalog,
            collection: collection,
            query: query,
            order: sortOrder,
            focusedTeamId: focusedTeamId
        )
    }

    private var teamChips: [MissingTeamChip] {
        guard let collection else { return [] }
        return MissingFilterHelper.teamChips(
            catalog: catalog,
            collection: collection,
            query: query,
            order: sortOrder
        )
    }

    private var totalMissing: Int {
        collection?.missingStickers().count ?? 0
    }

    var body: some View {
        NavigationStack {
            missingContent
        }
    }

    private var missingContent: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: DSSpacing.md) {
                DSScreenHeader(
                    title: L10n.missingTitle,
                    searchText: $query,
                    searchPlaceholder: L10n.missingSearchPlaceholder
                ) {
                    sortChip
                }

                if totalMissing > 0, !teamChips.isEmpty {
                    MissingTeamChipBar(
                        teamChips: teamChips,
                        focusedTeamId: $focusedTeamId
                    )
                }

                if totalMissing == 0 {
                    allOwnedState
                } else if groupedMissing.isEmpty {
                    noSearchResults
                } else {
                    missingGrid
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: query) { _, _ in
            focusedTeamId = nil
        }
    }

    private var sortChip: some View {
        DSSortChip(title: sortLabel(for: sortOrder), accessibilityLabel: L10n.missingSortTitle) {
            ForEach(MissingSortOrder.allCases) { order in
                Button {
                    sortOrderRaw = order.rawValue
                    HapticFeedback.light()
                } label: {
                    if sortOrder == order {
                        Label(sortLabel(for: order), systemImage: "checkmark")
                    } else {
                        Text(sortLabel(for: order))
                    }
                }
            }
        }
    }

    private func sortLabel(for order: MissingSortOrder) -> String {
        L10n.sortLabel(for: order)
    }

    private var allOwnedState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(DSColors.primary.opacity(0.6))
            Text(L10n.missingAllOwned)
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textMuted)
        }
        .frame(maxHeight: .infinity)
    }

    private var noSearchResults: some View {
        Text(L10n.noStickersFound)
            .font(DSTypography.body())
            .foregroundStyle(DSColors.textMuted)
            .frame(maxHeight: .infinity)
    }

    private var missingGrid: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DSSpacing.lg) {
                if let collection {
                    ForEach(groupedMissing, id: \.team.id) { group in
                        VStack(alignment: .leading, spacing: DSSpacing.md) {
                            DSTeamSectionHeader(team: group.team)

                            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                                ForEach(group.stickers) { sticker in
                                    missingStickerTile(sticker: sticker, collection: collection)
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

    private func missingStickerTile(
        sticker: NormalizedSticker,
        collection: CollectionRepository
    ) -> some View {
        DSStickerTile(
            sticker: sticker,
            status: collection.status(for: sticker.code),
            onTap: {
                let current = collection.status(for: sticker.code)
                collection.setOwned(!current.isOwned, for: sticker.code)
                HapticFeedback.light()
            },
            onAddDuplicate: {
                collection.adjustDuplicates(by: 1, for: sticker.code)
                HapticFeedback.light()
            },
            onRemoveDuplicate: {
                collection.adjustDuplicates(by: -1, for: sticker.code)
                HapticFeedback.light()
            }
        )
    }
}
