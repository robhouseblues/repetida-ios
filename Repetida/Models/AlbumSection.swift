import Foundation

enum AlbumSection: String, Codable, CaseIterable, Hashable {
    case logo
    case tournament
    case hosts
    case history
    case national

    var displayName: String {
        switch self {
        case .logo: return L10n.sectionLogo
        case .tournament: return L10n.sectionTournament
        case .hosts: return L10n.sectionHosts
        case .history: return L10n.sectionHistory
        case .national: return L10n.sectionNational
        }
    }

    var sortOrder: Int {
        switch self {
        case .logo: return 0
        case .tournament: return 1
        case .hosts: return 2
        case .history: return 3
        case .national: return 4
        }
    }
}
