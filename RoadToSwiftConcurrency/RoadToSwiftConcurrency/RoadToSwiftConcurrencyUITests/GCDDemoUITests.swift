//
//  GCDDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies GCD task completion: load in background, update UI on main.
//  Passes only when loadButtonTapped is correctly implemented.
//

import XCTest

final class GCDDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGCDDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.gcdDemo"].tap()

        let resultLabel = app.staticTexts["gcd.result"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(resultLabel.label, "Tap Load")
    }

    @MainActor
    func testGCDLoadUpdatesResult() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.gcdDemo"].tap()

        let loadButton = app.buttons["gcd.load"]
        let resultLabel = app.staticTexts["gcd.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        // Wait for result: "Data loaded: ..." (simulateLoad takes ~2 sec)
        let predicate = NSPredicate(format: "label BEGINSWITH 'Data loaded:'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Result label should show 'Data loaded:'")
    }
}
