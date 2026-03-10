//
//  ActorDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies Actor: counter increment, UI update.
//

import XCTest

final class ActorDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testActorDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.actorDemo"].tap()

        let countLabel = app.staticTexts["actorDemo.count"]
        XCTAssertTrue(countLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(countLabel.label, "0")
    }

    @MainActor
    func testActorIncrementUpdatesCount() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.actorDemo"].tap()

        let addButton = app.buttons["actorDemo.add"]
        let countLabel = app.staticTexts["actorDemo.count"]

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()

        let predicate = NSPredicate(format: "label == '1'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: countLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Count should be 1 after one tap")
    }
}
