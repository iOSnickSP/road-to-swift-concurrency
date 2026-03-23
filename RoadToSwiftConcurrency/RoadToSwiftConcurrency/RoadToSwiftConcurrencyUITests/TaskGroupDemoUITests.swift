//
//  TaskGroupDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies TaskGroup: load 3 resources in parallel, show result.
//

import XCTest

final class TaskGroupDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTaskGroupDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskGroupDemo"].tap()

        let statusLabel = app.staticTexts["taskGroup.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Load All")
    }

    @MainActor
    func testTaskGroupLoadsAllResources() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.taskGroupDemo"].tap()

        let loadButton = app.buttons["taskGroup.loadAll"]
        let statusLabel = app.staticTexts["taskGroup.status"]
        let resultLabel = app.staticTexts["taskGroup.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        let doneResult = XCTWaiter.wait(for: [doneExpectation], timeout: 6)
        XCTAssertEqual(doneResult, .completed, "Status should be 'Done'")

        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("Resource 0"), "Result should contain Resource 0")
        XCTAssertTrue(resultText.contains("Resource 1"), "Result should contain Resource 1")
        XCTAssertTrue(resultText.contains("Resource 2"), "Result should contain Resource 2")
    }
}
