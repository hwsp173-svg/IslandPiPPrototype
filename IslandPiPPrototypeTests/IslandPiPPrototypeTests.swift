import XCTest
@testable import IslandPiPPrototype

@MainActor
final class IslandPiPPrototypeTests: XCTestCase {
    func testDemoFactoryHasUsableTitles() { for kind in DemoKind.allCases { XCTAssertFalse(DemoFactory.content(for: kind).title.isEmpty) } }
    func testTimerCalculationClampsAtZero() { XCTAssertEqual(TimerMath.remaining(total: 10, startedAt: Date(timeIntervalSince1970: 0), now: Date(timeIntervalSince1970: 20)), 0) }
    func testTimerProgressBounds() { XCTAssertEqual(TimerMath.progress(total: 10, remaining: 15), 0); XCTAssertEqual(TimerMath.progress(total: 10, remaining: -2), 1) }
    func testIslandTransitions() { let island = IslandController(); XCTAssertEqual(island.mode, .collapsed); island.setMode(.expanded); XCTAssertEqual(island.mode, .expanded); island.collapse(); XCTAssertEqual(island.mode, .collapsed) }
    func testAutomaticCollapse() async throws { let island = IslandController(); island.settings.autoCollapse = 0.05; island.setMode(.expanded); try await Task.sleep(for: .milliseconds(120)); XCTAssertEqual(island.mode, .collapsed) }
}
