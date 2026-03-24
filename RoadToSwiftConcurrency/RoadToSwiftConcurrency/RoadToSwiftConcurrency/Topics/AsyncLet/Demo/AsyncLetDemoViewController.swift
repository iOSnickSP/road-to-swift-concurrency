//
//  AsyncLetDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: параллельная загрузка трёх ресурсов через async let.
//  Parallel load of three resources via async let.
//

import UIKit

@MainActor
final class AsyncLetDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load All", for: .normal)
        button.accessibilityIdentifier = "asyncLet.loadAll"
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
        label.text = "Tap Load All"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncLet.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncLet.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "async let Demo"
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
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressView.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 24),
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
        loadButton.addTarget(self, action: #selector(loadAllTapped), for: .touchUpInside)
    }

    @objc private func loadAllTapped() {
        loadButton.isEnabled = false
        progressView.reset()
        statusLabel.text = "Loading..."
        resultLabel.text = ""

        Task {
            // TODO: три async let для id 0, 1, 2 и LoadSimulators.taskGroupLoadResource(id:)
            // TODO: await (кортеж) — затем progressView.setProgress(1, ...), status "Done", resultLabel с объединённым текстом
            loadButton.isEnabled = true
        }
    }
}
