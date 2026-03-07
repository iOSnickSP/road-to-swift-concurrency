//
//  LoadSimulatorTests.swift
//  RoadToSwiftConcurrencyTests
//
//  Unit tests for load simulators. Verifies output format.
//

import XCTest
@testable import RoadToSwiftConcurrency

final class LoadSimulatorTests: XCTestCase {

    func testGCDLoadOutputFormat() {
        let result = LoadSimulators.gcdSimulateLoad(delay: 0)
        XCTAssertTrue(result.hasPrefix("Data loaded:"))
    }

    func testDispatchGroupResourceOutputFormat() {
        for id in 0..<3 {
            let result = LoadSimulators.dispatchGroupLoadResource(id: id, delay: 0)
            XCTAssertEqual(result, "Resource \(id)")
        }
    }
}
