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
final class CustomQueueExecutor: SerialExecutor {
    private let queue = DispatchQueue(label: "com.demo.serial")

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let unownedExec = asUnownedSerialExecutor()
        queue.async {
            unownedJob.runSynchronously(on: unownedExec)
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

/// Actor, привязанный к CustomQueueExecutor. Работа выполняется на выделенной очереди.
/// Actor bound to CustomQueueExecutor. Work runs on dedicated queue.
actor QueueBoundCounter {
    private let executor = CustomQueueExecutor()
    private var count = 0

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    func increment() async -> Int {
        count += 1
        return count
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
        Task {
            let n = await counter.increment()
            countLabel.text = "\(n)"
        }
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
