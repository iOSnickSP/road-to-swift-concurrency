//
//  AsyncStreamDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: легаси-колбэки → AsyncStream, for await.
//  Demo: legacy callbacks → AsyncStream, for await.
//

import UIKit

/// Имитация потока «кусков» с фоновой очередью (как прогресс или чанки сокета).
/// Simulated chunk stream on a background queue (like progress or socket chunks).
private enum LegacyChunkTicker {
    static func start(
        chunkCount: Int = 5,
        interval: TimeInterval = 0.2,
        onChunk: @escaping (Int) -> Void,
        onFinished: @escaping () -> Void
    ) {
        let queue = DispatchQueue(label: "legacy.chunk.ticker", qos: .utility)
        var emitted = 0

        func emitNext() {
            guard emitted < chunkCount else {
                queue.async(execute: onFinished)
                return
            }
            emitted += 1
            queue.asyncAfter(deadline: .now() + interval) {
                onChunk(emitted)
                emitNext()
            }
        }

        emitNext()
    }
}

@MainActor
final class AsyncStreamDemoViewController: UIViewController {

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "asyncStream.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncStream.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncStream.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AsyncStream Demo"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        setupUI()
        setupActions()
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    /// TASK: AsyncStream { continuation in … } + LegacyChunkTicker.start → yield / finish.
    /// TASK: AsyncStream { continuation in … } + LegacyChunkTicker.start → yield / finish.
    private func makeStream() -> AsyncStream<Int> {
        AsyncStream { _ in }
    }

    @objc private func startTapped() {
        // TASK: Task { @MainActor in … }, for await makeStream(), status/result
    }

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
}
