//
//  TaskPriorityDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: два Task с разным TaskPriority.
//

import UIKit

@MainActor
final class TaskPriorityDemoViewController: UIViewController {

    private var workTask: Task<Void, Never>?
    private var highPriorityTask: Task<Void, Error>?
    private var lowPriorityTask: Task<Void, Error>?

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "taskPriority.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "taskPriority.cancel"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "taskPriority.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let highProgressLabel: UILabel = {
        let label = UILabel()
        label.text = "High: 0/8"
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "taskPriority.highProgress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lowProgressLabel: UILabel = {
        let label = UILabel()
        label.text = "Low: 0/8"
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "taskPriority.lowProgress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let steps = 8

    private enum Timing {
        static let stepSleep: UInt64 = 100_000_000
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TaskPriority Demo"
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
        highPriorityTask?.cancel()
        lowPriorityTask?.cancel()
    }

    @objc private func dismissTapped() {
        cancelAllTasks()
        dismiss(animated: true)
    }

    /// Не вызывать из `deinit` — изоляция MainActor.
    /// Do not call from `deinit` — MainActor isolation.
    private func cancelAllTasks() {
        workTask?.cancel()
        highPriorityTask?.cancel()
        lowPriorityTask?.cancel()
    }

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(cancelButton)
        view.addSubview(statusLabel)
        view.addSubview(highProgressLabel)
        view.addSubview(lowProgressLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),

            highProgressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            highProgressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            highProgressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),

            lowProgressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lowProgressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            lowProgressLabel.topAnchor.constraint(equalTo: highProgressLabel.bottomAnchor, constant: 8)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        cancelAllTasks()

        statusLabel.text = "Running..."
        highProgressLabel.text = "High: 0/\(steps)"
        lowProgressLabel.text = "Low: 0/\(steps)"

        highPriorityTask = Task(priority: .high) { [weak self] in
            guard let self else { return }
            try await self.runPriorityLoop(prefix: "High") { self.highProgressLabel.text = $0 }
        }
        lowPriorityTask = Task(priority: .low) { [weak self] in
            guard let self else { return }
            try await self.runPriorityLoop(prefix: "Low") { self.lowProgressLabel.text = $0 }
        }

        workTask = Task { @MainActor [weak self] in
            guard let self else { return }
            guard let highTask = self.highPriorityTask, let lowTask = self.lowPriorityTask else { return }
            do {
                // Параллельное ожидание обоих Task — оба уже запущены с разным priority.
                // Parallel await — both tasks already running with different priorities.
                async let highResult = try highTask.value
                async let lowResult = try lowTask.value
                _ = try await (highResult, lowResult)
                self.statusLabel.text = "Completed"
            } catch {
                self.statusLabel.text = "Cancelled"
                self.applyCancelledIfNotDone(label: self.highProgressLabel, prefix: "High")
                self.applyCancelledIfNotDone(label: self.lowProgressLabel, prefix: "Low")
            }
        }
    }

    private func applyCancelledIfNotDone(label: UILabel, prefix: String) {
        if !(label.text ?? "").hasSuffix("Done") {
            label.text = "\(prefix): Cancelled"
        }
    }

    private func runPriorityLoop(
        prefix: String,
        setText: @escaping (String) -> Void
    ) async throws {
        for step in 1...steps {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: Timing.stepSleep)
            setText("\(prefix): \(step)/\(steps)")
        }
        setText("\(prefix): Done")
    }

    @objc private func cancelTapped() {
        cancelAllTasks()
    }
}
