import SwiftUI

struct ExchangeView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @State private var viewModel = ExchangeViewModel()
    @AppStorage("exchangeSortOrder") private var sortOrderRaw = ExchangeSortOrder.albumPage.rawValue
    @State private var query = ""
    @State private var quickFilter: ExchangeQuickFilter = .all
    @State private var showShareSheet = false
    @State private var showAddCopy = false
    @State private var dragSession: ExchangeDragSession?
    @State private var hoveredZone: ExchangeDragZone?
    @State private var dockFrames: [ExchangeDragZone: CGRect] = [:]
    @State private var tileFrames: [String: CGRect] = [:]
    @AppStorage("hasDismissedExchangeDragHint") private var hasDismissedExchangeDragHint = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)

    private var sortOrder: ExchangeSortOrder {
        ExchangeSortOrder(resolving: sortOrderRaw)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                if let collection {
                    if viewModel.allDuplicateItems(catalog: catalog, collection: collection).isEmpty {
                        emptyState
                    } else {
                        mainContent(collection: collection)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle(L10n.tabRepetidas)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.sortOrder = sortOrder
            }
            .onChange(of: sortOrderRaw) { _, _ in
                viewModel.sortOrder = sortOrder
            }
            .onChange(of: query) { _, _ in
                quickFilter = .all
            }
            .navigationDestination(isPresented: $showAddCopy) {
                ExchangeAddCopyView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let collection {
                    ExchangeShareSheet(
                        payload: viewModel.sharePayload(
                            catalog: catalog,
                            collection: collection,
                            query: query,
                            filter: quickFilter
                        ),
                        whatsAppText: viewModel.whatsAppText(
                            catalog: catalog,
                            collection: collection,
                            query: query,
                            filter: quickFilter
                        )
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "square.on.square")
                .font(.system(size: 40))
                .foregroundStyle(DSColors.goldFoil.opacity(0.5))
            Text(L10n.noDuplicatesYet)
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textMuted)
            if collection != nil {
                DSActionCapsuleButton(title: L10n.exchangeAddCopy) {
                    showAddCopy = true
                }
                .padding(.top, DSSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mainContent(collection: CollectionRepository) -> some View {
        let teamChips = viewModel.teamChips(
            catalog: catalog,
            collection: collection,
            query: query
        )
        let groups = viewModel.groupedSections(
            catalog: catalog,
            collection: collection,
            query: query,
            filter: quickFilter
        )

        return ZStack(alignment: .bottom) {
            VStack(spacing: DSSpacing.md) {
                DSScreenHeader(
                    title: L10n.tabRepetidas,
                    searchText: $query,
                    searchPlaceholder: L10n.exchangeSearchPlaceholder,
                    subtitle: viewModel.insightText(catalog: catalog, collection: collection)
                ) {
                    HStack(spacing: DSSpacing.sm) {
                        addCopyIconButton
                        shareButton
                        sortChip
                    }
                }

                if showsDragHint {
                    ExchangeDragHint(onDismiss: dismissDragHint)
                        .padding(.horizontal, DSSpacing.lg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if !teamChips.isEmpty {
                    ExchangeFilterChipBar(
                        teamChips: teamChips,
                        quickFilter: $quickFilter
                    )
                }

                if groups.isEmpty {
                    noResultsState
                } else {
                    duplicatesGrid(groups: groups, collection: collection)
                }
            }

            if dragSession != nil {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .zIndex(100)

                ExchangeDragDock(hoveredZone: hoveredZone)
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, DSSpacing.md)
                    .zIndex(150)
            }

            if let session = dragSession,
               let item = draggedItem(code: session.stickerCode, in: groups) {
                ExchangeDragPreview(item: item, session: session)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(200)
            }
        }
        .animation(.easeOut(duration: 0.2), value: dragSession != nil)
        .animation(.easeOut(duration: 0.2), value: showsDragHint)
        .exchangeDragDockFrames($dockFrames)
        .exchangeTileFrames($tileFrames)
    }

    private func draggedItem(
        code: String,
        in groups: [(team: Team, stickers: [ExchangeStickerItem])]
    ) -> ExchangeStickerItem? {
        groups.lazy
            .flatMap(\.stickers)
            .first { $0.sticker.code == code }
    }

    private var noResultsState: some View {
        Text(L10n.noStickersFound)
            .font(DSTypography.body())
            .foregroundStyle(DSColors.textMuted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var showsDragHint: Bool {
        !hasDismissedExchangeDragHint
    }

    private func dismissDragHint() {
        hasDismissedExchangeDragHint = true
    }

    private var sortChip: some View {
        DSSortChip(title: L10n.exchangeSort, accessibilityLabel: L10n.exchangeSort) {
            ForEach(ExchangeSortOrder.allCases) { order in
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

    private var shareButton: some View {
        DSToolbarIconButton(
            systemName: "square.and.arrow.up",
            accessibilityLabel: L10n.exchangeShare
        ) {
            showShareSheet = true
        }
    }

    private var addCopyIconButton: some View {
        DSToolbarIconButton(
            systemName: "plus",
            accessibilityLabel: L10n.exchangeAddCopy
        ) {
            showAddCopy = true
        }
    }

    private func duplicatesGrid(
        groups: [(team: Team, stickers: [ExchangeStickerItem])],
        collection: CollectionRepository
    ) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(groups, id: \.team.id) { group in
                    teamSection(group: group, collection: collection)
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
        .scrollDisabled(dragSession != nil)
    }

    private func teamSection(
        group: (team: Team, stickers: [ExchangeStickerItem]),
        collection: CollectionRepository
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            DSTeamSectionHeader(team: group.team)

            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(group.stickers) { item in
                    exchangeTile(item: item, collection: collection)
                }
            }
        }
    }

    private func exchangeTile(
        item: ExchangeStickerItem,
        collection: CollectionRepository
    ) -> some View {
        ExchangeDraggableTile(
            item: item,
            dragSession: $dragSession,
            hoveredZone: $hoveredZone,
            tileFrames: tileFrames,
            dockFrames: dockFrames,
            onAdd: {
                collection.adjustDuplicates(by: 1, for: item.sticker.code)
                dismissDragHint()
            },
            onRemove: {
                collection.adjustDuplicates(by: -1, for: item.sticker.code)
                dismissDragHint()
            }
        )
    }

    private func sortLabel(for order: ExchangeSortOrder) -> String {
        L10n.sortLabel(for: order)
    }
}
