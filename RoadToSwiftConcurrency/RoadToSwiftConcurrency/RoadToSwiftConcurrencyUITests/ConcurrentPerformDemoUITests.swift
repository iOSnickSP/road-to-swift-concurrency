//
//  ConcurrentPerformDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies concurrentPerform: parallel processing of 5 items.
//

import XCTest

final class ConcurrentPerformDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testConcurrentPerformDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.concurrentPerformDemo"].tap()

        XCTAssertTrue(app.buttons["concurrentPerform.process"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["concurrentPerform.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testConcurrentPerformProcessesAll() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.concurrentPerformDemo"].tap()

        let processButton = app.buttons["concurrentPerform.process"]
        let resultLabel = app.staticTexts["concurrentPerform.result"]

        processButton.tap()

        let predicate = NSPredicate(format: "label CONTAINS 'Resource'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }

    @MainActor
    func testConcurrentPerformShowsResult() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.concurrentPerformDemo"].tap()

        let processButton = app.buttons["concurrentPerform.process"]
        let resultLabel = app.staticTexts["concurrentPerform.result"]

        processButton.tap()

        let predicate = NSPredicate(format: "label CONTAINS 'Resource 4'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 6), .completed)
    }
}
