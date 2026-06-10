import XCTest
@testable import Repetida

final class TeamFlagEmojiTests: XCTestCase {
    func testAllNationalTeamsHaveFlagEmoji() {
        let repo = CatalogRepository(bundle: Bundle(for: TeamFlagEmojiTests.self))
        let nationalTeams = repo.teams.filter { $0.section == .national }

        XCTAssertEqual(nationalTeams.count, 48)

        for team in nationalTeams {
            XCTAssertNotNil(
                team.flagEmoji,
                "Expected flag emoji for national team \(team.code)"
            )
        }
    }

    func testMetaTeamsHaveNoFlagEmoji() {
        let repo = CatalogRepository(bundle: Bundle(for: TeamFlagEmojiTests.self))
        let metaTeams = repo.teams.filter { $0.section != .national }

        XCTAssertEqual(metaTeams.count, 4)

        for team in metaTeams {
            XCTAssertNil(team.flagEmoji, "Meta team \(team.code) should not have a flag")
            XCTAssertEqual(team.flaggedName, team.name)
        }
    }

    func testEdgeCaseFlags() {
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "USA"), "🇺🇸")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "MEX"), "🇲🇽")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "BRA"), "🇧🇷")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "KOR"), "🇰🇷")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "TUR"), "🇹🇷")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "CUW"), "🇨🇼")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "CIV"), "🇨🇮")
        XCTAssertEqual(TeamFlagEmoji.emoji(forFIFACode: "COD"), "🇨🇩")
        XCTAssertNotNil(TeamFlagEmoji.emoji(forFIFACode: "ENG"))
        XCTAssertNotNil(TeamFlagEmoji.emoji(forFIFACode: "SCO"))
    }
}
