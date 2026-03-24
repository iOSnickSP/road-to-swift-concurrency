//
//  TaskDetachedDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Task.detached не отменяется вместе с родительским Task.
//

import UIKit

@MainActor
final class TaskDetachedDemoViewController: UIViewController {

    private var parentTask: Task<Void, Never>?
    private var detachedTask: Task<Void, Never>?

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "taskDetached.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelParentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel parent", for: .normal)
        button.accessibilityIdentifier = "taskDetached.cancelParent"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelDetachedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel detached", for: .normal)
        button.accessibilityIdentifier = "taskDetached.cancelDetached"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let parentStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Parent: Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "taskDetached.parentStatus"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detachedProgressLabel: UILabel = {
        let label = UILabel()
        label.text = "Detached: —"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "taskDetached.detachedProgress"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let parentSteps = 5
    private let detachedSteps = 8

    private enum Timing {
        static let parentStep = 120_000_000 as UInt64
        static let detachedStep = 100_000_000 as UInt64
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Task.detached Demo"
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
        parentTask?.cancel()
        detachedTask?.cancel()
    }

    @objc private func dismissTapped() {
        cancelRunningTasks()
        dismiss(animated: true)
    }

    private func cancelRunningTasks() {
        parentTask?.cancel()
        detachedTask?.cancel()
    }

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(cancelParentButton)
        view.addSubview(cancelDetachedButton)
        view.addSubview(parentStatusLabel)
        view.addSubview(detachedProgressLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            cancelParentButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            cancelParentButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),

            cancelDetachedButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            cancelDetachedButton.centerYAnchor.constraint(equalTo: cancelParentButton.centerYAnchor),

            parentStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            parentStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            parentStatusLabel.topAnchor.constraint(equalTo: cancelParentButton.bottomAnchor, constant: 24),

            detachedProgressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            detachedProgressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            detachedProgressLabel.topAnchor.constraint(equalTo: parentStatusLabel.bottomAnchor, constant: 12)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        cancelParentButton.addTarget(self, action: #selector(cancelParentTapped), for: .touchUpInside)
        cancelDetachedButton.addTarget(self, action: #selector(cancelDetachedTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        cancelRunningTasks()

        parentStatusLabel.text = "Parent: Running"
        detachedProgressLabel.text = "Detached: 0/\(detachedSteps)"

        // Сначала detached — он не дочерний к родителю; отмена parentTask на него не действует.
        // Start detached first — it is not a child; cancelling parentTask does not cancel it.
        let detachedTotal = detachedSteps
        detachedTask = Task.detached(priority: .userInitiated) { [weak self] in
            do {
                for step in 1...detachedTotal {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: Timing.detachedStep)
                    await MainActor.run { [weak self] in
                        self?.detachedProgressLabel.text = "Detached: \(step)/\(detachedTotal)"
                    }
                }
                await MainActor.run { [weak self] in
                    self?.detachedProgressLabel.text = "Detached: Done"
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.detachedProgressLabel.text = "Detached: Cancelled"
                }
            }
        }

        parentTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                for step in 1...self.parentSteps {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: Timing.parentStep)
                    self.parentStatusLabel.text = "Parent: \(step)/\(self.parentSteps)"
                }
                self.parentStatusLabel.text = "Parent: Completed"
            } catch {
                self.parentStatusLabel.text = "Parent: Cancelled"
            }
        }
    }

    @objc private func cancelParentTapped() {
        parentTask?.cancel()
    }

    @objc private func cancelDetachedTapped() {
        detachedTask?.cancel()
    }
}
