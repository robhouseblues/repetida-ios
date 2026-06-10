import XCTest
@testable import Repetida

final class AlbumCompletionCelebrationStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AlbumCompletionCelebrationStore.reset()
    }

    override func tearDown() {
        AlbumCompletionCelebrationStore.reset()
        super.tearDown()
    }

    func testShowsOnceUntilCleared() {
        XCTAssertTrue(AlbumCompletionCelebrationStore.shouldShow)
        AlbumCompletionCelebrationStore.markShown()
        XCTAssertFalse(AlbumCompletionCelebrationStore.shouldShow)
        AlbumCompletionCelebrationStore.clear()
        XCTAssertTrue(AlbumCompletionCelebrationStore.shouldShow)
    }
}
