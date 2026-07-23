import Foundation

enum CatalogNormalizerError: Error, LocalizedError {
    case missingTeamForCode(String, rawTeam: String)
    case emptyAlbumPages(teamCode: String)

    var errorDescription: String? {
        switch self {
        case .missingTeamForCode(let code, let rawTeam):
            return "No team manifest entry for sticker \(code) (raw team: \(rawTeam))"
        case .emptyAlbumPages(let teamCode):
            return "Team \(teamCode) has empty albumPages"
        }
    }
}

struct CatalogNormalizer {
    private enum CatalogTeam {
        static let logo = "We Are Logo"
        static let tournamentSpecials = "Tournament Specials"
        static let hosts = "Host Countries and Cities"
        static let legends = "Tournament Legends"
    }

    static func normalize(
        catalog: RawCatalog,
        teamsManifest: TeamsManifest
    ) throws -> (teams: [Team], stickers: [NormalizedSticker]) {
        let teamByCode = Dictionary(uniqueKeysWithValues: teamsManifest.teams.map { ($0.code, $0) })
        let teamById = Dictionary(uniqueKeysWithValues: teamsManifest.teams.map { ($0.id, $0) })

        for team in teamsManifest.teams where team.albumPages.isEmpty {
            throw CatalogNormalizerError.emptyAlbumPages(teamCode: team.code)
        }

        var stickers: [NormalizedSticker] = []
        var referencedTeamIds = Set<String>()

        let filtered = catalog.stickers.enumerated().filter { !$0.element.code.hasSuffix("s") }

        for (sortIndex, entry) in filtered {
            let teamCode = parseTeamCode(from: entry)
            guard let team = teamByCode[teamCode] else {
                throw CatalogNormalizerError.missingTeamForCode(entry.code, rawTeam: entry.team)
            }

            let kind = inferKind(entry: entry)
            let isShiny = kind == .badge || kind == .special || kind == .legend

            stickers.append(NormalizedSticker(
                code: entry.code,
                name: entry.name,
                teamId: team.id,
                kind: kind,
                isShiny: isShiny,
                sortIndex: sortIndex
            ))
            referencedTeamIds.insert(team.id)
        }

        let teams = teamsManifest.teams
            .filter { referencedTeamIds.contains($0.id) }
            .sorted { lhs, rhs in
                if lhs.section.sortOrder != rhs.section.sortOrder {
                    return lhs.section.sortOrder < rhs.section.sortOrder
                }
                return lhs.firstAlbumPage < rhs.firstAlbumPage
            }

        _ = teamById
        return (teams, stickers)
    }

    static func parseTeamCode(from entry: CatalogEntry) -> String {
        if entry.code == "00" { return "LOGO" }
        if entry.team == CatalogTeam.logo { return "LOGO" }
        if entry.team == CatalogTeam.tournamentSpecials { return "FWC" }
        if entry.team == CatalogTeam.hosts { return "HOST" }
        if entry.team == CatalogTeam.legends { return "HIST" }

        let pattern = #"^([A-Z]{3})"#
        if let match = entry.code.range(of: pattern, options: .regularExpression) {
            return String(entry.code[match])
        }

        let alphaPrefix = entry.code.prefix(while: { $0.isLetter })
        return alphaPrefix.isEmpty ? entry.code : String(alphaPrefix)
    }

    static func inferKind(entry: CatalogEntry) -> StickerKind {
        if entry.team == CatalogTeam.logo
            || entry.team == CatalogTeam.tournamentSpecials
            || entry.team == CatalogTeam.hosts {
            return .special
        }
        if entry.team == CatalogTeam.legends { return .legend }
        if entry.name == "Team Photo" { return .teamPhoto }
        if entry.name == "Emblem" { return .badge }
        return .player
    }
}
