//
//  MainScreenUITests.swift
//  RoadToSwiftConcurrencyUITests
//
//  Verifies main screen and navigation to demos.
//

import XCTest

final class MainScreenUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainScreenShowsTopicButtons() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["topics.gcdDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchGroupDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchSemaphoreDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchWorkItemDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchBarrierDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.dispatchSourceDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.operationQueueDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.concurrentPerformDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.asyncAwaitDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.taskGroupDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.asyncLetDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.asyncSequenceDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.taskCancellationDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.withTaskCancellationHandlerDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.taskYieldDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.actorDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.sendableDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.uncheckedSendableDemo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["topics.serialExecutorDemo"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToGCDDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.gcdDemo"].tap()
        XCTAssertTrue(app.buttons["gcd.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["gcd.result"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchGroupDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchGroupDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchGroup.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dispatchGroup.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchSemaphoreDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchSemaphoreDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchSemaphore.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dispatchSemaphore.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchWorkItemDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchWorkItemDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchWorkItem.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["dispatchWorkItem.cancel"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchBarrierDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchBarrierDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchBarrier.increment"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["dispatchBarrier.read"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToDispatchSourceDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.dispatchSourceDemo"].tap()
        XCTAssertTrue(app.buttons["dispatchSource.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["dispatchSource.stop"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToOperationQueueDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.operationQueueDemo"].tap()
        XCTAssertTrue(app.buttons["operationQueue.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["operationQueue.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToConcurrentPerformDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.concurrentPerformDemo"].tap()
        XCTAssertTrue(app.buttons["concurrentPerform.process"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["concurrentPerform.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToAsyncAwaitDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncAwaitDemo"].tap()
        XCTAssertTrue(app.buttons["asyncAwait.load"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["asyncAwait.result"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToTaskGroupDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.taskGroupDemo"].tap()
        XCTAssertTrue(app.buttons["taskGroup.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["taskGroup.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToAsyncLetDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncLetDemo"].tap()
        XCTAssertTrue(app.buttons["asyncLet.loadAll"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["asyncLet.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToAsyncSequenceDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.asyncSequenceDemo"].tap()
        XCTAssertTrue(app.buttons["asyncSequence.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["asyncSequence.status"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToTaskCancellationDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.taskCancellationDemo"].tap()
        XCTAssertTrue(app.buttons["taskCancellation.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["taskCancellation.cancel"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToWithTaskCancellationHandlerDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.withTaskCancellationHandlerDemo"].tap()
        XCTAssertTrue(app.buttons["withTaskCancellationHandler.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["withTaskCancellationHandler.cancel"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToTaskYieldDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.taskYieldDemo"].tap()
        XCTAssertTrue(app.buttons["taskYield.start"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["taskYield.cancel"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToActorDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.actorDemo"].tap()
        XCTAssertTrue(app.buttons["actorDemo.add"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["actorDemo.count"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToSendableDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.sendableDemo"].tap()
        XCTAssertTrue(app.buttons["sendableDemo.send"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["sendableDemo.receive"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToUncheckedSendableDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.uncheckedSendableDemo"].tap()
        XCTAssertTrue(app.buttons["uncheckedSendable.store"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["uncheckedSendable.retrieve"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCanNavigateToSerialExecutorDemo() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["topics.serialExecutorDemo"].tap()
        XCTAssertTrue(app.buttons["serialExecutor.increment"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["serialExecutor.count"].waitForExistence(timeout: 2))
    }
}
