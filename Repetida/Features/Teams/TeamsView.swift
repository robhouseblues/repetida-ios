import SwiftUI

struct TeamsView: View {
    static let sortOrderStorageKey = "teamsSortOrder"

    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    @AppStorage(sortOrderStorageKey) private var sortOrderRaw = TeamSortOrder.albumPage.rawValue
    @State private var query = ""
    @State private var groupedTeamsCache: [(section: AlbumSection, teams: [Team])] = []
    @State private var orderedTeamsCache: [Team] = []

    private var sortOrder: TeamSortOrder {
        TeamSortOrder(rawValue: sortOrderRaw) ?? .albumPage
    }

    private var filteredGroupedTeams: [(section: AlbumSection, teams: [Team])] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return groupedTeamsCache }

        return groupedTeamsCache.compactMap { group in
            let teams = group.teams.filter { team in
                let searchable = [team.name, team.code, team.weAreTitle]
                    .joined(separator: " ")
                    .lowercased()
                return searchable.contains(trimmed)
            }
            guard !teams.isEmpty else { return nil }
            return (group.section, teams)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                List {
                    ForEach(filteredGroupedTeams, id: \.section) { group in
                        Section {
                            ForEach(Array(group.teams.enumerated()), id: \.element.id) { index, team in
                                if let collection {
                                    NavigationLink {
                                        TeamDetailPagerView(teams: orderedTeamsCache, initialTeam: team)
                                    } label: {
                                        DSTeamRow(
                                            team: team,
                                            progress: collection.progress(for: team.id)
                                        )
                                    }
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 0,
                                            leading: DSSpacing.lg,
                                            bottom: 0,
                                            trailing: DSSpacing.lg
                                        )
                                    )
                                    .listRowSeparator(
                                        index < group.teams.count - 1 ? .visible : .hidden,
                                        edges: .bottom
                                    )
                                    .listRowSeparatorTint(DSColors.cardBorder.opacity(0.65))
                                    .listRowBackground(
                                        DSGroupedListRowBackground(
                                            position: .at(index: index, count: group.teams.count)
                                        )
                                    )
                                }
                            }
                        } header: {
                            DSCompactSectionHeader(title: group.section.displayName)
                        }
                    }
                }
                .listSectionSpacing(DSSpacing.md)
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .top, spacing: 0) {
                    DSScreenHeader(
                        title: L10n.tabTeams,
                        searchText: $query,
                        searchPlaceholder: L10n.teamsSearchPlaceholder,
                        style: .pinned
                    ) {
                        sortChip
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task(id: sortOrderRaw) {
            rebuildTeamLists()
        }
    }

    private func completionFractionLookup() -> ((Team) -> Double)? {
        guard sortOrder == .completion, let collection else { return nil }
        let progressByTeamId = Dictionary(
            uniqueKeysWithValues: catalog.teams.map { team in
                (team.id, collection.progress(for: team.id).fraction)
            }
        )
        return { progressByTeamId[$0.id, default: 0] }
    }

    private func rebuildTeamLists() {
        let fraction = completionFractionLookup()
        groupedTeamsCache = catalog.teamsGroupedBySection(
            sortBy: sortOrder,
            completionFraction: fraction
        )
        orderedTeamsCache = catalog.teamsInListOrder(
            sortBy: sortOrder,
            completionFraction: fraction
        )
    }

    private var sortChip: some View {
        DSSortChip(title: sortLabel(for: sortOrder), accessibilityLabel: L10n.sortTeams) {
            ForEach(TeamSortOrder.allCases) { order in
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

    private func sortLabel(for order: TeamSortOrder) -> String {
        L10n.sortLabel(for: order)
    }
}

struct TeamDetailView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    let team: Team
    @AppStorage(TeamPageLockStore.storageKey) private var lockedTeamPageIdsRaw = ""
    @State private var showCompletionCelebration = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)

    private var isLocked: Bool {
        TeamPageLockStore.isLocked(teamId: team.id, in: lockedTeamPageIdsRaw)
    }

    var body: some View {
        detailContent
    }

    private var detailContent: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    header

                    if let collection {
                        if isLocked {
                            lockedBanner
                        }

                        stickerGrid(
                            collection: collection,
                            stickers: catalog.stickers(forTeamId: team.id)
                        )
                    }
                }
                .padding(DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl)
            }
            .scrollContentBackground(.hidden)

            if showCompletionCelebration, let collection {
                let progress = collection.progress(for: team.id)
                DSTeamCompletionBanner(
                    owned: progress.owned,
                    total: progress.total,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showCompletionCelebration = false
                        }
                    }
                )
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showCompletionCelebration)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
                Text(team.weAreTitle)
                    .font(DSTypography.display(18))
                    .foregroundStyle(DSColors.textPrimary)

                Spacer(minLength: DSSpacing.sm)

                Text(team.albumPagesLabel)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColors.textMuted)
            }

            if let collection {
                let progress = collection.progress(for: team.id)
                HStack(spacing: DSSpacing.sm) {
                    ProgressView(value: progress.fraction)
                        .tint(DSColors.primary)
                    Text(L10n.teamProgressLabel(progress.owned, progress.total))
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.textMuted)
                        .monospacedDigit()
                        .fixedSize()
                }
            }
        }
    }

    private func isTeamComplete(collection: CollectionRepository) -> Bool {
        missingCount(collection: collection) == 0
    }

    private func handleCompletionAfterChange(
        collection: CollectionRepository,
        wasComplete: Bool
    ) {
        guard isTeamComplete(collection: collection) else {
            HapticFeedback.light()
            return
        }

        if !wasComplete {
            lockedTeamPageIdsRaw = TeamPageLockStore.lock(teamId: team.id, in: lockedTeamPageIdsRaw)
        }

        guard !wasComplete, TeamCompletionCelebrationStore.shouldShow(for: team.id) else {
            HapticFeedback.light()
            return
        }
        TeamCompletionCelebrationStore.markShown(for: team.id)
        HapticFeedback.success()
        showCompletionCelebration = true
    }

    private func handleIncompleteAfterChange(collection: CollectionRepository) {
        guard !isTeamComplete(collection: collection) else { return }
        TeamCompletionCelebrationStore.clear(for: team.id)
        lockedTeamPageIdsRaw = TeamPageLockStore.unlock(teamId: team.id, in: lockedTeamPageIdsRaw)
        showCompletionCelebration = false
    }

    private func missingCount(collection: CollectionRepository) -> Int {
        catalog.stickers(forTeamId: team.id)
            .filter { !collection.status(for: $0.code).isOwned }
            .count
    }

    private func stickerGrid(
        collection: CollectionRepository,
        stickers: [NormalizedSticker]
    ) -> some View {
        LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
            ForEach(stickers) { sticker in
                DSStickerTile(
                    sticker: sticker,
                    status: collection.status(for: sticker.code),
                    onTap: {
                        guard !isLocked else { return }
                        let wasComplete = isTeamComplete(collection: collection)
                        let current = collection.status(for: sticker.code)
                        collection.setOwned(!current.isOwned, for: sticker.code)
                        if current.isOwned {
                            handleIncompleteAfterChange(collection: collection)
                            HapticFeedback.light()
                        } else {
                            handleCompletionAfterChange(
                                collection: collection,
                                wasComplete: wasComplete
                            )
                        }
                    },
                    onAddDuplicate: {
                        guard !isLocked else { return }
                        collection.adjustDuplicates(by: 1, for: sticker.code)
                        HapticFeedback.light()
                    },
                    onRemoveDuplicate: {
                        guard !isLocked else { return }
                        collection.adjustDuplicates(by: -1, for: sticker.code)
                        HapticFeedback.light()
                    },
                    onLongPress: isLocked ? nil : {
                        collection.adjustDuplicates(by: 1, for: sticker.code)
                        HapticFeedback.light()
                    },
                    isInteractionDisabled: isLocked
                )
            }
        }
    }

    private var lockedBanner: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DSColors.goldFoil)

            Text(L10n.teamPageLocked)
                .font(DSTypography.caption())
                .foregroundStyle(DSColors.textMuted)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(DSColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                        .strokeBorder(DSColors.primaryChrome.opacity(0.35), lineWidth: 1)
                )
        )
    }
}
