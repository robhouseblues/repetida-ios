import SwiftUI

private enum HomeLayout {
    /// Tighter vertical rhythm so progress, stats, and first quase-completa fit above the fold.
    static let sectionSpacing = DSSpacing.lg
    static let heroClusterSpacing = DSSpacing.md
}

private extension View {
    /// Shared secondary surface for stats, quase-completas, and activity rows.
    func homeSecondaryCard() -> some View {
        atmosphericCardSurface(
            cornerRadius: DSRadius.sm,
            showScanlines: false,
            showsShadow: false
        )
    }
}

struct HomeView: View {
    @Environment(CatalogRepository.self) private var catalog
    @Environment(\.collectionRepository) private var collection

    var onSelectTab: (AppTab, TeamSortOrder?) -> Void = { _, _ in }

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphericBackground()

                ScrollView {
                    VStack(spacing: HomeLayout.sectionSpacing) {
                        if let collection {
                            VStack(spacing: HomeLayout.heroClusterSpacing) {
                                progressCard(collection: collection)
                                statsRow(collection: collection)
                            }
                            if showsGettingStartedEmptyState(collection: collection) {
                                gettingStartedEmptyState
                            } else {
                                closestTeamsSection(collection: collection)
                                recentSection(collection: collection)
                            }
                        }
                    }
                    .padding(DSSpacing.lg)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func progressCard(collection: CollectionRepository) -> some View {
        let progress = collection.albumProgress()

        return DSCard {
            VStack(spacing: DSSpacing.lg) {
                DSProgressRing(
                    progress: progress.fraction,
                    label: "\(progress.owned) / \(progress.total)"
                )

                if progress.owned >= progress.total, progress.total > 0 {
                    Text(L10n.homeAlbumComplete)
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.goldFoil)
                } else {
                    Text(L10n.albumCompletion)
                        .font(DSTypography.body(14))
                        .foregroundStyle(DSColors.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private enum StatCardLayout {
        /// Uniform content area; number + label sit tight and center as a group.
        static let contentHeight: CGFloat = 54
        static let valueLabelSpacing: CGFloat = 2
        static let horizontalPadding = DSSpacing.sm
        static let verticalPadding = DSSpacing.sm
    }

    private func statsRow(collection: CollectionRepository) -> some View {
        let progress = collection.albumProgress()
        let teamsProgress = collection.teamsCompletionProgress(for: .national)

        return HStack(alignment: .center, spacing: DSSpacing.md) {
            Button {
                onSelectTab(.teams, nil)
            } label: {
                secondaryStatCard(title: L10n.statMissing) {
                    Text("\(progress.missing)")
                        .font(DSTypography.display(20))
                        .foregroundStyle(DSColors.textMuted)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            Button {
                onSelectTab(.exchange, nil)
            } label: {
                secondaryStatCard(title: L10n.statDuplicates) {
                    Text("\(progress.duplicateCount)")
                        .font(DSTypography.display(20))
                        .foregroundStyle(DSColors.duplicate)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            Button {
                onSelectTab(.teams, .completion)
            } label: {
                secondaryStatCard(title: L10n.statTeamsCompleted) {
                    Text("\(teamsProgress.completed)/\(teamsProgress.total)")
                        .font(DSTypography.display(20))
                        .foregroundStyle(DSColors.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .accessibilityLabel(
                L10n.statTeamsAccessibility(teamsProgress.completed, teamsProgress.total)
            )
        }
    }

    private func secondaryStatCard<Value: View>(
        title: String,
        @ViewBuilder value: () -> Value
    ) -> some View {
        VStack(spacing: StatCardLayout.valueLabelSpacing) {
            value()
                .frame(maxWidth: .infinity)

            Text(title)
                .font(DSTypography.caption(11))
                .foregroundStyle(DSColors.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: StatCardLayout.contentHeight, alignment: .center)
        .padding(.horizontal, StatCardLayout.horizontalPadding)
        .padding(.vertical, StatCardLayout.verticalPadding)
        .homeSecondaryCard()
    }

    @ViewBuilder
    private func closestTeamsSection(collection: CollectionRepository) -> some View {
        let closest = HomeCollectionInsights.closestTeams(
            catalog: catalog,
            collection: collection
        )
        if !closest.isEmpty {
            let pagerTeams = HomeCollectionInsights.nationalTeamsInPagerOrder(catalog: catalog)

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(title: L10n.homeClosestTeams)

                ForEach(closest, id: \.team.id) { item in
                    NavigationLink {
                        TeamDetailPagerView(teams: pagerTeams, initialTeam: item.team)
                    } label: {
                        closestTeamRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func closestTeamRow(item: ClosestTeamInsight) -> some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(item.team.flaggedName)
                    .font(DSTypography.body())
                    .foregroundStyle(DSColors.textPrimary)

                if let sticker = item.nextSticker {
                    Text(L10n.homeClosestTeamSubtitle(sticker.code, sticker.name))
                        .font(DSTypography.caption())
                        .foregroundStyle(DSColors.textMuted)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: DSSpacing.xs) {
                Text(L10n.homeTeamFalta(item.missing))
                    .font(DSTypography.caption(11))
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColors.goldFoil)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(DSColors.goldFoil.opacity(0.14))
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.textMuted.opacity(0.7))
            }
        }
        .padding(DSSpacing.md)
        .homeSecondaryCard()
        .accessibilityElement(children: .combine)
    }

    private func showsGettingStartedEmptyState(collection: CollectionRepository) -> Bool {
        collection.albumProgress().owned == 0 && collection.recentActivities(limit: 1).isEmpty
    }

    private var gettingStartedEmptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "square.dashed")
                .font(.system(size: 40))
                .foregroundStyle(DSColors.primary.opacity(0.65))

            Text(L10n.homeEmptyTitle)
                .font(DSTypography.body())
                .foregroundStyle(DSColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(L10n.homeEmptyMessage)
                .font(DSTypography.caption())
                .foregroundStyle(DSColors.textMuted)
                .multilineTextAlignment(.center)

            DSActionCapsuleButton(title: L10n.homeEmptyGoToTeams) {
                onSelectTab(.teams, nil)
            }
            .padding(.top, DSSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.lg)
        .homeSecondaryCard()
    }

    private func recentSection(collection: CollectionRepository) -> some View {
        let recent = collection.recentActivities(limit: 8)

        return Group {
            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    DSSectionHeader(title: L10n.recentlyUpdated)

                    ForEach(recent) { activity in
                        if let sticker = catalog.sticker(forCode: activity.stickerCode),
                           let team = catalog.team(for: sticker) {
                            StickerResultRow(
                                sticker: sticker,
                                team: team,
                                status: collection.status(for: activity.stickerCode),
                                isCompact: true,
                                isInteractive: false,
                                updateLabel: L10n.recentActivityDescription(
                                    kind: activity.kind,
                                    date: activity.date
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}
