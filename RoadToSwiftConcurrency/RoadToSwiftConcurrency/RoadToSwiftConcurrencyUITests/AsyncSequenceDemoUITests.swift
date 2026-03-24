//
//  AsyncSequenceDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies AsyncSequence demo: iterator yields steps 1, 2, 3.
//

import XCTest

final class AsyncSequenceDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAsyncSequenceDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.asyncSequenceDemo"].tap()

        let statusLabel = app.staticTexts["asyncSequence.status"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(statusLabel.label, "Tap Start")
    }

    @MainActor
    func testAsyncSequenceCompletesWithSteps() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncSequenceDemo"].tap()

        let startButton = app.buttons["asyncSequence.start"]
        let statusLabel = app.staticTexts["asyncSequence.status"]
        let resultLabel = app.staticTexts["asyncSequence.result"]

        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        let donePredicate = NSPredicate(format: "label == 'Done'")
        let doneExpectation = XCTNSPredicateExpectation(predicate: donePredicate, object: statusLabel)
        let doneResult = XCTWaiter.wait(for: [doneExpectation], timeout: 8)
        XCTAssertEqual(doneResult, .completed, "Status should be 'Done'")

        let resultText = resultLabel.label
        XCTAssertTrue(resultText.contains("1"), "Result should contain 1")
        XCTAssertTrue(resultText.contains("2"), "Result should contain 2")
        XCTAssertTrue(resultText.contains("3"), "Result should contain 3")
    }
}
