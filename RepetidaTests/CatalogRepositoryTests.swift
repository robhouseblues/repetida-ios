import XCTest
@testable import Repetida

final class CatalogRepositoryTests: XCTestCase {
    func testSearchFindsStickerByCode() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let results = repo.search(query: "mex13")
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.sticker.code, "MEX13")
    }

    func testTeamLookupByAlbumPage() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let team = repo.team(forAlbumPage: 8)
        XCTAssertEqual(team?.code, "MEX")
        XCTAssertEqual(team?.albumPages, [8, 9])
    }

    func testPaniniSortsFirstByAlbumPage() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let panini = repo.teams.first { $0.id == "panini" }
        XCTAssertEqual(panini?.firstAlbumPage, 0)
        XCTAssertEqual(repo.team(forAlbumPage: 0)?.code, "LOGO")

        let ordered = repo.teams.map(\.firstAlbumPage)
        XCTAssertEqual(ordered.first, 0)
    }

    func testLoadedCatalogHas980Stickers() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        XCTAssertEqual(repo.allStickers.count, 980)
        XCTAssertEqual(repo.teams.count, 52)
    }

    func testTeamsGroupedByAlbumPage() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let national = repo.teamsGroupedBySection(sortBy: .albumPage)
            .first { $0.section == .national }?.teams ?? []
        let pages = national.map(\.firstAlbumPage)
        XCTAssertEqual(pages, pages.sorted())
    }

    func testTeamsGroupedByName() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let national = repo.teamsGroupedBySection(sortBy: .name)
            .first { $0.section == .national }?.teams ?? []
        let names = national.map(\.name)
        XCTAssertEqual(names, names.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
    }

    func testTeamsSortedByCompletionDescendingWithinSection() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let sampleTeams = Array(repo.teams.filter { $0.section == .national }.prefix(5))
        let fractions = Dictionary(uniqueKeysWithValues: sampleTeams.enumerated().map { index, team in
            (team.id, Double(index) / Double(sampleTeams.count))
        })

        let sorted = Team.sorted(sampleTeams, by: .completion) { fractions[$0.id] ?? 0 }
        let resultFractions = sorted.map { fractions[$0.id]! }
        XCTAssertEqual(resultFractions, resultFractions.sorted(by: >))
    }

    func testTeamsGroupedByCompletionWithinEachSection() {
        let repo = CatalogRepository(bundle: Bundle(for: CatalogRepositoryTests.self))
        let fractions = Dictionary(uniqueKeysWithValues: repo.teams.enumerated().map { index, team in
            (team.id, Double(index % 10) / 10.0)
        })

        let grouped = repo.teamsGroupedBySection(sortBy: .completion) { fractions[$0.id] ?? 0 }
        for group in grouped {
            let sectionFractions = group.teams.map { fractions[$0.id]! }
            XCTAssertEqual(sectionFractions, sectionFractions.sorted(by: >))
        }
    }
}
