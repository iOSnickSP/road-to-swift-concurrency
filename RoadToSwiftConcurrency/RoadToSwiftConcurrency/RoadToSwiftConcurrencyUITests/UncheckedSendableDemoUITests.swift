//
//  UncheckedSendableDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies @unchecked Sendable: ThreadSafeBox Store and Retrieve.
//

import XCTest

final class UncheckedSendableDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testUncheckedSendableDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.uncheckedSendableDemo"].tap()

        XCTAssertTrue(app.textFields["uncheckedSendable.input"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["uncheckedSendable.store"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["uncheckedSendable.retrieve"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["uncheckedSendable.result"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testUncheckedSendableStoreAndRetrieve() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.uncheckedSendableDemo"].tap()

        let inputField = app.textFields["uncheckedSendable.input"]
        let storeButton = app.buttons["uncheckedSendable.store"]
        let retrieveButton = app.buttons["uncheckedSendable.retrieve"]
        let resultLabel = app.staticTexts["uncheckedSendable.result"]

        XCTAssertTrue(inputField.waitForExistence(timeout: 2))
        inputField.tap()
        inputField.typeText("ThreadSafe value")

        storeButton.tap()

        let predicate = NSPredicate(format: "label == 'ThreadSafe value'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        retrieveButton.tap()
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "Result label should show 'ThreadSafe value'")
    }
}
