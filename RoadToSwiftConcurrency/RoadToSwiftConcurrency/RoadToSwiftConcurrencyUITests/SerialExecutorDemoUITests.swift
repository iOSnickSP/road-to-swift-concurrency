//
//  SerialExecutorDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies SerialExecutor: QueueBoundCounter Increment.
//

import XCTest

final class SerialExecutorDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSerialExecutorDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.serialExecutorDemo"].tap()

        let countLabel = app.staticTexts["serialExecutor.count"]
        XCTAssertTrue(countLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(countLabel.label, "0")
    }

    @MainActor
    func testSerialExecutorIncrementUpdatesCount() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.serialExecutorDemo"].tap()

        let incrementButton = app.buttons["serialExecutor.increment"]
        let countLabel = app.staticTexts["serialExecutor.count"]

        XCTAssertTrue(incrementButton.waitForExistence(timeout: 2))
        incrementButton.tap()

        let predicate = NSPredicate(format: "label == '1'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: countLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Count should be 1 after one tap")
    }
}
