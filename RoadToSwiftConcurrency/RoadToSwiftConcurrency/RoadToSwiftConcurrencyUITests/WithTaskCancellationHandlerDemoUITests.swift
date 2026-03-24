//
//  WithTaskCancellationHandlerDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies withTaskCancellationHandler demo: cleanup on cancel, completed path.
//

import XCTest

final class WithTaskCancellationHandlerDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWithTaskCancellationHandlerInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.withTaskCancellationHandlerDemo"].tap()

        XCTAssertTrue(app.staticTexts["withTaskCancellationHandler.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["withTaskCancellationHandler.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["withTaskCancellationHandler.cleanup"].label, "Cleanup: —")
        XCTAssertEqual(app.staticTexts["withTaskCancellationHandler.progress"].label, "0 / 10")
    }

    @MainActor
    func testWithTaskCancellationHandlerRunsToCompleted() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.withTaskCancellationHandlerDemo"].tap()

        app.buttons["withTaskCancellationHandler.start"].tap()

        let statusLabel = app.staticTexts["withTaskCancellationHandler.status"]
        let completed = NSPredicate(format: "label == 'Completed'")
        let expectation = XCTNSPredicateExpectation(predicate: completed, object: statusLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 6)
        XCTAssertEqual(result, .completed, "Work should finish with status Completed")

        XCTAssertEqual(app.staticTexts["withTaskCancellationHandler.cleanup"].label, "Cleanup: —")
    }

    @MainActor
    func testWithTaskCancellationHandlerCancelShowsCleanup() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.withTaskCancellationHandlerDemo"].tap()

        app.buttons["withTaskCancellationHandler.start"].tap()
        app.buttons["withTaskCancellationHandler.cancel"].tap()

        let statusLabel = app.staticTexts["withTaskCancellationHandler.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        let statusExpectation = XCTNSPredicateExpectation(predicate: cancelled, object: statusLabel)
        let statusResult = XCTWaiter.wait(for: [statusExpectation], timeout: 3)
        XCTAssertEqual(statusResult, .completed, "After cancel, status should be Cancelled")

        let cleanupLabel = app.staticTexts["withTaskCancellationHandler.cleanup"]
        let cleanupRan = NSPredicate(format: "label == 'Cleanup: ran'")
        let cleanupExpectation = XCTNSPredicateExpectation(predicate: cleanupRan, object: cleanupLabel)
        let cleanupResult = XCTWaiter.wait(for: [cleanupExpectation], timeout: 3)
        XCTAssertEqual(cleanupResult, .completed, "onCancel should set cleanup label")
    }
}
