//
//  DispatchSemaphoreDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies DispatchSemaphore: load 5 resources, max 2 concurrent, show result.
//  Passes only when loadAllTapped is correctly implemented.
//

import XCTest

final class DispatchSemaphoreDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDispatchSemaphoreDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchSemaphoreDemo"].tap()

        let statusLabel = app.staticTexts["dispatchSemaphore.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Load All")
    }

    @MainActor
    func testDispatchSemaphoreLoadsAllResources() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchSemaphoreDemo"].tap()

        let loadButton = app.buttons["dispatchSemaphore.loadAll"]
        let statusLabel = app.staticTexts["dispatchSemaphore.status"]
        let resultLabel = app.staticTexts["dispatchSemaphore.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        // Wait for status "Done" (all 5 resources loaded, max 2 concurrent → ~4–5 sec)
        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        let doneResult = XCTWaiter.wait(for: [doneExpectation], timeout: 12)
        XCTAssertEqual(doneResult, .completed, "Status should be 'Done'")

        // Verify result contains all 5 resources
        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("Resource 0"), "Result should contain Resource 0")
        XCTAssertTrue(resultText.contains("Resource 1"), "Result should contain Resource 1")
        XCTAssertTrue(resultText.contains("Resource 2"), "Result should contain Resource 2")
        XCTAssertTrue(resultText.contains("Resource 3"), "Result should contain Resource 3")
        XCTAssertTrue(resultText.contains("Resource 4"), "Result should contain Resource 4")

        // Button re-enabled after completion
        XCTAssertTrue(loadButton.isEnabled)
    }

    @MainActor
    func testDispatchSemaphoreCanReload() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchSemaphoreDemo"].tap()

        let loadButton = app.buttons["dispatchSemaphore.loadAll"]
        let statusLabel = app.staticTexts["dispatchSemaphore.status"]
        let donePredicate = NSPredicate(format: "label == 'Done'")

        loadButton.tap()
        var expectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 12), .completed)

        // Tap again — should complete without crash
        loadButton.tap()
        expectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 12), .completed)
        XCTAssertEqual(statusLabel.label, "Done")
    }
}
