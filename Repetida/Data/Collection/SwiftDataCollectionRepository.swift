import Foundation
import SwiftData

private enum DuplicateCopyMigration {
    static let completedKey = "duplicateCopiesMigrated"
    static let envelopesRemovedKey = "envelopesRemovedV2"
}

@Observable
final class SwiftDataCollectionRepository: CollectionRepository {
    private(set) var changeToken = 0

    private let modelContext: ModelContext
    private let catalog: CatalogRepository
    private var entryCache: [String: StickerEntry] = [:]
    private var copyCache: [UUID: DuplicateCopy] = [:]
    private var copiesByCode: [String: [DuplicateCopy]] = [:]
    private var nextCopySortIndex = 0
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
        let copies = (try? modelContext.fetch(copyDescriptor)) ?? []
        copyCache = copies.reduce(into: [:]) { $0[$1.id] = $1 }
        rebuildCopiesIndex(from: copies)

        let collectionDescriptor = FetchDescriptor<TradeCollection>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.name)]
        )
        collectionCache = (try? modelContext.fetch(collectionDescriptor))?
            .reduce(into: [:]) { $0[$1.id] = $1 } ?? [:]

        let activityDescriptor = FetchDescriptor<CollectionActivity>()
        activityCache = (try? modelContext.fetch(activityDescriptor))?
            .reduce(into: [:]) { $0[$1.id] = $1 } ?? [:]
    }

    private func rebuildCopiesIndex(from copies: [DuplicateCopy]) {
        copiesByCode = Dictionary(grouping: copies, by: \.stickerCode)
            .mapValues { $0.sorted { $0.createdAt < $1.createdAt } }
        nextCopySortIndex = (copies.map(\.sortIndex).max() ?? -1) + 1
    }

    private func noteMutation() {
        changeToken &+= 1
    }

    private func logActivity(stickerCode: String, kind: RecentUpdateKind, saveImmediately: Bool = true) {
        let activity = CollectionActivity(stickerCode: stickerCode, kind: kind)
        modelContext.insert(activity)
        activityCache[activity.id] = activity
        if saveImmediately {
            save()
        }
    }

    private func inferActivityKind(for entry: StickerEntry) -> RecentUpdateKind {
        let duplicateCount = entry.duplicateCount
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

        rebuildCopiesIndex(from: Array(copyCache.values))
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
        copiesByCode[code] ?? []
    }

    private func insertCopy(_ copy: DuplicateCopy) {
        copyCache[copy.id] = copy
        var list = copiesByCode[copy.stickerCode] ?? []
        list.append(copy)
        list.sort { $0.createdAt < $1.createdAt }
        copiesByCode[copy.stickerCode] = list
    }

    private func removeCopyFromIndex(_ copy: DuplicateCopy) {
        guard var list = copiesByCode[copy.stickerCode] else { return }
        list.removeAll { $0.id == copy.id }
        if list.isEmpty {
            copiesByCode.removeValue(forKey: copy.stickerCode)
        } else {
            copiesByCode[copy.stickerCode] = list
        }
    }

    private func syncDuplicateCount(for code: String, saveImmediately: Bool = true) {
        let count = copies(for: code).count
        let entry = fetchOrCreate(code: code)
        entry.duplicateCount = count
        entry.updatedAt = .now
        if saveImmediately {
            save()
        }
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
        let dupeCount = entry.duplicateCount
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
        noteMutation()
        publishAlbumCompletionIfNeeded(wasComplete: wasAlbumComplete)
    }

    func adjustDuplicates(by delta: Int, for code: String) {
        if delta > 0 {
            for _ in 0..<delta {
                addDuplicateCopy(for: code)
            }
            syncDuplicateCount(for: code, saveImmediately: false)
            save()
            noteMutation()
        } else if delta < 0 {
            let removable = Array(copies(for: code).suffix(min(-delta, copies(for: code).count)))
            for copy in removable {
                removeDuplicateCopy(copy.id, logRemoval: true, saveImmediately: false)
            }
            syncDuplicateCount(for: code, saveImmediately: false)
            save()
            noteMutation()
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
        noteMutation()
        publishAlbumCompletionIfNeeded(wasComplete: wasAlbumComplete)
    }

    func ownedStickers() -> [StickerEntry] {
        entryCache.values.filter(\.isOwned).sorted { $0.updatedAt > $1.updatedAt }
    }

    func duplicateStickers() -> [StickerEntry] {
        copiesByCode.keys.compactMap { entryCache[$0] }
            .sorted { $0.code < $1.code }
    }

    func progress(for teamId: String) -> TeamProgress {
        let stickers = catalog.stickers(forTeamId: teamId)
        let owned = stickers.filter { entryCache[$0.code]?.isOwned == true }.count
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
        let owned = catalog.allStickers.reduce(0) { partial, sticker in
            partial + (entryCache[sticker.code]?.isOwned == true ? 1 : 0)
        }
        return AlbumProgress(
            owned: owned,
            total: total,
            missing: total - owned,
            duplicateCount: copyCache.count
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
            sortIndex: nextCopySortIndex
        )
        nextCopySortIndex += 1
        modelContext.insert(copy)
        insertCopy(copy)
        logActivity(stickerCode: code, kind: .duplicateAdded, saveImmediately: false)
    }

    private func removeDuplicateCopy(
        _ copyId: UUID,
        logRemoval: Bool = true,
        saveImmediately: Bool = true
    ) {
        guard let copy = copyCache.removeValue(forKey: copyId) else { return }
        removeCopyFromIndex(copy)
        modelContext.delete(copy)
        if logRemoval {
            logActivity(stickerCode: copy.stickerCode, kind: .duplicateRemoved, saveImmediately: false)
        }
        if saveImmediately {
            syncDuplicateCount(for: copy.stickerCode, saveImmediately: false)
            save()
            noteMutation()
        }
    }
}
