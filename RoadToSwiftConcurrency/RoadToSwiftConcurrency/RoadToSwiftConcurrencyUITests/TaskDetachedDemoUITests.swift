//
//  TaskDetachedDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies Task.detached demo: parent vs detached cancellation.
//

import XCTest

final class TaskDetachedDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTaskDetachedInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskDetachedDemo"].tap()

        XCTAssertTrue(app.staticTexts["taskDetached.parentStatus"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["taskDetached.parentStatus"].label, "Parent: Tap Start")
        XCTAssertEqual(app.staticTexts["taskDetached.detachedProgress"].label, "Detached: —")
    }

    @MainActor
    func testTaskDetachedBothComplete() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskDetachedDemo"].tap()

        app.buttons["taskDetached.start"].tap()

        let parent = app.staticTexts["taskDetached.parentStatus"]
        let detached = app.staticTexts["taskDetached.detachedProgress"]

        let parentDone = NSPredicate(format: "label == 'Parent: Completed'")
        let detachedDone = NSPredicate(format: "label == 'Detached: Done'")

        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: parentDone, object: parent)], timeout: 5),
            .completed
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: detachedDone, object: detached)], timeout: 5),
            .completed
        )
    }

    @MainActor
    func testTaskDetachedCancelParentLeavesDetachedRunning() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskDetachedDemo"].tap()

        app.buttons["taskDetached.start"].tap()
        app.buttons["taskDetached.cancelParent"].tap()

        let parent = app.staticTexts["taskDetached.parentStatus"]
        let detached = app.staticTexts["taskDetached.detachedProgress"]

        let parentCancelled = NSPredicate(format: "label == 'Parent: Cancelled'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: parentCancelled, object: parent)], timeout: 3),
            .completed
        )

        let detachedDone = NSPredicate(format: "label == 'Detached: Done'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: detachedDone, object: detached)], timeout: 5),
            .completed,
            "Detached task should finish even when parent was cancelled"
        )
    }

    @MainActor
    func testTaskDetachedCancelDetached() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.taskDetachedDemo"].tap()

        app.buttons["taskDetached.start"].tap()
        app.buttons["taskDetached.cancelDetached"].tap()

        let detached = app.staticTexts["taskDetached.detachedProgress"]
        let detachedCancelled = NSPredicate(format: "label == 'Detached: Cancelled'")
        XCTAssertEqual(
            XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: detachedCancelled, object: detached)], timeout: 3),
            .completed
        )
    }
}
