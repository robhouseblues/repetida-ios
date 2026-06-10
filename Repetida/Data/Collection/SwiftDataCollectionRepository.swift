import Foundation
import SwiftData

private enum DuplicateCopyMigration {
    static let completedKey = "duplicateCopiesMigrated"
    static let envelopesRemovedKey = "envelopesRemovedV2"
}

@Observable
final class SwiftDataCollectionRepository: CollectionRepository {
    private let modelContext: ModelContext
    private let catalog: CatalogRepository
    private var entryCache: [String: StickerEntry] = [:]
    private var copyCache: [UUID: DuplicateCopy] = [:]
    private var collectionCache: [UUID: TradeCollection] = [:]
    private var activityCache: [UUID: CollectionActivity] = [:]

    init(modelContext: ModelContext, catalog: CatalogRepository) {
        self.modelContext = modelContext
        self.catalog = catalog
        reloadCache()
        migrateDuplicateCopiesIfNeeded()
        removeEnvelopesIfNeeded()
        backfillActivityLogIfNeeded()
    }

    private func reloadCache() {
        let entryDescriptor = FetchDescriptor<StickerEntry>()
        entryCache = (try? modelContext.fetch(entryDescriptor))?
            .reduce(into: [:]) { $0[$1.code] = $1 } ?? [:]

        let copyDescriptor = FetchDescriptor<DuplicateCopy>()
        copyCache = (try? modelContext.fetch(copyDescriptor))?
            .reduce(into: [:]) { $0[$1.id] = $1 } ?? [:]

        let collectionDescriptor = FetchDescriptor<TradeCollection>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.name)]
        )
        collectionCache = (try? modelContext.fetch(collectionDescriptor))?
            .reduce(into: [:]) { $0[$1.id] = $1 } ?? [:]

        let activityDescriptor = FetchDescriptor<CollectionActivity>()
        activityCache = (try? modelContext.fetch(activityDescriptor))?
            .reduce(into: [:]) { $0[$1.id] = $1 } ?? [:]
    }

    private func logActivity(stickerCode: String, kind: RecentUpdateKind) {
        let activity = CollectionActivity(stickerCode: stickerCode, kind: kind)
        modelContext.insert(activity)
        activityCache[activity.id] = activity
        save()
    }

    private func inferActivityKind(for entry: StickerEntry) -> RecentUpdateKind {
        let duplicateCount = copies(for: entry.code).count
        if duplicateCount > 0, !entry.isOwned {
            return .duplicateAdded
        }
        if entry.isOwned {
            return .markedOwned
        }
        return .markedMissing
    }

    private func backfillActivityLogIfNeeded() {
        guard activityCache.isEmpty, !entryCache.isEmpty else { return }

        for entry in entryCache.values {
            let activity = CollectionActivity(
                stickerCode: entry.code,
                kind: inferActivityKind(for: entry),
                createdAt: entry.updatedAt
            )
            modelContext.insert(activity)
            activityCache[activity.id] = activity
        }

        save()
    }

    private func migrateDuplicateCopiesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: DuplicateCopyMigration.completedKey) else { return }

        for entry in entryCache.values where entry.duplicateCount > 0 {
            for index in 0..<entry.duplicateCount {
                let copy = DuplicateCopy(stickerCode: entry.code, collectionId: nil, sortIndex: index)
                modelContext.insert(copy)
                copyCache[copy.id] = copy
            }
        }

        save()
        UserDefaults.standard.set(true, forKey: DuplicateCopyMigration.completedKey)
    }

    private func entry(for code: String) -> StickerEntry? {
        entryCache[code]
    }

    private func fetchOrCreate(code: String) -> StickerEntry {
        if let existing = entryCache[code] {
            return existing
        }
        let newEntry = StickerEntry(code: code)
        modelContext.insert(newEntry)
        entryCache[code] = newEntry
        return newEntry
    }

    private func save() {
        try? modelContext.save()
    }

    private func copies(for code: String) -> [DuplicateCopy] {
        copyCache.values
            .filter { $0.stickerCode == code }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private func syncDuplicateCount(for code: String) {
        let count = copies(for: code).count
        let entry = fetchOrCreate(code: code)
        entry.duplicateCount = count
        entry.updatedAt = .now
        save()
    }

    private func nextSortIndex() -> Int {
        (copyCache.values.map(\.sortIndex).max() ?? -1) + 1
    }

    private func removeEnvelopesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: DuplicateCopyMigration.envelopesRemovedKey) else { return }

        for copy in copyCache.values where copy.collectionId != nil {
            copy.collectionId = nil
        }

        for collection in collectionCache.values {
            modelContext.delete(collection)
        }
        collectionCache.removeAll()

        save()
        UserDefaults.standard.set(true, forKey: DuplicateCopyMigration.envelopesRemovedKey)
    }

    // MARK: - Core collection

    func status(for code: String) -> StickerStatus {
        guard let entry = entry(for: code) else { return .missing }
        let dupeCount = copies(for: code).count
        if entry.isOwned && dupeCount > 0 {
            return .ownedWithDuplicates(count: dupeCount)
        }
        if entry.isOwned { return .owned }
        if dupeCount > 0 { return .duplicate(count: dupeCount) }
        return .missing
    }

    func setOwned(_ owned: Bool, for code: String) {
        let wasAlbumComplete = isAlbumComplete
        let entry = fetchOrCreate(code: code)
        entry.isOwned = owned
        entry.updatedAt = .now
        logActivity(stickerCode: code, kind: owned ? .markedOwned : .markedMissing)
        save()
        publishAlbumCompletionIfNeeded(wasComplete: wasAlbumComplete)
    }

    func adjustDuplicates(by delta: Int, for code: String) {
        if delta > 0 {
            for _ in 0..<delta {
                addDuplicateCopy(for: code)
            }
        } else if delta < 0 {
            let toRemove = min(-delta, copies(for: code).count)
            let removable = copies(for: code).suffix(toRemove)
            for copy in removable {
                removeDuplicateCopy(copy.id)
            }
        }
    }

    func setTeamOwned(_ owned: Bool, teamId: String) {
        let wasAlbumComplete = isAlbumComplete
        for sticker in catalog.stickers(forTeamId: teamId) {
            let entry = fetchOrCreate(code: sticker.code)
            entry.isOwned = owned
            entry.updatedAt = .now
        }
        save()
        publishAlbumCompletionIfNeeded(wasComplete: wasAlbumComplete)
    }

    func ownedStickers() -> [StickerEntry] {
        entryCache.values.filter(\.isOwned).sorted { $0.updatedAt > $1.updatedAt }
    }

    func duplicateStickers() -> [StickerEntry] {
        let codesWithCopies = Set(copyCache.values.map(\.stickerCode))
        return codesWithCopies.compactMap { entryCache[$0] }
            .sorted { $0.code < $1.code }
    }

    func missingStickers() -> [NormalizedSticker] {
        catalog.allStickers
            .filter { !status(for: $0.code).isOwned }
            .sorted { $0.code < $1.code }
    }

    func progress(for teamId: String) -> TeamProgress {
        let stickers = catalog.stickers(forTeamId: teamId)
        let owned = stickers.filter { status(for: $0.code).isOwned }.count
        return TeamProgress(teamId: teamId, owned: owned, total: stickers.count)
    }

    private var isAlbumComplete: Bool {
        let progress = albumProgress()
        return progress.total > 0 && progress.owned >= progress.total
    }

    private func publishAlbumCompletionIfNeeded(wasComplete: Bool) {
        if !isAlbumComplete {
            AlbumCompletionCelebrationStore.clear()
            return
        }
        guard !wasComplete, AlbumCompletionCelebrationStore.shouldShow else { return }
        AlbumCompletionCelebrationStore.markShown()
        NotificationCenter.default.post(name: .albumDidComplete, object: nil)
    }

    func albumProgress() -> AlbumProgress {
        let total = catalog.allStickers.count
        let owned = catalog.allStickers.filter { status(for: $0.code).isOwned }.count
        let duplicateCount = copyCache.count
        return AlbumProgress(
            owned: owned,
            total: total,
            missing: total - owned,
            duplicateCount: duplicateCount
        )
    }

    func teamsCompletionProgress(for section: AlbumSection) -> TeamsCompletionProgress {
        let teams = catalog.teams.filter { $0.section == section }
        let completed = teams.filter { team in
            let progress = progress(for: team.id)
            return progress.total > 0 && progress.owned == progress.total
        }.count
        return TeamsCompletionProgress(completed: completed, total: teams.count)
    }

    func recentActivities(limit: Int) -> [RecentActivity] {
        if activityCache.isEmpty {
            backfillActivityLogIfNeeded()
        }

        return activityCache.values
            .filter { $0.kind != "traded" }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map {
                RecentActivity(
                    id: $0.id,
                    stickerCode: $0.stickerCode,
                    kind: $0.updateKind,
                    date: $0.createdAt
                )
            }
    }

    // MARK: - Duplicates

    private func addDuplicateCopy(for code: String) {
        let copy = DuplicateCopy(
            stickerCode: code,
            collectionId: nil,
            sortIndex: nextSortIndex()
        )
        modelContext.insert(copy)
        copyCache[copy.id] = copy
        logActivity(stickerCode: code, kind: .duplicateAdded)
        syncDuplicateCount(for: code)
    }

    private func removeDuplicateCopy(_ copyId: UUID, logRemoval: Bool = true) {
        guard let copy = copyCache.removeValue(forKey: copyId) else { return }
        modelContext.delete(copy)
        if logRemoval {
            logActivity(stickerCode: copy.stickerCode, kind: .duplicateRemoved)
        }
        syncDuplicateCount(for: copy.stickerCode)
        save()
    }
}
