//
//  SerialExecutorDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Actor с custom SerialExecutor — привязка к DispatchQueue.
//  Actor bound to custom queue via SerialExecutor.
//

import UIKit

/// Executor, диспатчащий job'ы на выделенную DispatchQueue.
/// Dispatches jobs onto a dedicated DispatchQueue.
///
/// TASK: Реализуй enqueue — UnownedJob(job), queue.async { unownedJob.runSynchronously(on: ...) }
/// Implement enqueue — see THEORY.md pattern.
final class CustomQueueExecutor: SerialExecutor {
    private let queue = DispatchQueue(label: "com.demo.serial")

    func enqueue(_ job: consuming ExecutorJob) {
        // TASK: полная реализация — иначе job не выполнится, тесты зависнут
        // Full implementation — otherwise job never runs, tests hang
        _ = UnownedJob(job)
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

/// Actor, привязанный к CustomQueueExecutor.
/// TASK: Реализуй increment() — count += 1; return count
actor QueueBoundCounter {
    private let executor = CustomQueueExecutor()
    private var count = 0

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    func increment() async -> Int {
        // TASK: count += 1; return count
        return 0
    }
}

@MainActor
final class SerialExecutorDemoViewController: UIViewController {

    private let counter = QueueBoundCounter()

    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Increment", for: .normal)
        button.accessibilityIdentifier = "serialExecutor.increment"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .monospacedDigitSystemFont(ofSize: 34, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "serialExecutor.count"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SerialExecutor Demo"
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

    @objc private func incrementTapped() {
        // TASK: Task { let n = await counter.increment(); countLabel.text = "\(n)" }
    }

    private func setupUI() {
        view.addSubview(incrementButton)
        view.addSubview(countLabel)

        NSLayoutConstraint.activate([
            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            incrementButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: incrementButton.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
    }
}
