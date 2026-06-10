import Foundation

enum L10n {
    /// App copy is pt-BR only; force locale so English device settings still resolve strings.
    private static let appLocale = Locale(identifier: "pt-BR")

    // MARK: - Launch

    static let launchFailureTitle = String(localized: "launch.failure.title", locale: appLocale)
    static let launchFailureMessage = String(localized: "launch.failure.message", locale: appLocale)
    static let launchFailureRetry = String(localized: "launch.failure.retry", locale: appLocale)

    // MARK: - Tabs

    static let tabHome = String(localized: "tab.home", locale: appLocale)
    static let tabTeams = String(localized: "tab.teams", locale: appLocale)
    static let tabMissing = String(localized: "tab.missing", locale: appLocale)
    static let tabRepetidas = String(localized: "tab.repetidas", locale: appLocale)

    // MARK: - Home

    static let albumCompletion = String(localized: "home.albumCompletion", locale: appLocale)
    static let statMissing = String(localized: "home.stat.missing", locale: appLocale)
    static let statDuplicates = String(localized: "home.stat.duplicates", locale: appLocale)
    static let statTeamsCompleted = String(localized: "home.stat.teamsCompleted", locale: appLocale)
    static func statTeamsAccessibility(_ completed: Int, _ total: Int) -> String {
        String(localized: "home.stat.teamsAccessibility \(completed) \(total)", locale: appLocale)
    }
    static let recentlyUpdated = String(localized: "home.recentlyUpdated", locale: appLocale)
    static func recentActivityDescription(kind: RecentUpdateKind, date: Date) -> String {
        let action = recentActionPhrase(for: kind)
        let when = date.formatted(.relative(presentation: .named).locale(appLocale))
        return "\(action) · \(when)"
    }

    private static func recentActionPhrase(for kind: RecentUpdateKind) -> String {
        switch kind {
        case .markedOwned: return String(localized: "home.recent.addedToCollection", locale: appLocale)
        case .markedMissing: return String(localized: "home.recent.removedFromCollection", locale: appLocale)
        case .duplicateAdded: return String(localized: "home.recent.duplicateRegistered", locale: appLocale)
        case .duplicateRemoved: return String(localized: "home.recent.duplicateRemoved", locale: appLocale)
        }
    }
    static let homeClosestTeams = String(localized: "home.closestTeams", locale: appLocale)
    static func homeTeamFalta(_ count: Int) -> String {
        count == 1
            ? String(localized: "home.teamFaltaOne", locale: appLocale)
            : String(localized: "home.teamFaltam \(count)", locale: appLocale)
    }
    static let homeAlbumComplete = String(localized: "home.albumComplete", locale: appLocale)
    static let homeEmptyTitle = String(localized: "home.empty.title", locale: appLocale)
    static let homeEmptyMessage = String(localized: "home.empty.message", locale: appLocale)
    static let homeEmptyGoToMissing = String(localized: "home.empty.goToMissing", locale: appLocale)
    static func homeClosestTeamSubtitle(_ stickerCode: String, _ stickerName: String) -> String {
        String(localized: "home.closestTeamSubtitle \(stickerCode) \(stickerName)", locale: appLocale)
    }

    // MARK: - Missing

    static let missingTitle = String(localized: "missing.title", locale: appLocale)
    static let missingSearchPlaceholder = String(localized: "missing.searchPlaceholder", locale: appLocale)
    static let missingAllOwned = String(localized: "missing.allOwned", locale: appLocale)
    static let missingSortTitle = String(localized: "missing.sort.title", locale: appLocale)
    static let missingFilterAll = String(localized: "missing.filter.all", locale: appLocale)
    static func missingFilterTeamChip(_ code: String, _ count: Int) -> String {
        String(localized: "missing.filter.teamChip \(code) \(count)", locale: appLocale)
    }

    // MARK: - Lookup

    static let searchPlaceholder = String(localized: "lookup.searchPlaceholder", locale: appLocale)
    static let clearSearch = String(localized: "lookup.clearSearch", locale: appLocale)
    static let searchPrompt = String(localized: "lookup.searchPrompt", locale: appLocale)
    static let noStickersFound = String(localized: "lookup.noResults", locale: appLocale)

