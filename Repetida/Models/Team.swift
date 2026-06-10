import Foundation

struct Team: Identifiable, Hashable, Codable {
    let id: String
    let code: String
    let name: String
    let albumPages: [Int]
    let section: AlbumSection

    var displayAlbumPages: [Int] {
        albumPages.filter { $0 > 0 }
    }

    var albumPagesLabel: String {
        let pages = displayAlbumPages
        guard let first = pages.first else { return "" }
        if pages.count == 1 {
            return L10n.albumPage(first)
        }
        if let last = pages.last, last == first + pages.count - 1 {
            return L10n.albumPageRange(from: first, to: last)
        }
        return pages.map { L10n.albumPage($0) }.joined(separator: ", ")
    }

    /// Album page headline — e.g. "We Are Brazil" for national teams.
    var weAreTitle: String {
        if name.hasPrefix("We Are ") { return name }
        if section == .national {
            return L10n.weAreTeam(name)
        }
        return name
    }
}

struct TeamsManifest: Codable {
    let teams: [Team]
}
