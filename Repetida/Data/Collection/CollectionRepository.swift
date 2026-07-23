import Foundation

protocol CollectionRepository: AnyObject {
    /// Bumped on every mutation so screens can refresh derived caches without rescanning in `body`.
    var changeToken: Int { get }

    func status(for code: String) -> StickerStatus
    func setOwned(_ owned: Bool, for code: String)
    func adjustDuplicates(by delta: Int, for code: String)
    func setTeamOwned(_ owned: Bool, teamId: String)
    func ownedStickers() -> [StickerEntry]
    func duplicateStickers() -> [StickerEntry]
    func progress(for teamId: String) -> TeamProgress
    func albumProgress() -> AlbumProgress
    func teamsCompletionProgress(for section: AlbumSection) -> TeamsCompletionProgress
    func recentActivities(limit: Int) -> [RecentActivity]
}
