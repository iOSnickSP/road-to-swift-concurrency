//
//  ActorDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: счётчик через Actor.
//  Counter via Actor.
//

import UIKit

/// Actor изолирует состояние — доступ только через await. Сериализует вызовы increment().
/// Actor isolates state — access only via await. Serializes increment() calls.
actor CounterActor {
    private var count = 0

    /// Увеличивает на 1. Task.sleep — для наглядности сериализации при быстрых нажатиях.
    /// Increments by 1. Task.sleep — to show serialization on rapid taps.
    func increment() async -> Int {
        try? await Task.sleep(nanoseconds: 300_000_000)
        count += 1
        return count
    }
}

@MainActor
final class ActorDemoViewController: UIViewController {

    // MARK: - State

    private let counter = CounterActor()

    /// Текущая задача. Отменяется при уходе с экрана.
    /// Current task. Cancelled when leaving screen.
    private var incrementTask: Task<Void, Never>?

    // MARK: - UI

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        incrementTask?.cancel()
    }

    // MARK: - Actions

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    @objc private func addTapped() {
        incrementTask = Task {
            let n = await counter.increment()
            guard !Task.isCancelled else { return }
            countLabel.text = "\(n)"
        }
    }

    // MARK: - Layout

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
