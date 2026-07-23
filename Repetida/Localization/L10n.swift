import Foundation

enum L10n {
    // MARK: - Launch

    static let launchFailureTitle = String(localized: "launch.failure.title")
    static let launchFailureMessage = String(localized: "launch.failure.message")
    static let launchFailureRetry = String(localized: "launch.failure.retry")

    // MARK: - Tabs

    static let tabHome = String(localized: "tab.home")
    static let tabTeams = String(localized: "tab.teams")
    static let tabMissing = String(localized: "tab.missing")
    static let tabRepetidas = String(localized: "tab.repetidas")

    // MARK: - Home

    static let albumCompletion = String(localized: "home.albumCompletion")
    static let statMissing = String(localized: "home.stat.missing")
    static let statDuplicates = String(localized: "home.stat.duplicates")
    static let statTeamsCompleted = String(localized: "home.stat.teamsCompleted")
    static func statTeamsAccessibility(_ completed: Int, _ total: Int) -> String {
        String(localized: "home.stat.teamsAccessibility \(completed) \(total)")
    }
    static let recentlyUpdated = String(localized: "home.recentlyUpdated")
    static func recentActivityDescription(kind: RecentUpdateKind, date: Date) -> String {
        let action = recentActionPhrase(for: kind)
        let when = date.formatted(.relative(presentation: .named))
        return "\(action) · \(when)"
    }

    private static func recentActionPhrase(for kind: RecentUpdateKind) -> String {
        switch kind {
        case .markedOwned: return String(localized: "home.recent.addedToCollection")
        case .markedMissing: return String(localized: "home.recent.removedFromCollection")
        case .duplicateAdded: return String(localized: "home.recent.duplicateRegistered")
        case .duplicateRemoved: return String(localized: "home.recent.duplicateRemoved")
        }
    }
    static let homeClosestTeams = String(localized: "home.closestTeams")
    static func homeTeamFalta(_ count: Int) -> String {
        count == 1
            ? String(localized: "home.teamFaltaOne")
            : String(localized: "home.teamFaltam \(count)")
    }
    static let homeAlbumComplete = String(localized: "home.albumComplete")
    static let homeEmptyTitle = String(localized: "home.empty.title")
    static let homeEmptyMessage = String(localized: "home.empty.message")
    static let homeEmptyGoToMissing = String(localized: "home.empty.goToMissing")
    static func homeClosestTeamSubtitle(_ stickerCode: String, _ stickerName: String) -> String {
        String(localized: "home.closestTeamSubtitle \(stickerCode) \(stickerName)")
    }

    // MARK: - Missing

    static let missingTitle = String(localized: "missing.title")
    static let missingSearchPlaceholder = String(localized: "missing.searchPlaceholder")
    static let missingAllOwned = String(localized: "missing.allOwned")
    static let missingSortTitle = String(localized: "missing.sort.title")
    static let missingFilterAll = String(localized: "missing.filter.all")
    static func missingFilterTeamChip(_ code: String, _ count: Int) -> String {
        String(localized: "missing.filter.teamChip \(code) \(count)")
    }

    // MARK: - Lookup

    static let searchPlaceholder = String(localized: "lookup.searchPlaceholder")
    static let clearSearch = String(localized: "lookup.clearSearch")
    static let searchPrompt = String(localized: "lookup.searchPrompt")
    static let noStickersFound = String(localized: "lookup.noResults")

    // MARK: - Teams

    static let sortTeams = String(localized: "teams.sort.title")
    static let teamsSearchPlaceholder = String(localized: "teams.searchPlaceholder")
    static let sortByAlbumPage = String(localized: "teams.sort.albumPage")
    static let sortByTeamCode = String(localized: "teams.sort.teamCode")
    static let sortByName = String(localized: "teams.sort.name")
    static let sortByCompletion = String(localized: "teams.sort.completion")
    static let sortByQuantity = String(localized: "exchange.sort.quantity")

    static func sortLabel(for order: TeamSortOrder) -> String {
        switch order {
        case .albumPage: sortByAlbumPage
        case .teamCode: sortByTeamCode
        case .name: sortByName
        case .completion: sortByCompletion
        }
    }

    static func sortLabel(for order: StickerGroupSortOrder) -> String {
        switch order {
        case .albumPage: sortByAlbumPage
        case .teamCode: sortByTeamCode
        case .name: sortByName
        }
    }

    static func sortLabel(for order: ExchangeSortOrder) -> String {
        switch order {
        case .albumPage: sortByAlbumPage
        case .teamCode: sortByTeamCode
        case .name: sortByName
        case .quantity: sortByQuantity
        }
    }
    static let teamCelebrationTitle = String(localized: "teams.celebration.title")
    static func teamCelebrationProgress(_ owned: Int, _ total: Int) -> String {
        String(localized: "teams.celebration.progress \(owned) \(total)")
    }
    static let teamCelebrationDismiss = String(localized: "teams.celebration.dismiss")
    static func teamProgressLabel(_ owned: Int, _ total: Int) -> String {
        let percent = total > 0 ? Int((Double(owned) / Double(total)) * 100) : 0
        return String(localized: "teams.progress.label \(owned) \(total) \(percent)")
    }
    static func weAreTeam(_ teamName: String) -> String {
        String(localized: "teams.weAreTitle \(teamName)")
    }
    static let teamPageLock = String(localized: "teams.page.lock")
    static let teamPageUnlock = String(localized: "teams.page.unlock")
    static let teamPageLocked = String(localized: "teams.page.locked")
    static let teamPickerTitle = String(localized: "teams.picker.title")
    static func teamPickerOpen(_ code: String) -> String {
        String(localized: "teams.picker.open \(code)")
    }
    static let teamPagerSwipeHint = String(localized: "teams.pager.swipeHint")
    static let teamPagerDismissHint = String(localized: "teams.pager.dismissHint")
    static func teamPagerPrevious(teamName: String, teamCode: String) -> String {
        String(localized: "teams.pager.previous \(teamName) \(teamCode)")
    }
    static func teamPagerNext(teamName: String, teamCode: String) -> String {
        String(localized: "teams.pager.next \(teamName) \(teamCode)")
    }

