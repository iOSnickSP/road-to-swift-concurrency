//
//  ProgressViewTests.swift
//  RoadToSwiftConcurrencyTests
//

import XCTest
@testable import RoadToSwiftConcurrency

final class ProgressViewTests: XCTestCase {

    func testProgressInitialValue() {
        let view = ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(view.progress, 0)
    }

    func testSetProgress() {
        let view = ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        view.progress = 0.5
        XCTAssertEqual(view.progress, 0.5)
    }

    func testProgressClamped() {
        let view = ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        view.setProgress(1.5, animated: false)
        XCTAssertEqual(view.progress, 1)
        view.setProgress(-0.5, animated: false)
        XCTAssertEqual(view.progress, 0)
    }

    func testReset() {
        let view = ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        view.progress = 0.7
        view.reset()
        XCTAssertEqual(view.progress, 0)
    }

    func testSetProgressAnimated() {
        let view = ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        view.progress = 0.3
        view.setProgress(0.8, animated: true)
        XCTAssertEqual(view.progress, 0.8)
    }

    func testIntrinsicContentSize() {
        let view = ProgressView()
        view.barHeight = 12
        let size = view.intrinsicContentSize
        XCTAssertEqual(size.height, 12)
        XCTAssertEqual(size.width, UIView.noIntrinsicMetric)
    }
}
