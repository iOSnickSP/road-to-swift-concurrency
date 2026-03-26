//
//  ContinuousClockDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Task.sleep(for:clock:) + замер Duration на ContinuousClock.
//

import UIKit

@MainActor
final class ContinuousClockDemoViewController: UIViewController {

    private var workTask: Task<Void, Never>?
    private let monoClock = ContinuousClock()
    private let totalSteps = 5
    private let stepDuration = Duration.milliseconds(200)

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "continuousClock.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "continuousClock.cancel"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "continuousClock.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 5"
        label.font = .monospacedDigitSystemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "continuousClock.progress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "continuousClock.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ContinuousClock Demo"
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
        view.addSubview(progressLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        workTask?.cancel()

        statusLabel.text = "Running..."
        progressLabel.text = "0 / \(totalSteps)"
        resultLabel.text = "—"

        workTask = Task { @MainActor in
            await self.runSteps()
        }
    }

    private func runSteps() async {
        let start = monoClock.now
        do {
            for step in 1...totalSteps {
                try Task.checkCancellation()
                try await Task.sleep(for: stepDuration, clock: monoClock)
                progressLabel.text = "\(step) / \(totalSteps)"
            }
            let elapsed = start.duration(to: monoClock.now)
            resultLabel.text = "Elapsed: \(String(describing: elapsed))"
            statusLabel.text = "Completed"
        } catch {
            statusLabel.text = "Cancelled"
            resultLabel.text = "—"
        }
    }

    @objc private func cancelTapped() {
        workTask?.cancel()
    }
}
