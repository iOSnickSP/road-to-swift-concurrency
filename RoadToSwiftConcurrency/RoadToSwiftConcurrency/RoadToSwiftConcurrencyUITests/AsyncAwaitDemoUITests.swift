//
//  AsyncAwaitDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies AsyncAwait: load via async/await, update UI.
//

import XCTest

final class AsyncAwaitDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAsyncAwaitDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.asyncAwaitDemo"].tap()

        let resultLabel = app.staticTexts["asyncAwait.result"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(resultLabel.label, "Tap Load")
    }

    @MainActor
    func testAsyncAwaitLoadUpdatesResult() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncAwaitDemo"].tap()

        let loadButton = app.buttons["asyncAwait.load"]
        let resultLabel = app.staticTexts["asyncAwait.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        let predicate = NSPredicate(format: "label BEGINSWITH 'Data loaded:'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Result label should show 'Data loaded:'")
    }
}
