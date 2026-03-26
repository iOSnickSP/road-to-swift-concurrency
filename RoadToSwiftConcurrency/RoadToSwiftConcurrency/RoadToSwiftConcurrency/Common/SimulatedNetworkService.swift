//
//  SimulatedNetworkService.swift
//  RoadToSwiftConcurrency
//
//  Единая эмуляция «сетевых» запросов: задержки, текстовые ответы, случайные данные, картинки.
//  Single place for simulated network latency, text payloads, random data, and images.
//

import Foundation
import UIKit

enum SimulatedNetworkService {

    // MARK: - Latency

    private static func sleepAsync(seconds: TimeInterval) async throws {
        let ns = UInt64(max(0, seconds) * 1_000_000_000)
        try await Task.sleep(nanoseconds: ns)
    }

    private static func sleepBlocking(seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: max(0, seconds))
    }

    private static func resolvedResourceDelay(id: Int, override: TimeInterval?) -> TimeInterval {
        override ?? Double(id) * 0.5 + 1.0
    }

    // MARK: - Text (async)

    /// Симулирует GET текста. Вызывать с `await`.
    /// Simulates async text load. Call with `await`.
    static func fetchText(delay: TimeInterval = 2) async -> String {
        try? await sleepAsync(seconds: delay)
        return "Data loaded: \(Date())"
    }

    /// Симулирует загрузку именованного ресурса. Вызывать с `await`.
    /// Simulates named resource load. Call with `await`.
    static func fetchResource(id: Int, delay: TimeInterval? = nil) async -> String {
        try? await sleepAsync(seconds: resolvedResourceDelay(id: id, override: delay))
        return "Resource \(id)"
    }

    // MARK: - Text (blocking — GCD / Dispatch / OperationQueue)

    /// Симулирует GET текста. Вызывать только с фонового потока.
    /// Simulates text load. Call only from a background thread.
    static func fetchTextSync(delay: TimeInterval = 2) -> String {
        sleepBlocking(seconds: delay)
        return "Data loaded: \(Date())"
    }

    /// Симулирует загрузку именованного ресурса. Вызывать только с фонового потока.
    /// Simulates named resource load. Call only from a background thread.
    static func fetchResourceSync(id: Int, delay: TimeInterval? = nil) -> String {
        sleepBlocking(seconds: resolvedResourceDelay(id: id, override: delay))
        return "Resource \(id)"
    }

    // MARK: - Random data

    /// «Запрос» случайного числа после эмуляции задержки сети.
    /// Random integer after simulated network latency.
    static func fetchRandomInt(in range: ClosedRange<Int>, delay: TimeInterval = 0.5) async -> Int {
        try? await sleepAsync(seconds: delay)
        return Int.random(in: range)
    }

    /// Моковый бинарный payload фиксированной длины (не настоящий API).
    /// Mock binary payload of fixed length (not a real API).
    static func fetchRandomPayload(byteCount: Int, delay: TimeInterval = 0.5) async -> Data {
        try? await sleepAsync(seconds: delay)
        let count = max(0, byteCount)
        var bytes = [UInt8](repeating: 0, count: count)
        for i in bytes.indices {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return Data(bytes)
    }

    // MARK: - Image

    enum ImageFetchMode: Equatable {
        /// Локальная генерация без сети (по умолчанию для CI и офлайн).
        /// Local mock image (default for CI / offline).
        case mock(size: CGSize = CGSize(width: 200, height: 200))
        /// Реальная загрузка по HTTPS (например `URL(string: "https://picsum.photos/200/200")!`).
        /// Real HTTPS fetch. Use `nil` on failure or missing network.
        case network(URL)
    }

    /// Моковая картинка или загрузка по URL после эмуляции задержки.
    /// Mock image or network fetch after simulated latency.
    static func fetchImage(mode: ImageFetchMode = .mock(), delay: TimeInterval = 0.5) async -> UIImage? {
        try? await sleepAsync(seconds: delay)
        switch mode {
        case .mock(let size):
            return renderMockImage(size: size)
        case .network(let url):
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }
    }

    private static func renderMockImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let c1 = UIColor(
            red: CGFloat.random(in: 0.3...1),
            green: CGFloat.random(in: 0.3...1),
            blue: CGFloat.random(in: 0.3...1),
            alpha: 1
        )
        let c2 = UIColor(
            red: CGFloat.random(in: 0...0.5),
            green: CGFloat.random(in: 0...0.5),
            blue: CGFloat.random(in: 0...0.5),
            alpha: 1
        )
        return renderer.image { ctx in
            let colors = [c1.cgColor, c2.cgColor] as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) {
                ctx.cgContext.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }
        }
    }
}
