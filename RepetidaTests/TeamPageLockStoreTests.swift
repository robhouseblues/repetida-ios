import XCTest
@testable import Repetida

final class TeamPageLockStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        TeamPageLockStore.resetAll()
    }

    override func tearDown() {
        TeamPageLockStore.resetAll()
        super.tearDown()
    }

    func testLockAndUnlock() {
        XCTAssertFalse(TeamPageLockStore.isLocked(teamId: "bra", in: ""))

        let locked = TeamPageLockStore.lock(teamId: "bra", in: "")
        XCTAssertTrue(TeamPageLockStore.isLocked(teamId: "bra", in: locked))
        XCTAssertEqual(locked, "bra")

        let unlocked = TeamPageLockStore.unlock(teamId: "bra", in: locked)
        XCTAssertFalse(TeamPageLockStore.isLocked(teamId: "bra", in: unlocked))
        XCTAssertEqual(unlocked, "")
    }

    func testToggle() {
        let locked = TeamPageLockStore.toggle(teamId: "arg", in: "")
        XCTAssertTrue(TeamPageLockStore.isLocked(teamId: "arg", in: locked))

        let unlocked = TeamPageLockStore.toggle(teamId: "arg", in: locked)
        XCTAssertFalse(TeamPageLockStore.isLocked(teamId: "arg", in: unlocked))
    }

    func testMultipleTeamsSortedSerialization() {
        let raw = TeamPageLockStore.lock(teamId: "usa", in: "")
        let raw2 = TeamPageLockStore.lock(teamId: "arg", in: raw)
        XCTAssertEqual(raw2, "arg,usa")
    }
}
