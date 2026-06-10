import SwiftUI

struct TeamDetailPagerView: View {
    let teams: [Team]
    @State private var selectedIndex: Int
    @State private var showTeamPicker = false
    @State private var allowNonAdjacentPageChange = false
    @AppStorage(TeamPageLockStore.storageKey) private var lockedTeamPageIdsRaw = ""
    @AppStorage("hasDismissedTeamSwipeHint") private var hasDismissedTeamSwipeHint = false

    init(teams: [Team], initialTeam: Team) {
        self.teams = teams
        let index = teams.firstIndex(where: { $0.id == initialTeam.id }) ?? 0
        _selectedIndex = State(initialValue: index)
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            TabView(selection: $selectedIndex) {
                ForEach(Array(teams.enumerated()), id: \.element.id) { index, team in
                    TeamDetailView(team: team)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if showsNavigationHint {
                TeamPagerNavigationHint(onDismiss: dismissNavigationHint)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, DSSpacing.xs)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: showsNavigationHint)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .pushedNavigationChrome()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    showTeamPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(currentTeam.flaggedCode)
                            .font(DSTypography.display(22))
                            .foregroundStyle(DSColors.textPrimary)
                            .textCase(.uppercase)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DSColors.textMuted)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.teamPickerOpen(currentTeam.code))
            }

            ToolbarItem(placement: .topBarTrailing) {
                DSToolbarIconButton(
                    systemName: isCurrentTeamLocked ? "lock.fill" : "lock.open",
                    accessibilityLabel: isCurrentTeamLocked ? L10n.teamPageUnlock : L10n.teamPageLock,
                    foregroundColor: isCurrentTeamLocked ? DSColors.primary : DSColors.textMuted
                ) {
                    toggleLock(for: currentTeam.id)
                }
            }
        }
        .sheet(isPresented: $showTeamPicker) {
            TeamPickerSheet(
                teams: teams,
                currentTeamId: currentTeam.id,
                onSelect: { team in
                    navigateToTeam(team)
                }
            )
        }
        .onChange(of: showTeamPicker) { _, isPresented in
            if isPresented {
                dismissNavigationHint()
            }
        }
        .onChange(of: selectedIndex) { oldValue, newValue in
            guard newValue >= 0, newValue < teams.count else {
                selectedIndex = oldValue
                return
            }
            if allowNonAdjacentPageChange {
                allowNonAdjacentPageChange = false
                HapticFeedback.light()
                dismissNavigationHint()
                return
            }
            // TabView page style can wrap cyclically (first ↔ last); only allow ±1 steps.
            guard abs(newValue - oldValue) == 1 else {
                selectedIndex = oldValue
                return
            }
            HapticFeedback.light()
            dismissNavigationHint()
        }
    }

    private var showsNavigationHint: Bool {
        teams.count > 1 && !hasDismissedTeamSwipeHint
    }

    private var currentTeam: Team {
        teams[selectedIndex]
    }

    private func navigateToTeam(_ team: Team) {
        guard let index = teams.firstIndex(where: { $0.id == team.id }),
              index != selectedIndex else { return }
        allowNonAdjacentPageChange = true
        withAnimation {
            selectedIndex = index
        }
    }

    private var isCurrentTeamLocked: Bool {
        isTeamLocked(currentTeam.id)
    }

    private func isTeamLocked(_ teamId: String) -> Bool {
        TeamPageLockStore.isLocked(teamId: teamId, in: lockedTeamPageIdsRaw)
    }

    private func toggleLock(for teamId: String) {
        lockedTeamPageIdsRaw = TeamPageLockStore.toggle(teamId: teamId, in: lockedTeamPageIdsRaw)
        HapticFeedback.light()
    }

    private func dismissNavigationHint() {
        guard !hasDismissedTeamSwipeHint else { return }
        hasDismissedTeamSwipeHint = true
    }
}
