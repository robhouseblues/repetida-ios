import SwiftUI

enum AppTab: Int, Hashable {
    case home
    case teams
    case exchange
}

struct AppRouter: View {
    @Environment(\.collectionRepository) private var collection
    @State private var selectedTab: AppTab = .home
    @State private var showAlbumCompletionCelebration = false

    init() {
        IconOnlyTabBar.configure()
    }

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView(onSelectTab: selectTab)
                    .accessibilityLabel(L10n.tabHome)
                    .tabItem {
                        IconOnlyTabBar.icon("house.fill")
                    }
                    .tag(AppTab.home)

                TeamsView()
                    .accessibilityLabel(L10n.tabTeams)
                    .tabItem {
                        IconOnlyTabBar.icon("flag.2.crossed.fill")
                    }
                    .tag(AppTab.teams)

                ExchangeView()
                    .accessibilityLabel(L10n.tabRepetidas)
                    .tabItem {
                        IconOnlyTabBar.icon("square.on.square.fill")
                    }
                    .tag(AppTab.exchange)
            }
            .tint(DSColors.primary)

            if showAlbumCompletionCelebration, let collection {
                let progress = collection.albumProgress()
                DSAlbumCompletionBanner(
                    owned: progress.owned,
                    total: progress.total,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showAlbumCompletionCelebration = false
                        }
                    }
                )
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showAlbumCompletionCelebration)
        .onReceive(NotificationCenter.default.publisher(for: .albumDidComplete)) { _ in
            HapticFeedback.success()
            showAlbumCompletionCelebration = true
        }
    }

    private func selectTab(_ tab: AppTab, teamsSort: TeamSortOrder? = nil) {
        if let teamsSort {
            UserDefaults.standard.set(teamsSort.rawValue, forKey: TeamsView.sortOrderStorageKey)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                selectedTab = tab
            }
        }
    }
}
