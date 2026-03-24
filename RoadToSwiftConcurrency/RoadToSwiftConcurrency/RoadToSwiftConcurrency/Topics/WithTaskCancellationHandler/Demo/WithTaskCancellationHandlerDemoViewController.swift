//
//  WithTaskCancellationHandlerDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: withTaskCancellationHandler + cleanup on cancel.
//

import UIKit

@MainActor
final class WithTaskCancellationHandlerDemoViewController: UIViewController {

    private var workTask: Task<Void, Never>?

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "withTaskCancellationHandler.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "withTaskCancellationHandler.cancel"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "withTaskCancellationHandler.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cleanupLabel: UILabel = {
        let label = UILabel()
        label.text = "Cleanup: —"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "withTaskCancellationHandler.cleanup"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 10"
        label.font = .monospacedDigitSystemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "withTaskCancellationHandler.progress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalSteps = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "withTaskCancellationHandler Demo"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        setupUI()
        setupActions()
    }

    deinit {
        workTask?.cancel()
    }

    @objc private func dismissTapped() {
        workTask?.cancel()
        dismiss(animated: true)
    }

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(cancelButton)
        view.addSubview(statusLabel)
        view.addSubview(cleanupLabel)
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),

            cleanupLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cleanupLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cleanupLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: cleanupLabel.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        workTask?.cancel()

        statusLabel.text = "Running..."
        cleanupLabel.text = "Cleanup: —"
        progressLabel.text = "0 / \(totalSteps)"

        workTask = Task { [weak self] in
            await self?.runWithCancellationHandler()
        }
    }

    private func runWithCancellationHandler() async {
        do {
            try await withTaskCancellationHandler {
                for step in 1...totalSteps {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: 250_000_000)
                    await MainActor.run {
                        self.progressLabel.text = "\(step) / \(self.totalSteps)"
                    }
                }
            } onCancel: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.cleanupLabel.text = "Cleanup: ran"
                }
            }
            statusLabel.text = "Completed"
        } catch {
            statusLabel.text = "Cancelled"
        }
    }

    @objc private func cancelTapped() {
        workTask?.cancel()
    }
}
