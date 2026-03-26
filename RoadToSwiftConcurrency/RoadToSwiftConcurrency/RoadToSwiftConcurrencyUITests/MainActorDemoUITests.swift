//
//  MainActorDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies MainActor demo: background work + MainActor.run for UI.
//

import XCTest

final class MainActorDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainActorInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.mainActorDemo"].tap()

        XCTAssertTrue(app.staticTexts["mainActor.status"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["mainActor.status"].label, "Tap Start")
        XCTAssertEqual(app.staticTexts["mainActor.result"].label, "—")
    }

    @MainActor
    func testMainActorCompletesToDone() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.mainActorDemo"].tap()

        app.buttons["mainActor.start"].tap()

        let status = app.staticTexts["mainActor.status"]
        let result = app.staticTexts["mainActor.result"]

        let done = NSPredicate(format: "label == 'Done'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: done, object: status)], timeout: 5),
            .completed
        )
        XCTAssertEqual(result.label, "OK")
    }

    @MainActor
    func testMainActorCancel() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.mainActorDemo"].tap()

        app.buttons["mainActor.start"].tap()
        app.buttons["mainActor.cancel"].tap()

        let status = app.staticTexts["mainActor.status"]
        let cancelled = NSPredicate(format: "label == 'Cancelled'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: cancelled, object: status)], timeout: 3),
            .completed
        )
    }
}
