//
//  DispatchWorkItemDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: загрузка 3 ресурсов последовательно, отмена через DispatchWorkItem.
//  Load 3 resources sequentially, cancel via DispatchWorkItem.
//

import UIKit

final class DispatchWorkItemDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load", for: .normal)
        button.accessibilityIdentifier = "dispatchWorkItem.load"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.accessibilityIdentifier = "dispatchWorkItem.cancel"
        button.isEnabled = false
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
        label.text = "Tap Load"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchWorkItem.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchWorkItem.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalTasks = 3

    // Store work items and group for cancel to access
    private var workItems: [DispatchWorkItem] = []
    private var group: DispatchGroup?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DispatchWorkItem Demo"
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
        view.addSubview(cancelButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
            cancelButton.topAnchor.constraint(equalTo: loadButton.topAnchor),

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
        loadButton.addTarget(self, action: #selector(loadTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func loadTapped() {
        loadButton.isEnabled = false
        cancelButton.isEnabled = true
        progressView.reset()
        statusLabel.text = "Loading..."
        resultLabel.text = ""

        // TASK: Serial queue + 3 DispatchWorkItem, Group, leave() on cancel for remaining, notify → Done/Cancelled
    }

    @objc private func cancelTapped() {
        // TASK: cancel work items, leave() for cancelled
    }

    /// Симулирует загрузку ресурса. Вызывать только из фонового потока.
    private func loadResource(id: Int) -> String {
        LoadSimulators.dispatchGroupLoadResource(id: id)
    }
}
