//
//  GCDDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Задание / Task: загрузка данных в фоне, обновление UI на main queue.
//  Load data in background, update UI on main queue.
//  Теория / Theory — см. THEORY.md в папке GCD.
//

import UIKit

final class GCDDemoViewController: UIViewController {

    // MARK: - UI

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load", for: .normal)
        button.accessibilityIdentifier = "gcd.load"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Load"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "gcd.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GCD Demo"
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

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(loadButton)
        view.addSubview(activityIndicator)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func loadButtonTapped() {
        // TASK: global.async → simulateLoad() → main.async → update UI
    }

    /// Симулирует загрузку данных (2 секунды). Вызывать только из фонового потока.
    /// Simulates data load (2 sec). Call only from background thread.
    private func simulateLoad() -> String {
        SimulatedNetworkService.fetchTextSync(delay: 2)
    }
}
