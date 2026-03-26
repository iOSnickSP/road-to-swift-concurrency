//
//  CheckedContinuationDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies CheckedContinuation demo screen and accessibility ids.
//

import XCTest

final class CheckedContinuationDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCheckedContinuationDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.checkedContinuationDemo"].tap()

        XCTAssertTrue(app.buttons["checkedContinuation.fetch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["checkedContinuation.status"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["checkedContinuation.result"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["checkedContinuation.status"].label, "Tap Fetch")
        XCTAssertEqual(app.staticTexts["checkedContinuation.result"].label, "—")
    }
}
