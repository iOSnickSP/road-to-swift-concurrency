//
//  SendableDemoUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies Sendable: Message Relay — Send and Receive.
//

import XCTest

final class SendableDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSendableDemoInitialState() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["topics.sendableDemo"].tap()

        XCTAssertTrue(app.textFields["sendableDemo.input"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["sendableDemo.send"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["sendableDemo.receive"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["sendableDemo.result"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSendableSendAndReceive() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.sendableDemo"].tap()

        let inputField = app.textFields["sendableDemo.input"]
        let sendButton = app.buttons["sendableDemo.send"]
        let receiveButton = app.buttons["sendableDemo.receive"]
        let resultLabel = app.staticTexts["sendableDemo.result"]

        XCTAssertTrue(inputField.waitForExistence(timeout: 2))
        inputField.tap()
        inputField.typeText("Hello Sendable")

        sendButton.tap()

        let predicate = NSPredicate(format: "label == 'Hello Sendable'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: resultLabel)
        receiveButton.tap()
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "Result label should show 'Hello Sendable'")
    }
}
