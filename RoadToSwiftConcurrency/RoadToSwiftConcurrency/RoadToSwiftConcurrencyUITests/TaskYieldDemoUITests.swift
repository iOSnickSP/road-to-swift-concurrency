//
//  TaskYieldDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies Task.yield demo: full run or cancel.
//

import XCTest

final class TaskYieldDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTaskYieldInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskYieldDemo"].tap()

        XCTAssertTrue(app.staticTexts["taskYield.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["taskYield.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["taskYield.progress"].label, "0 / 12")
    }

    @MainActor
    func testTaskYieldRunsToCompleted() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskYieldDemo"].tap()

        app.buttons["taskYield.start"].tap()

        let statusLabel = app.staticTexts["taskYield.status"]
        let completed = NSPredicate(format: "label == 'Completed'")
        let expectation = XCTNSPredicateExpectation(predicate: completed, object: statusLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Loop should finish with status Completed")
    }

    @MainActor
    func testTaskYieldCancel() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskYieldDemo"].tap()

        app.buttons["taskYield.start"].tap()
        app.buttons["taskYield.cancel"].tap()

        let statusLabel = app.staticTexts["taskYield.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        let expectation = XCTNSPredicateExpectation(predicate: cancelled, object: statusLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "After cancel, status should be Cancelled")
    }
}
