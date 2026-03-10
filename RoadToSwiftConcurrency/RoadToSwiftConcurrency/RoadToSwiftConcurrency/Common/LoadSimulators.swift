//
//  LoadSimulators.swift
//  RoadToSwiftConcurrency
//
//  Shared load simulators for demos. Configurable delay for testing.
//

import Foundation

enum LoadSimulators {

    /// GCD demo: simulates data load. Call from background thread.
    static func gcdSimulateLoad(delay: TimeInterval = 2) -> String {
        Thread.sleep(forTimeInterval: delay)
        return "Data loaded: \(Date())"
    }

    /// DispatchGroup demo: simulates resource load. Call from background thread.
    static func dispatchGroupLoadResource(id: Int, delay: TimeInterval? = nil) -> String {
        let resolvedDelay = delay ?? Double(id) * 0.5 + 1.0
        Thread.sleep(forTimeInterval: resolvedDelay)
        return "Resource \(id)"
    }
}
