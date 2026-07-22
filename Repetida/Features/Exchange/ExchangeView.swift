import SwiftUI

struct ExchangeView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @State private var viewModel = ExchangeViewModel()
    @State private var dragController = ExchangeDragController()
    @AppStorage("exchangeSortOrder") private var sortOrderRaw = ExchangeSortOrder.albumPage.rawValue
    @State private var query = ""
    @State private var quickFilter: ExchangeQuickFilter = .all
    @State private var showShareSheet = false
    @State private var showAddCopy = false
    @AppStorage("hasDismissedExchangeDragHint") private var hasDismissedExchangeDragHint = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)

    private var sortOrder: ExchangeSortOrder {
        ExchangeSortOrder(resolving: sortOrderRaw)
    }

    private var collectionChangeToken: Int {
        collection?.changeToken ?? -1
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                if collection != nil {
                    if viewModel.allItems.isEmpty {
                        emptyState
                    } else {
                        mainContent
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle(L10n.tabRepetidas)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.sortOrder = sortOrder
                refreshInventory()
            }
            .onChange(of: sortOrderRaw) { _, _ in
                viewModel.sortOrder = sortOrder
                refreshInventory()
            }
            .onChange(of: query) { _, _ in
                quickFilter = .all
                refreshInventory()
            }
            .onChange(of: quickFilter) { _, _ in
                refreshInventory()
            }
            .onChange(of: collectionChangeToken) { _, _ in
                refreshInventory()
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

    private func refreshInventory() {
        guard let collection else { return }
        viewModel.refresh(
            catalog: catalog,
            collection: collection,
            query: query,
            filter: quickFilter
        )
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

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: DSSpacing.md) {
                DSScreenHeader(
                    title: L10n.tabRepetidas,
                    searchText: $query,
                    searchPlaceholder: L10n.exchangeSearchPlaceholder,
                    subtitle: viewModel.insightText
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

                if !viewModel.teamChips.isEmpty {
                    ExchangeFilterChipBar(
                        teamChips: viewModel.teamChips,
                        quickFilter: $quickFilter
                    )
                }

                if viewModel.groups.isEmpty {
                    noResultsState
                } else {
                    duplicatesGrid
                }
            }
            .animation(.easeOut(duration: 0.2), value: showsDragHint)

            ExchangeDragOverlay(controller: dragController)
                .zIndex(100)
        }
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

    private var duplicatesGrid: some View {
        ExchangeDuplicatesGrid(
            groups: viewModel.groups,
            columns: columns,
            dragController: dragController,
            onAdd: { code in
                collection?.adjustDuplicates(by: 1, for: code)
                dismissDragHint()
            },
            onRemove: { code in
                collection?.adjustDuplicates(by: -1, for: code)
                dismissDragHint()
            }
        )
    }

    private func sortLabel(for order: ExchangeSortOrder) -> String {
        L10n.sortLabel(for: order)
    }
}

/// Isolated scroll/grid so drag-session updates don't rebuild header/chips via preference churn.
private struct ExchangeDuplicatesGrid: View {
    let groups: [(team: Team, stickers: [ExchangeStickerItem])]
    let columns: [GridItem]
    @Bindable var dragController: ExchangeDragController
    let onAdd: (String) -> Void
    let onRemove: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DSSpacing.lg) {
                ForEach(groups, id: \.team.id) { group in
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        DSTeamSectionHeader(team: group.team)

                        LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                            ForEach(group.stickers) { item in
                                ExchangeDraggableTile(
                                    item: item,
                                    controller: dragController,
                                    onAdd: { onAdd(item.sticker.code) },
                                    onRemove: { onRemove(item.sticker.code) }
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
            .onPreferenceChange(ExchangeTileFrameKey.self) { frames in
                dragController.tileFrames = frames
            }
        }
        .scrollDisabled(dragController.session != nil)
    }
}
