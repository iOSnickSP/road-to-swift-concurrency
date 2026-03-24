//
//  AsyncLetDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies async let demo: parallel loads complete with expected resources.
//

import XCTest

final class AsyncLetDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAsyncLetDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.asyncLetDemo"].tap()

        let statusLabel = app.staticTexts["asyncLet.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Load All")
    }

    @MainActor
    func testAsyncLetLoadsAllResources() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncLetDemo"].tap()

        let loadButton = app.buttons["asyncLet.loadAll"]
        let statusLabel = app.staticTexts["asyncLet.status"]
        let resultLabel = app.staticTexts["asyncLet.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        let doneResult = XCTWaiter.wait(for: [doneExpectation], timeout: 6)
        XCTAssertEqual(doneResult, .completed, "Status should be 'Done'")

        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("Resource 0"), "Result should contain Resource 0")
        XCTAssertTrue(resultText.contains("Resource 1"), "Result should contain Resource 1")
        XCTAssertTrue(resultText.contains("Resource 2"), "Result should contain Resource 2")
    }
}
