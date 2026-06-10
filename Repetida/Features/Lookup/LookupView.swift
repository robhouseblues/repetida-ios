import SwiftUI

struct LookupView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @State private var query = ""
    @State private var selectedSticker: NormalizedSticker?

    private var results: [(sticker: NormalizedSticker, team: Team)] {
        catalog.search(query: query)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                VStack(spacing: DSSpacing.lg) {
                    DSSearchField(text: $query)
                        .padding(.horizontal, DSSpacing.lg)
                        .padding(.top, DSSpacing.sm)

                    if query.isEmpty {
                        emptyPrompt
                    } else if results.isEmpty {
                        noResults
                    } else {
                        resultsList
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedSticker) { sticker in
                if let team = catalog.team(for: sticker), let collection {
                    StickerDetailSheet(
                        sticker: sticker,
                        team: team,
                        status: collection.status(for: sticker.code),
                        onToggleOwned: {
                            toggleOwned(sticker: sticker, collection: collection)
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
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }

    private var emptyPrompt: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(DSColors.primary.opacity(0.6))
            Text(L10n.searchPrompt)
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textMuted)
        }
        .frame(maxHeight: .infinity)
    }

    private var noResults: some View {
        Text(L10n.noStickersFound)
            .font(DSTypography.body())
            .foregroundStyle(DSColors.textMuted)
            .frame(maxHeight: .infinity)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.sm) {
                if let collection {
                    ForEach(results, id: \.sticker.code) { result in
                        StickerResultRow(
                            sticker: result.sticker,
                            team: result.team,
                            status: collection.status(for: result.sticker.code),
                            onTap: {
                                toggleOwned(sticker: result.sticker, collection: collection)
                            },
                            onAddDuplicate: {
                                collection.adjustDuplicates(by: 1, for: result.sticker.code)
                                HapticFeedback.light()
                            }
                        )
                        .onLongPressGesture {
                            selectedSticker = result.sticker
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
    }

    private func toggleOwned(sticker: NormalizedSticker, collection: CollectionRepository) {
        let current = collection.status(for: sticker.code)
        collection.setOwned(!current.isOwned, for: sticker.code)
        HapticFeedback.light()
    }
}

struct StickerDetailSheet: View {
    let sticker: NormalizedSticker
    let team: Team
    let status: StickerStatus
    var onToggleOwned: () -> Void
    var onAddDuplicate: () -> Void
    var onRemoveDuplicate: () -> Void

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                HStack {
                    Text(sticker.code)
                        .font(DSTypography.stickerCode(20))
                        .foregroundStyle(DSColors.goldShimmer)
                    Spacer()
                    DSStickerStatusBadge(status: status)
                }

                Text(sticker.name)
                    .font(DSTypography.display(22))
                    .foregroundStyle(DSColors.textPrimary)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(team.name)
                        .font(DSTypography.body())
                        .foregroundStyle(DSColors.textPrimary)
                    Text(team.albumPagesLabel.isEmpty ? team.code : "\(team.code) · \(team.albumPagesLabel)")
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.textMuted)
                }

                HStack(spacing: DSSpacing.md) {
                    Button(L10n.toggleOwned, action: onToggleOwned)
                        .buttonStyle(DetailButtonStyle())

                    Button(L10n.addDuplicateShort, action: onAddDuplicate)
                        .buttonStyle(DetailButtonStyle(accent: DSColors.duplicate, filled: true))

                    if status.duplicateCount > 0 {
                        Button(L10n.removeDuplicateShort, action: onRemoveDuplicate)
                            .buttonStyle(DetailButtonStyle(accent: DSColors.textMuted))
                    }
                }

                Spacer()
            }
            .padding(DSSpacing.xl)
        }
    }
}

struct DetailButtonStyle: ButtonStyle {
    var accent: Color = DSColors.primary
    var filled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.caption())
            .foregroundStyle(filled ? DSColors.pitchDeep : accent)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background {
                if filled {
                    Capsule().fill(accent)
                } else {
                    Capsule().strokeBorder(accent.opacity(0.55), lineWidth: 1)
                }
            }
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
