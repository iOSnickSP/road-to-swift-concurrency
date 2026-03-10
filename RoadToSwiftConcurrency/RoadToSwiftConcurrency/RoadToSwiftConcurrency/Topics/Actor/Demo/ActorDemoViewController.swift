//
//  ActorDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: счётчик через Actor.
//  Counter via Actor.
//

import UIKit

/// TODO: Добавь try? await Task.sleep(nanoseconds: 300_000_000) в начало increment().
/// Add try? await Task.sleep(nanoseconds: 300_000_000) at the start of increment().
actor CounterActor {
    private var count = 0

    func increment() async -> Int {
        // TODO: try? await Task.sleep(nanoseconds: 300_000_000)
        count += 1
        return count
    }
}

@MainActor
final class ActorDemoViewController: UIViewController {

    private let counter = CounterActor()

    private var incrementTask: Task<Void, Never>?

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.accessibilityIdentifier = "actorDemo.add"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .monospacedDigitSystemFont(ofSize: 34, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "actorDemo.count"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Actor Demo"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        setupUI()
        setupActions()
    }

    // TODO: override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); incrementTask?.cancel() }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    @objc private func addTapped() {
        // TODO: incrementTask = Task { let n = await counter.increment(); guard !Task.isCancelled else { return }; countLabel.text = "\(n)" }
    }

    private func setupUI() {
        view.addSubview(addButton)
        view.addSubview(countLabel)

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
}
