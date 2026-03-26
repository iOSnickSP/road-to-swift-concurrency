//
//  AsyncAwaitDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: загрузка данных через async/await.
//  Data loading via async/await.
//

import UIKit

final class AsyncAwaitDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load", for: .normal)
        button.accessibilityIdentifier = "asyncAwait.load"
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
        label.accessibilityIdentifier = "asyncAwait.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Async/Await Demo"
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
        loadButton.addTarget(self, action: #selector(loadTapped), for: .touchUpInside)
    }

    @objc private func loadTapped() {
        // TASK: Task { loadButton.isEnabled = false, activityIndicator.startAnimating(),
        // let result = await loadData(), resultLabel.text = result, activityIndicator.stopAnimating(), loadButton.isEnabled = true }
    }

    /// Симулирует загрузку данных (2 сек). Вызывать с await.
    /// Simulates data load (2 sec). Call with await.
    private func loadData() async -> String {
        await LoadSimulators.asyncSimulateLoad(delay: 2)
    }
}
