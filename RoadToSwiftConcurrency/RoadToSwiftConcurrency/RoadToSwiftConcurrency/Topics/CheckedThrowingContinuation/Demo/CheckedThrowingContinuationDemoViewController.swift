//
//  CheckedThrowingContinuationDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Result в колбэке → async throws через withCheckedThrowingContinuation.
//  Demo: Result callback → async throws via withCheckedThrowingContinuation.
//

import UIKit

/// Легаси‑API: колбэк с Result (как многие сетевые обёртки).
/// Legacy-style API: completion with Result (like many networking wrappers).
private enum LegacyResultLoader {
    enum SimulatedFailure: Error {
        case backendSaidNo
    }

    static func loadText(
        shouldFail: Bool,
        delay: TimeInterval = 1.0,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + delay) {
            if shouldFail {
                completion(.failure(SimulatedFailure.backendSaidNo))
            } else {
                completion(.success("Data loaded: \(Date())"))
            }
        }
    }
}

extension LegacyResultLoader.SimulatedFailure: LocalizedError {
    var errorDescription: String? {
        "Simulated backend failure (backendSaidNo)"
    }
}

@MainActor
final class CheckedThrowingContinuationDemoViewController: UIViewController {

    private let fetchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fetch", for: .normal)
        button.accessibilityIdentifier = "checkedThrowingContinuation.fetch"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let failSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.accessibilityIdentifier = "checkedThrowingContinuation.failSwitch"
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let failLabel: UILabel = {
        let label = UILabel()
        label.text = "Simulate failure"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Fetch"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "checkedThrowingContinuation.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "checkedThrowingContinuation.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CheckedThrowingContinuation Demo"
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

    private func fetchBridged(shouldFail: Bool) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            LegacyResultLoader.loadText(shouldFail: shouldFail) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @objc private func fetchTapped() {
        let shouldFail = failSwitch.isOn
        Task { @MainActor in
            fetchButton.isEnabled = false
            defer { fetchButton.isEnabled = true }

            statusLabel.text = "Running…"
            resultLabel.text = "…"
            do {
                let text = try await fetchBridged(shouldFail: shouldFail)
                resultLabel.text = text
                statusLabel.text = "Done"
            } catch {
                resultLabel.text = error.localizedDescription
                statusLabel.text = "Failed"
            }
        }
    }

    private func setupUI() {
        let switchRow = UIStackView(arrangedSubviews: [failLabel, failSwitch])
        switchRow.axis = .horizontal
        switchRow.spacing = 12
        switchRow.alignment = .center
        switchRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fetchButton)
        view.addSubview(switchRow)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            fetchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            switchRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchRow.topAnchor.constraint(equalTo: fetchButton.bottomAnchor, constant: 20),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: switchRow.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        fetchButton.addTarget(self, action: #selector(fetchTapped), for: .touchUpInside)
    }
}
