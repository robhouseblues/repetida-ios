import Foundation

enum TeamSortOrder: String, CaseIterable, Identifiable {
    case albumPage
    case teamCode
    case name
    case completion

    var id: String { rawValue }
}

extension Team {
    var firstAlbumPage: Int {
        albumPages.min() ?? Int.max
    }

    static func compareByFifaCode(_ lhs: Team, _ rhs: Team) -> Bool {
        let codeCompare = lhs.code.localizedCaseInsensitiveCompare(rhs.code)
        if codeCompare != .orderedSame {
            return codeCompare == .orderedAscending
        }
        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    static func sorted(
        _ teams: [Team],
        by order: TeamSortOrder,
        completionFraction: ((Team) -> Double)? = nil
    ) -> [Team] {
        switch order {
        case .albumPage:
            return teams.sorted { $0.firstAlbumPage < $1.firstAlbumPage }
        case .teamCode:
            return teams.sorted { compareByFifaCode($0, $1) }
        case .name:
            return teams.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .completion:
            guard let completionFraction else {
                return sorted(teams, by: .albumPage)
            }
            return teams.sorted { lhs, rhs in
                let left = completionFraction(lhs)
                let right = completionFraction(rhs)
                if left != right { return left > right }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }
}
