//
//  TaskCancellationDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies Task cancellation demo: complete loop or cancel mid-flight.
//

import XCTest

final class TaskCancellationDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTaskCancellationInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskCancellationDemo"].tap()

        XCTAssertTrue(app.staticTexts["taskCancellation.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["taskCancellation.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["taskCancellation.progress"].label, "0 / 10")
    }

    @MainActor
    func testTaskCancellationRunsToCompleted() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskCancellationDemo"].tap()

        app.buttons["taskCancellation.start"].tap()

        let statusLabel = app.staticTexts["taskCancellation.status"]
        let completed = NSPredicate(format: "label == 'Completed'")
        let expectation = XCTNSPredicateExpectation(predicate: completed, object: statusLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Work should finish with status Completed")
    }

    @MainActor
    func testTaskCancellationCancel() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskCancellationDemo"].tap()

        app.buttons["taskCancellation.start"].tap()
        app.buttons["taskCancellation.cancel"].tap()

        let statusLabel = app.staticTexts["taskCancellation.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        let expectation = XCTNSPredicateExpectation(predicate: cancelled, object: statusLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "After cancel, status should be Cancelled")
    }
}
