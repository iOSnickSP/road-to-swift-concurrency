//
//  AsyncStreamDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies AsyncStream demo screen and accessibility ids.
//

import XCTest

final class AsyncStreamDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAsyncStreamDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.asyncStreamDemo"].tap()

        XCTAssertTrue(app.buttons["asyncStream.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["asyncStream.status"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["asyncStream.result"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["asyncStream.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["asyncStream.result"].label, "—")
    }
}
