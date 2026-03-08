//
//  DispatchBarrierDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies DispatchBarrier: thread-safe counter with barrier writes.
//

import XCTest

final class DispatchBarrierDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDispatchBarrierDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchBarrierDemo"].tap()

        let valueLabel = app.staticTexts["dispatchBarrier.value"]
        XCTAssertTrue(valueLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(valueLabel.label, "0")
    }

    @MainActor
    func testDispatchBarrierCounterIncrements() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchBarrierDemo"].tap()

        let incrementButton = app.buttons["dispatchBarrier.increment"]
        let readButton = app.buttons["dispatchBarrier.read"]
        let valueLabel = app.staticTexts["dispatchBarrier.value"]

        for _ in 0..<5 {
            incrementButton.tap()
        }
        readButton.tap()

        let valuePredicate = NSPredicate(format: "label == '5'")
        let expectation = XCTNSPredicateExpectation(predicate: valuePredicate, object: valueLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed)
    }

    @MainActor
    func testDispatchBarrierReadShowsValue() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchBarrierDemo"].tap()

        let incrementButton = app.buttons["dispatchBarrier.increment"]
        let readButton = app.buttons["dispatchBarrier.read"]
        let valueLabel = app.staticTexts["dispatchBarrier.value"]

        incrementButton.tap()
        incrementButton.tap()
        readButton.tap()

        let valuePredicate = NSPredicate(format: "label == '2'")
        let expectation = XCTNSPredicateExpectation(predicate: valuePredicate, object: valueLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed)
    }
}
