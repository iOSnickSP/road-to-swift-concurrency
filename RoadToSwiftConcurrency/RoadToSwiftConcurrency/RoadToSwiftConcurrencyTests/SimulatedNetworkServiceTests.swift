//
//  SimulatedNetworkServiceTests.swift
//  RoadToSwiftConcurrencyTests
//
//  Unit tests for SimulatedNetworkService. Verifies string contracts and helpers.
//

import XCTest
@testable import RoadToSwiftConcurrency

final class SimulatedNetworkServiceTests: XCTestCase {

    func testFetchTextSyncOutputFormat() {
        let result = SimulatedNetworkService.fetchTextSync(delay: 0)
        XCTAssertTrue(result.hasPrefix("Data loaded:"))
    }

    func testFetchResourceSyncOutputFormat() {
        for id in 0..<3 {
            let result = SimulatedNetworkService.fetchResourceSync(id: id, delay: 0)
            XCTAssertEqual(result, "Resource \(id)")
        }
    }

    /// DispatchSemaphore demo uses id 0..<5. Verifies format for all 5.
    func testFetchResourceSyncForSemaphoreIds() {
        for id in 0..<5 {
            let result = SimulatedNetworkService.fetchResourceSync(id: id, delay: 0)
            XCTAssertEqual(result, "Resource \(id)", "Resource \(id) expected for id \(id)")
        }
    }

    func testFetchTextAsyncOutputFormat() async {
        let result = await SimulatedNetworkService.fetchText(delay: 0)
        XCTAssertTrue(result.hasPrefix("Data loaded:"))
    }

    func testFetchResourceAsyncOutputFormat() async {
        for id in 0..<3 {
            let result = await SimulatedNetworkService.fetchResource(id: id, delay: 0)
            XCTAssertEqual(result, "Resource \(id)")
        }
    }

    func testFetchRandomIntInRange() async {
        let value = await SimulatedNetworkService.fetchRandomInt(in: 1...100, delay: 0)
        XCTAssertTrue((1...100).contains(value))
    }

    func testFetchRandomPayloadByteCount() async {
        let data = await SimulatedNetworkService.fetchRandomPayload(byteCount: 32, delay: 0)
        XCTAssertEqual(data.count, 32)
    }

    func testFetchImageMockNonNil() async {
        let image = await SimulatedNetworkService.fetchImage(mode: .mock(), delay: 0)
        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image?.size.width ?? 0, 0)
    }
}
