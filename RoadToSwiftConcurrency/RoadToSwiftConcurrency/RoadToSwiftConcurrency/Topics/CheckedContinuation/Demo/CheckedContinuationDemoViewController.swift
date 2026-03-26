//
//  CheckedContinuationDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: колбэк → async через withCheckedContinuation.
//  Callback → async via withCheckedContinuation.
//

import UIKit

/// Легаси‑API без async: только колбэк после «сетевой» задержки (как старые SDK).
/// Legacy-style API without async: completion only after simulated latency.
private enum LegacyCallbackLoader {
    static func loadText(delay: TimeInterval = 1.0, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + delay) {
            completion("Data loaded: \(Date())")
        }
    }
}

@MainActor
final class CheckedContinuationDemoViewController: UIViewController {

    private let fetchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fetch", for: .normal)
        button.accessibilityIdentifier = "checkedContinuation.fetch"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Fetch"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "checkedContinuation.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "checkedContinuation.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CheckedContinuation Demo"
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

    /// TASK: оберни вызов LegacyCallbackLoader в withCheckedContinuation — ровно один resume(returning:).
    /// TASK: wrap LegacyCallbackLoader using withCheckedContinuation — exactly one resume(returning:).
    private func fetchBridged() async -> String {
        ""
    }

    @objc private func fetchTapped() {
        // TASK: Task { @MainActor in … }, status Running…, await fetchBridged(), result, status Done
    }

    private func setupUI() {
        view.addSubview(fetchButton)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            fetchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: fetchButton.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        fetchButton.addTarget(self, action: #selector(fetchTapped), for: .touchUpInside)
    }
}
