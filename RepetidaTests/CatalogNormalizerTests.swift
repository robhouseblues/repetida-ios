import XCTest
@testable import Repetida

final class CatalogNormalizerTests: XCTestCase {
    private var catalog: RawCatalog!
    private var manifest: TeamsManifest!

    override func setUpWithError() throws {
        let bundle = Bundle(for: CatalogNormalizerTests.self)

        let catalogURL = try XCTUnwrap(bundle.url(forResource: "panini-wc-2026-catalog", withExtension: "json"))
        let teamsURL = try XCTUnwrap(bundle.url(forResource: "teams", withExtension: "json"))

        catalog = try JSONDecoder().decode(RawCatalog.self, from: Data(contentsOf: catalogURL))
        manifest = try JSONDecoder().decode(TeamsManifest.self, from: Data(contentsOf: teamsURL))
    }

    func testNormalizedStickerCountIs980() throws {
        let result = try CatalogNormalizer.normalize(catalog: catalog, teamsManifest: manifest)
        XCTAssertEqual(result.stickers.count, 980)
    }

    func testTeamCountIs52() throws {
        let result = try CatalogNormalizer.normalize(catalog: catalog, teamsManifest: manifest)
        XCTAssertEqual(result.teams.count, 52)
    }

    func testEveryTeamHasAlbumPages() throws {
        for team in manifest.teams {
            XCTAssertFalse(team.albumPages.isEmpty, "Team \(team.code) missing albumPages")
        }
    }

    func testMexicoStickerLinksToMexicoTeam() throws {
        let result = try CatalogNormalizer.normalize(catalog: catalog, teamsManifest: manifest)
        let mex13 = try XCTUnwrap(result.stickers.first { $0.code == "MEX13" })
        let mexico = try XCTUnwrap(result.teams.first { $0.id == "mex" })

        XCTAssertEqual(mex13.teamId, mexico.id)
        XCTAssertEqual(mexico.code, "MEX")
        XCTAssertEqual(mexico.name, "Mexico")
        XCTAssertEqual(mexico.albumPages, [8, 9])
    }

    func testParseTeamCode() {
        XCTAssertEqual(
            CatalogNormalizer.parseTeamCode(from: CatalogEntry(code: "MEX13", name: "Team Photo", team: "Mexico")),
            "MEX"
        )
        XCTAssertEqual(
            CatalogNormalizer.parseTeamCode(from: CatalogEntry(code: "00", name: "Panini Logo", team: "We Are Panini")),
            "PANINI"
        )
        XCTAssertEqual(
            CatalogNormalizer.parseTeamCode(from: CatalogEntry(code: "FWC1", name: "Official Emblem1", team: "FIFA World Cup 2026")),
            "FWC"
        )
    }

    func testInferKind() {
        XCTAssertEqual(
            CatalogNormalizer.inferKind(entry: CatalogEntry(code: "MEX1", name: "Emblem", team: "Mexico")),
            .badge
        )
        XCTAssertEqual(
            CatalogNormalizer.inferKind(entry: CatalogEntry(code: "MEX13", name: "Team Photo", team: "Mexico")),
            .teamPhoto
        )
        XCTAssertEqual(
            CatalogNormalizer.inferKind(entry: CatalogEntry(code: "FWC10", name: "Uruguay 1930", team: "FIFA World Cup History")),
            .legend
        )
    }

    func testEuropeanShinyVariantsExcluded() throws {
        let shinyCount = catalog.stickers.filter { $0.code.hasSuffix("s") }.count
        XCTAssertGreaterThan(shinyCount, 0)

        let result = try CatalogNormalizer.normalize(catalog: catalog, teamsManifest: manifest)
        XCTAssertFalse(result.stickers.contains { $0.code.hasSuffix("s") })
    }
}
