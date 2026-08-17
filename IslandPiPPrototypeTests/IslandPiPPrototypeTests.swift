import XCTest
@testable import IslandPiPPrototype

@MainActor
final class IslandPiPPrototypeTests: XCTestCase {
    func testDemoFactoryHasUsableTitles() {
        for kind in IslandContentKind.allCases {
            XCTAssertFalse(IslandDemoFactory.content(for: kind).title.isEmpty)
        }
    }

    func testTimerCalculationClampsAtZero() {
        XCTAssertEqual(
            TimerMath.remaining(total: 10, startedAt: Date(timeIntervalSince1970: 0), now: Date(timeIntervalSince1970: 20)),
            0
        )
    }

    func testTimerProgressBounds() {
        XCTAssertEqual(TimerMath.progress(total: 10, remaining: 15), 0)
        XCTAssertEqual(TimerMath.progress(total: 10, remaining: -2), 1)
    }

    func testIslandTransitions() {
        let island = IslandState()
        XCTAssertEqual(island.mode, .collapsed)
        island.setMode(.expanded)
        XCTAssertEqual(island.mode, .expanded)
        island.collapse()
        XCTAssertEqual(island.mode, .collapsed)
    }

    func testBrowserStateLooksLikeURL() {
        let state = BrowserState()
        // Calling navigate should set showingHome to false for URL-like input
        state.navigate(to: "google.com")
        XCTAssertFalse(state.showingHome)
    }

    func testBrowserStateSearch() {
        let state = BrowserState()
        state.searchEngine = .google
        // Non-URL input triggers a search
        state.navigate(to: "swift programming")
        XCTAssertFalse(state.showingHome)
    }
}
