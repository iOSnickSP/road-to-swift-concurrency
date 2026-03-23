//
//  TaskGroupDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: параллельная загрузка 3 ресурсов через TaskGroup.
//  Parallel load of 3 resources via TaskGroup.
//

import UIKit

@MainActor
final class TaskGroupDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load All", for: .normal)
        button.accessibilityIdentifier = "taskGroup.loadAll"
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
        label.accessibilityIdentifier = "taskGroup.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "taskGroup.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalTasks = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TaskGroup Demo"
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
            let results = await withTaskGroup(of: String.self) { group in
                for id in 0..<totalTasks {
                    group.addTask {
                        await SimulatedNetworkService.fetchResource(id: id)
                    }
                }
                var collected: [String] = []
                for await result in group {
                    collected.append(result)
                    progressView.setProgress(CGFloat(collected.count) / CGFloat(totalTasks), animated: true)
                }
                return collected
            }
            statusLabel.text = "Done"
            resultLabel.text = results.joined(separator: ", ")
            loadButton.isEnabled = true
        }
    }
}
