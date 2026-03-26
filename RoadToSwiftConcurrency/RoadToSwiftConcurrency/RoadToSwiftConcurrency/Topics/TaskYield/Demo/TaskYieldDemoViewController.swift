//
//  TaskYieldDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Task.yield() в цикле + отмена.
//

import UIKit

@MainActor
final class TaskYieldDemoViewController: UIViewController {

    private var workTask: Task<Void, Never>?

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "taskYield.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "taskYield.cancel"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "taskYield.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 12"
        label.font = .monospacedDigitSystemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "taskYield.progress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalSteps = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Task.yield Demo"
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

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
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

        // TASK: Topics/TaskYield/THEORY.md — Task { @MainActor in … }, цикл с try Task.checkCancellation(),
        // await Task.yield(), sleep, обновление progress; Completed / Cancelled на status.
    }

    @objc private func cancelTapped() {
        workTask?.cancel()
        // TASK: отмена workTask
    }
}
