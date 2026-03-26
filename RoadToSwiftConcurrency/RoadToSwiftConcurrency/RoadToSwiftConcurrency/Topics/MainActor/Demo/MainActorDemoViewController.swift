//
//  MainActorDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Task.detached + hop на MainActor для UI (с защитой от устаревших задач).
//

import UIKit

@MainActor
final class MainActorDemoViewController: UIViewController {

    /// Инкремент на каждый Start: отменённые/старые задачи не затирают UI нового запуска.
    private var operationID = 0
    private var workTask: Task<Void, Never>?

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "mainActor.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "mainActor.cancel"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "mainActor.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "mainActor.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MainActor Demo"
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
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            cancelButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        workTask?.cancel()
        operationID += 1
        let op = operationID

        statusLabel.text = "Running..."
        resultLabel.text = "—"

        workTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                try Task.checkCancellation()
                await self.applySuccessIfCurrent(operation: op)
            } catch {
                await self.applyCancelledIfCurrent(operation: op)
            }
        }
    }

    @objc private func cancelTapped() {
        workTask?.cancel()
    }

    private func applySuccessIfCurrent(operation op: Int) {
        guard op == operationID else { return }
        statusLabel.text = "Done"
        resultLabel.text = "OK"
    }

    private func applyCancelledIfCurrent(operation op: Int) {
        guard op == operationID else { return }
        statusLabel.text = "Cancelled"
        resultLabel.text = "—"
    }
}