    // MARK: - Exchange

    static let noDuplicatesYet = String(localized: "exchange.noDuplicates")
    static let exchangeAddCopy = String(localized: "exchange.addCopy")
    static let exchangeAddCopyRecent = String(localized: "exchange.addCopy.recent")
    static let exchangeAddCopySearchPlaceholder = String(localized: "exchange.addCopySearchPlaceholder")
    static let exchangeAddCopySort = String(localized: "exchange.addCopy.sort")
    static let exchangeDockRemove = String(localized: "exchange.dock.remove")
    static let exchangeDragHint = String(localized: "exchange.dragHint")
    static let exchangeSort = String(localized: "exchange.sort")
    static let exchangeShare = String(localized: "exchange.share")
    static func exchangeShareTradingHeadlineLine1(_ count: Int) -> String {
        if count == 1 {
            String(localized: "exchange.share.tradingHeadlineSingular")
        } else {
            String(localized: "exchange.share.tradingHeadlinePlural")
        }
    }
    static let exchangeShareTradingHeadlineLine2 = String(localized: "exchange.share.tradingHeadlineLine2")
    static func exchangeShareSheetHeadline(_ count: Int) -> String {
        String(localized: "exchange.share.sheetHeadline \(count)")
    }
    static let exchangeShareShowListPreview = String(localized: "exchange.share.showListPreview")
    static let exchangeShareCTA = String(localized: "exchange.share.cta")
    static func exchangeShareQuantity(_ count: Int) -> String {
        String(localized: "exchange.share.quantity \(count)")
    }
    static func exchangeShareOverflowCopies(_ count: Int) -> String {
        String(localized: "exchange.share.overflowCopies \(count)")
    }
    static let exchangeShareAttribution = String(localized: "exchange.share.attribution")
    static let exchangeShareWhatsAppHeader = String(localized: "exchange.share.whatsappHeader")
    static let exchangeShareStory = String(localized: "exchange.share.story")
    static let exchangeShareSquare = String(localized: "exchange.share.square")
    static func exchangeInsight(_ copies: Int, _ uniqueStickers: Int, _ shiny: Int) -> String {
        String(localized: "exchange.insight \(copies) \(shiny)")
    }
    static func exchangeShareTotal(_ count: Int) -> String {
        String(localized: "exchange.share.total \(count)")
    }
    static let exchangeSearchPlaceholder = String(localized: "exchange.searchPlaceholder")
    static func exchangeFilterTeamChip(_ code: String, _ count: Int) -> String {
        String(localized: "exchange.filter.teamChip \(code) \(count)")
    }
    static let exchangeShareCopied = String(localized: "exchange.share.copied")
    static let exchangeDockMore = String(localized: "exchange.dock.more")
    static let exchangeFilterAll = String(localized: "exchange.filter.all")
    static let exchangeFilterShiny = String(localized: "exchange.filter.shiny")
    static let exchangeFilterTwoOrMore = String(localized: "exchange.filter.twoOrMore")
    static let exchangeCopyTextList = String(localized: "exchange.copy.textList")

    // MARK: - Sticker status

    static let statusMissing = String(localized: "status.missing")
    static let statusOwned = String(localized: "status.owned")
    static func statusDuplicate(_ count: Int) -> String {
        String(localized: "status.duplicate \(count)")
    }
    static func statusOwnedWithDuplicates(_ count: Int) -> String {
        String(localized: "status.ownedWithDuplicates \(count)")
    }

    // MARK: - Actions

    static let toggleOwned = String(localized: "action.toggleOwned")
    static let addDuplicate = String(localized: "action.addDuplicate")
    static let removeDuplicate = String(localized: "action.removeDuplicate")
    static let addDuplicateShort = String(localized: "action.addDuplicateShort")
    static let removeDuplicateShort = String(localized: "action.removeDuplicateShort")

    // MARK: - Album sections

    static let sectionLogo = String(localized: "section.logo")
    static let sectionTournament = String(localized: "section.tournament")
    static let sectionHosts = String(localized: "section.hosts")
    static let sectionHistory = String(localized: "section.history")
    static let sectionNational = String(localized: "section.national")

    // MARK: - Album pages

    static func albumPage(_ page: Int) -> String {
        String(localized: "album.page \(page)")
    }
    static func albumPageRange(from: Int, to: Int) -> String {
        String(localized: "album.pageRange \(from) \(to)")
    }
}
