//
//  DispatchWorkItemDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies DispatchWorkItem: load 3 resources sequentially, cancel stops remaining.
//

import XCTest

final class DispatchWorkItemDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDispatchWorkItemDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchWorkItemDemo"].tap()

        let statusLabel = app.staticTexts["dispatchWorkItem.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Load")
    }

    @MainActor
    func testDispatchWorkItemLoadsAllResources() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchWorkItemDemo"].tap()

        let loadButton = app.buttons["dispatchWorkItem.load"]
        let statusLabel = app.staticTexts["dispatchWorkItem.status"]
        let resultLabel = app.staticTexts["dispatchWorkItem.result"]

        loadButton.tap()

        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [doneExpectation], timeout: 10), .completed)

        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("Resource 0"))
        XCTAssertTrue(resultText.contains("Resource 1"))
        XCTAssertTrue(resultText.contains("Resource 2"))
    }

    @MainActor
    func testDispatchWorkItemCancelStopsRemaining() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchWorkItemDemo"].tap()

        let loadButton = app.buttons["dispatchWorkItem.load"]
        let cancelButton = app.buttons["dispatchWorkItem.cancel"]
        let statusLabel = app.staticTexts["dispatchWorkItem.status"]
        let resultLabel = app.staticTexts["dispatchWorkItem.result"]

        loadButton.tap()
        cancelButton.tap()

        let cancelledPredicate = NSPredicate(format: "label == 'Cancelled'")
        let cancelledExpectation = XCTNSPredicateExpectation(predicate: cancelledPredicate, object: statusLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [cancelledExpectation], timeout: 5), .completed)

        XCTAssertFalse(resultLabel.label.contains("Resource 2"), "Cancel should prevent Resource 2 from loading")
    }
}