    // MARK: - Teams

    static let sortTeams = String(localized: "teams.sort.title", locale: appLocale)
    static let teamsSearchPlaceholder = String(localized: "teams.searchPlaceholder", locale: appLocale)
    static let sortByAlbumPage = String(localized: "teams.sort.albumPage", locale: appLocale)
    static let sortByTeamCode = String(localized: "teams.sort.teamCode", locale: appLocale)
    static let sortByName = String(localized: "teams.sort.name", locale: appLocale)
    static let sortByCompletion = String(localized: "teams.sort.completion", locale: appLocale)
    static let sortByQuantity = String(localized: "exchange.sort.quantity", locale: appLocale)

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
    static let teamCelebrationTitle = String(localized: "teams.celebration.title", locale: appLocale)
    static func teamCelebrationProgress(_ owned: Int, _ total: Int) -> String {
        String(localized: "teams.celebration.progress \(owned) \(total)", locale: appLocale)
    }
    static let teamCelebrationDismiss = String(localized: "teams.celebration.dismiss", locale: appLocale)
    static func teamProgressLabel(_ owned: Int, _ total: Int) -> String {
        let percent = total > 0 ? Int((Double(owned) / Double(total)) * 100) : 0
        return String(localized: "teams.progress.label \(owned) \(total) \(percent)", locale: appLocale)
    }
    static func weAreTeam(_ teamName: String) -> String {
        String(localized: "teams.weAreTitle \(teamName)", locale: appLocale)
    }
    static let teamPageLock = String(localized: "teams.page.lock", locale: appLocale)
    static let teamPageUnlock = String(localized: "teams.page.unlock", locale: appLocale)
    static let teamPageLocked = String(localized: "teams.page.locked", locale: appLocale)
    static let teamPickerTitle = String(localized: "teams.picker.title", locale: appLocale)
    static func teamPickerOpen(_ code: String) -> String {
        String(localized: "teams.picker.open \(code)", locale: appLocale)
    }
    static let teamPagerSwipeHint = String(localized: "teams.pager.swipeHint", locale: appLocale)
    static let teamPagerDismissHint = String(localized: "teams.pager.dismissHint", locale: appLocale)
    static func teamPagerPrevious(teamName: String, teamCode: String) -> String {
        String(localized: "teams.pager.previous \(teamName) \(teamCode)", locale: appLocale)
    }
    static func teamPagerNext(teamName: String, teamCode: String) -> String {
        String(localized: "teams.pager.next \(teamName) \(teamCode)", locale: appLocale)
    }

    // MARK: - Exchange

