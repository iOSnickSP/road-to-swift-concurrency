//
//  CheckedThrowingContinuationDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies CheckedThrowingContinuation demo screen and accessibility ids.
//

import XCTest

final class CheckedThrowingContinuationDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCheckedThrowingContinuationDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.checkedThrowingContinuationDemo"].tap()

        XCTAssertTrue(app.buttons["checkedThrowingContinuation.fetch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.switches["checkedThrowingContinuation.failSwitch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["checkedThrowingContinuation.status"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["checkedThrowingContinuation.result"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["checkedThrowingContinuation.status"].label, "Tap Fetch")
        XCTAssertEqual(app.staticTexts["checkedThrowingContinuation.result"].label, "—")
    }
}
