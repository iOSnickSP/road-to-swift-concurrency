//
//  DispatchSourceDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies DispatchSource: timer-based stopwatch.
//

import XCTest

final class DispatchSourceDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDispatchSourceDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchSourceDemo"].tap()

        let valueLabel = app.staticTexts["dispatchSource.value"]
        XCTAssertTrue(valueLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(valueLabel.label, "0")
    }

    @MainActor
    func testDispatchSourceTimerCountsSeconds() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchSourceDemo"].tap()

        let startButton = app.buttons["dispatchSource.start"]
        let valueLabel = app.staticTexts["dispatchSource.value"]

        startButton.tap()

        let valuePredicate = NSPredicate(format: "label == '3'")
        let expectation = XCTNSPredicateExpectation(predicate: valuePredicate, object: valueLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }

    @MainActor
    func testDispatchSourceStopResets() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchSourceDemo"].tap()

        let startButton = app.buttons["dispatchSource.start"]
        let stopButton = app.buttons["dispatchSource.stop"]
        let valueLabel = app.staticTexts["dispatchSource.value"]

        startButton.tap()
        let valuePredicate = NSPredicate(format: "label == '2'")
        let expectation = XCTNSPredicateExpectation(predicate: valuePredicate, object: valueLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 4), .completed)

        stopButton.tap()
        startButton.tap()

        let resetPredicate = NSPredicate(format: "label == '1'")
        let resetExpectation = XCTNSPredicateExpectation(predicate: resetPredicate, object: valueLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [resetExpectation], timeout: 3), .completed)
    }
}
