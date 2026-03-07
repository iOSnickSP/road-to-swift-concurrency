//
//  DispatchGroupDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies DispatchGroup task completion: load 3 resources in parallel, show result.
//  Passes only when loadAllTapped is correctly implemented.
//

import XCTest

final class DispatchGroupDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDispatchGroupDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.dispatchGroupDemo"].tap()

        let statusLabel = app.staticTexts["dispatchGroup.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Load All")
    }

    @MainActor
    func testDispatchGroupLoadsAllResources() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchGroupDemo"].tap()

        let loadButton = app.buttons["dispatchGroup.loadAll"]
        let statusLabel = app.staticTexts["dispatchGroup.status"]
        let resultLabel = app.staticTexts["dispatchGroup.result"]

        XCTAssertTrue(loadButton.waitForExistence(timeout: 2))
        loadButton.tap()

        // Wait for status "Done" (all 3 resources loaded, max ~2.5 sec in parallel)
        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        let doneResult = XCTWaiter.wait(for: [doneExpectation], timeout: 6)
        XCTAssertEqual(doneResult, .completed, "Status should be 'Done'")

        // Verify result contains all 3 resources
        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("Resource 0"), "Result should contain Resource 0")
        XCTAssertTrue(resultText.contains("Resource 1"), "Result should contain Resource 1")
        XCTAssertTrue(resultText.contains("Resource 2"), "Result should contain Resource 2")
    }
}
