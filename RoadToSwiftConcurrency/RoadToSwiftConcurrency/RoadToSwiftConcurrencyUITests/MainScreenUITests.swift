//
//  MainScreenUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies main screen and navigation to demos.
//

import XCTest

final class MainScreenUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainScreenShowsTopicButtons() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["topics.gcdDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchGroupDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchSemaphoreDemo"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToGCDDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.gcdDemo"].tap()
        XCTAssertTrue(app.buttons["gcd.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["gcd.result"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchGroupDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchGroupDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchGroup.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dispatchGroup.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchSemaphoreDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchSemaphoreDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchSemaphore.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dispatchSemaphore.status"].waitForExistence(timeout: 2))
    }
}
