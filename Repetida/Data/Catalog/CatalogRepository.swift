import Foundation

@Observable
final class CatalogRepository {
    private(set) var teams: [Team] = []
    private(set) var allStickers: [NormalizedSticker] = []

    private var stickerByCode: [String: NormalizedSticker] = [:]
    private var teamById: [String: Team] = [:]
    private var teamByCode: [String: Team] = [:]
    private var stickersByTeamId: [String: [NormalizedSticker]] = [:]
    private var teamByAlbumPage: [Int: Team] = [:]
    private var searchIndex: [SearchRecord] = []

    struct SearchRecord {
        let sticker: NormalizedSticker
        let team: Team
        let searchableText: String
    }

    init(bundle: Bundle = .main) {
        load(from: bundle)
    }

    private func load(from bundle: Bundle) {
        guard
            let catalogURL = bundle.url(forResource: "panini-wc-2026-catalog", withExtension: "json"),
            let teamsURL = bundle.url(forResource: "teams", withExtension: "json"),
            let catalogData = try? Data(contentsOf: catalogURL),
            let teamsData = try? Data(contentsOf: teamsURL),
            let catalog = try? JSONDecoder().decode(RawCatalog.self, from: catalogData),
            let manifest = try? JSONDecoder().decode(TeamsManifest.self, from: teamsData),
            let result = try? CatalogNormalizer.normalize(catalog: catalog, teamsManifest: manifest)
        else {
            return
        }

        teams = result.teams
        allStickers = result.stickers

        stickerByCode = Dictionary(uniqueKeysWithValues: allStickers.map { ($0.code, $0) })
        teamById = Dictionary(uniqueKeysWithValues: teams.map { ($0.id, $0) })
        teamByCode = Dictionary(uniqueKeysWithValues: teams.map { ($0.code, $0) })

        stickersByTeamId = Dictionary(grouping: allStickers, by: \.teamId)
        for team in teams {
            for page in team.albumPages where page >= 0 {
                teamByAlbumPage[page] = team
            }
        }

        searchIndex = allStickers.compactMap { sticker in
            guard let team = teamById[sticker.teamId] else { return nil }
            let text = [
                sticker.code,
                sticker.name,
                team.name,
                team.code,
            ].joined(separator: " ").lowercased()
            return SearchRecord(sticker: sticker, team: team, searchableText: text)
        }
    }

    func sticker(forCode code: String) -> NormalizedSticker? {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines)
        return stickerByCode[normalized]
            ?? stickerByCode[normalized.uppercased()]
            ?? stickerByCode.first { $0.key.caseInsensitiveCompare(normalized) == .orderedSame }?.value
    }

    func team(forId id: String) -> Team? {
        teamById[id]
    }

    func team(forCode code: String) -> Team? {
        teamByCode[code.uppercased()]
    }

    func team(forAlbumPage page: Int) -> Team? {
        teamByAlbumPage[page]
    }

    func stickers(forTeamId teamId: String) -> [NormalizedSticker] {
        stickersByTeamId[teamId] ?? []
    }

    func team(for sticker: NormalizedSticker) -> Team? {
        teamById[sticker.teamId]
    }

    func search(query: String) -> [(sticker: NormalizedSticker, team: Team)] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return searchIndex
            .filter { $0.searchableText.contains(trimmed) }
            .prefix(50)
            .map { ($0.sticker, $0.team) }
    }

    func teamsGroupedBySection(
        sortBy order: TeamSortOrder = .albumPage,
        completionFraction: ((Team) -> Double)? = nil
    ) -> [(section: AlbumSection, teams: [Team])] {
        AlbumSection.allCases.compactMap { section in
            let sectionTeams = Team.sorted(
                teams.filter { $0.section == section },
                by: order,
                completionFraction: completionFraction
            )
            guard !sectionTeams.isEmpty else { return nil }
            return (section, sectionTeams)
        }
    }

    func teamsInListOrder(
        sortBy order: TeamSortOrder = .albumPage,
        completionFraction: ((Team) -> Double)? = nil
    ) -> [Team] {
        teamsGroupedBySection(sortBy: order, completionFraction: completionFraction).flatMap(\.teams)
    }
}
