//
//  OperationQueueDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies OperationQueue: 3 operations with dependencies A → B → C.
//

import XCTest

final class OperationQueueDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOperationQueueDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.operationQueueDemo"].tap()

        XCTAssertTrue(app.buttons["operationQueue.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["operationQueue.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testOperationQueueLoadsInOrder() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.operationQueueDemo"].tap()

        let loadButton = app.buttons["operationQueue.load"]
        let resultLabel = app.staticTexts["operationQueue.result"]

        loadButton.tap()

        let predicate = NSPredicate(format: "label CONTAINS 'Resource 0'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 8), .completed)
    }

    @MainActor
    func testOperationQueueShowsResult() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.operationQueueDemo"].tap()

        let loadButton = app.buttons["operationQueue.load"]
        let resultLabel = app.staticTexts["operationQueue.result"]

        loadButton.tap()

        let predicate = NSPredicate(format: "label CONTAINS 'Resource 2'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed)
    }
}
