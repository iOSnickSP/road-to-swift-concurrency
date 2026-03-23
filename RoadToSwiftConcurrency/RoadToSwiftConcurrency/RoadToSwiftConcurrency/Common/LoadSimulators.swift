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

    /// AsyncAwait demo: simulates async data load. Call with await.
    static func asyncSimulateLoad(delay: TimeInterval = 2) async -> String {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return "Data loaded: \(Date())"
    }

    /// TaskGroup demo: simulates async resource load. Call with await.
    static func taskGroupLoadResource(id: Int, delay: TimeInterval? = nil) async -> String {
        let resolvedDelay = delay ?? Double(id) * 0.5 + 1.0
        try? await Task.sleep(nanoseconds: UInt64(resolvedDelay * 1_000_000_000))
        return "Resource \(id)"
    }
}
