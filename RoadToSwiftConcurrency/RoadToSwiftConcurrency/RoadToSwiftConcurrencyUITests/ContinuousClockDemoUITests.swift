//
//  ContinuousClockDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies ContinuousClock demo: Task.sleep(for:clock:) + Completed / Cancelled.
//

import XCTest

final class ContinuousClockDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testContinuousClockInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.continuousClockDemo"].tap()

        XCTAssertTrue(app.staticTexts["continuousClock.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["continuousClock.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["continuousClock.progress"].label, "0 / 5")
        XCTAssertEqual(app.staticTexts["continuousClock.result"].label, "—")
    }

    @MainActor
    func testContinuousClockCompletes() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.continuousClockDemo"].tap()

        app.buttons["continuousClock.start"].tap()

        let status = app.staticTexts["continuousClock.status"]
        let progress = app.staticTexts["continuousClock.progress"]
        let result = app.staticTexts["continuousClock.result"]

        let completed = NSPredicate(format: "label == 'Completed'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: completed, object: status)], timeout: 8),
            .completed
        )
        XCTAssertEqual(progress.label, "5 / 5")
        XCTAssertTrue(result.label.hasPrefix("Elapsed:"), "Expected elapsed summary, got: \(result.label)")
    }

    @MainActor
    func testContinuousClockCancel() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.continuousClockDemo"].tap()

        app.buttons["continuousClock.start"].tap()
        app.buttons["continuousClock.cancel"].tap()

        let status = app.staticTexts["continuousClock.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: cancelled, object: status)], timeout: 3),
            .completed
        )
    }
}