    static let noDuplicatesYet = String(localized: "exchange.noDuplicates", locale: appLocale)
    static let exchangeAddCopy = String(localized: "exchange.addCopy", locale: appLocale)
    static let exchangeAddCopyRecent = String(localized: "exchange.addCopy.recent", locale: appLocale)
    static let exchangeAddCopySearchPlaceholder = String(localized: "exchange.addCopySearchPlaceholder", locale: appLocale)
    static let exchangeAddCopySort = String(localized: "exchange.addCopy.sort", locale: appLocale)
    static let exchangeDockRemove = String(localized: "exchange.dock.remove", locale: appLocale)
    static let exchangeDragHint = String(localized: "exchange.dragHint", locale: appLocale)
    static let exchangeSort = String(localized: "exchange.sort", locale: appLocale)
    static let exchangeShare = String(localized: "exchange.share", locale: appLocale)
    static func exchangeShareTradingHeadlineLine1(_ count: Int) -> String {
        if count == 1 {
            String(localized: "exchange.share.tradingHeadlineSingular", locale: appLocale)
        } else {
            String(localized: "exchange.share.tradingHeadlinePlural", locale: appLocale)
        }
    }
    static let exchangeShareTradingHeadlineLine2 = String(localized: "exchange.share.tradingHeadlineLine2", locale: appLocale)
    static func exchangeShareSheetHeadline(_ count: Int) -> String {
        String(localized: "exchange.share.sheetHeadline \(count)", locale: appLocale)
    }
    static let exchangeShareShowListPreview = String(localized: "exchange.share.showListPreview", locale: appLocale)
    static let exchangeShareCTA = String(localized: "exchange.share.cta", locale: appLocale)
    static func exchangeShareQuantity(_ count: Int) -> String {
        String(localized: "exchange.share.quantity \(count)", locale: appLocale)
    }
    static func exchangeShareOverflowCopies(_ count: Int) -> String {
        String(localized: "exchange.share.overflowCopies \(count)", locale: appLocale)
    }
    static let exchangeShareAttribution = String(localized: "exchange.share.attribution", locale: appLocale)
    static let exchangeShareWhatsAppHeader = String(localized: "exchange.share.whatsappHeader", locale: appLocale)
    static let exchangeShareStory = String(localized: "exchange.share.story", locale: appLocale)
    static let exchangeShareSquare = String(localized: "exchange.share.square", locale: appLocale)
    static func exchangeInsight(_ copies: Int, _ uniqueStickers: Int, _ shiny: Int) -> String {
        String(localized: "exchange.insight \(copies) \(shiny)", locale: appLocale)
    }
    static func exchangeShareTotal(_ count: Int) -> String {
        String(localized: "exchange.share.total \(count)", locale: appLocale)
    }
    static let exchangeSearchPlaceholder = String(localized: "exchange.searchPlaceholder", locale: appLocale)
    static func exchangeFilterTeamChip(_ code: String, _ count: Int) -> String {
        String(localized: "exchange.filter.teamChip \(code) \(count)", locale: appLocale)
    }
    static let exchangeShareCopied = String(localized: "exchange.share.copied", locale: appLocale)
    static let exchangeDockMore = String(localized: "exchange.dock.more", locale: appLocale)
    static let exchangeFilterAll = String(localized: "exchange.filter.all", locale: appLocale)
    static let exchangeFilterShiny = String(localized: "exchange.filter.shiny", locale: appLocale)
    static let exchangeFilterTwoOrMore = String(localized: "exchange.filter.twoOrMore", locale: appLocale)
    static let exchangeCopyTextList = String(localized: "exchange.copy.textList", locale: appLocale)

    // MARK: - Sticker status

    static let statusMissing = String(localized: "status.missing", locale: appLocale)
    static let statusOwned = String(localized: "status.owned", locale: appLocale)
    static func statusDuplicate(_ count: Int) -> String {
        String(localized: "status.duplicate \(count)", locale: appLocale)
    }
    static func statusOwnedWithDuplicates(_ count: Int) -> String {
        String(localized: "status.ownedWithDuplicates \(count)", locale: appLocale)
    }

    // MARK: - Actions

    static let toggleOwned = String(localized: "action.toggleOwned", locale: appLocale)
    static let addDuplicate = String(localized: "action.addDuplicate", locale: appLocale)
    static let removeDuplicate = String(localized: "action.removeDuplicate", locale: appLocale)
    static let addDuplicateShort = String(localized: "action.addDuplicateShort", locale: appLocale)
    static let removeDuplicateShort = String(localized: "action.removeDuplicateShort", locale: appLocale)

    // MARK: - Album sections

    static let sectionPanini = String(localized: "section.panini", locale: appLocale)
    static let sectionTournament = String(localized: "section.tournament", locale: appLocale)
    static let sectionHosts = String(localized: "section.hosts", locale: appLocale)
    static let sectionHistory = String(localized: "section.history", locale: appLocale)
    static let sectionNational = String(localized: "section.national", locale: appLocale)

    // MARK: - Album pages

    static func albumPage(_ page: Int) -> String {
        String(localized: "album.page \(page)", locale: appLocale)
    }
    static func albumPageRange(from: Int, to: Int) -> String {
        String(localized: "album.pageRange \(from) \(to)", locale: appLocale)
    }
}
