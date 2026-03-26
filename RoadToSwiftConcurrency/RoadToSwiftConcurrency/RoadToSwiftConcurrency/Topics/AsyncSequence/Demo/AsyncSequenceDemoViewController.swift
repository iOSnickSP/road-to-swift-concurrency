//
//  AsyncSequenceDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: кастомная AsyncSequence и for await.
//  Custom AsyncSequence and for await.
//

import UIKit

/// Последовательность из трёх строковых шагов «1», «2», «3».
/// Sequence of three string steps "1", "2", "3".
struct StepsAsyncSequence: AsyncSequence {
    typealias Element = String

    func makeAsyncIterator() -> Iterator {
        Iterator()
    }

    struct Iterator: AsyncIteratorProtocol {
        // TASK: храни счётчик шага (0…3) и реализуй next() — см. THEORY.md
        // TASK: hold step index (0…3) and implement next() — see THEORY.md

        mutating func next() async -> String? {
            nil
        }
    }
}

@MainActor
final class AsyncSequenceDemoViewController: UIViewController {

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "asyncSequence.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let progressView: ProgressView = {
        let view = ProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncSequence.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncSequence.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalSteps: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AsyncSequence Demo"
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

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        startButton.isEnabled = false
        progressView.reset()
        statusLabel.text = "Running..."
        resultLabel.text = ""

        // TASK: после реализации StepsAsyncSequence.Iterator — Task { for await step in StepsAsyncSequence() { … } },
        // progressView, status "Done", result из шагов, startButton.isEnabled = true. См. Topics/AsyncSequence/THEORY.md
    }
}
