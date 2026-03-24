//
//  TaskPriorityDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies TaskPriority demo: two priority loops complete or cancel.
//

import XCTest

final class TaskPriorityDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTaskPriorityInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskPriorityDemo"].tap()

        XCTAssertTrue(app.staticTexts["taskPriority.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["taskPriority.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["taskPriority.highProgress"].label, "High: 0/8")
        XCTAssertEqual(app.staticTexts["taskPriority.lowProgress"].label, "Low: 0/8")
    }

    @MainActor
    func testTaskPriorityBothDone() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskPriorityDemo"].tap()

        app.buttons["taskPriority.start"].tap()

        let status = app.staticTexts["taskPriority.status"]
        let high = app.staticTexts["taskPriority.highProgress"]
        let low = app.staticTexts["taskPriority.lowProgress"]

        let completed = NSPredicate(format: "label == 'Completed'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: completed, object: status)], timeout: 6),
            .completed
        )
        XCTAssertEqual(high.label, "High: Done")
        XCTAssertEqual(low.label, "Low: Done")
    }

    @MainActor
    func testTaskPriorityCancel() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskPriorityDemo"].tap()

        app.buttons["taskPriority.start"].tap()
        app.buttons["taskPriority.cancel"].tap()

        let status = app.staticTexts["taskPriority.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: cancelled, object: status)], timeout: 3),
            .completed
        )
    }
}
