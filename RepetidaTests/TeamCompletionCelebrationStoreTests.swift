import XCTest
@testable import Repetida

final class TeamCompletionCelebrationStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        TeamCompletionCelebrationStore.resetAll()
    }

    override func tearDown() {
        TeamCompletionCelebrationStore.resetAll()
        super.tearDown()
    }

    func testShowsOnceUntilCleared() {
        XCTAssertTrue(TeamCompletionCelebrationStore.shouldShow(for: "arg"))
        TeamCompletionCelebrationStore.markShown(for: "arg")
        XCTAssertFalse(TeamCompletionCelebrationStore.shouldShow(for: "arg"))
        TeamCompletionCelebrationStore.clear(for: "arg")
        XCTAssertTrue(TeamCompletionCelebrationStore.shouldShow(for: "arg"))
    }
}
