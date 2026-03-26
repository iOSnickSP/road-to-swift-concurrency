//
//  DispatchSemaphoreDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: загрузка 5 ресурсов, не более 2 одновременно (DispatchSemaphore).
//  Load 5 resources, max 2 concurrent (DispatchSemaphore).
//

import UIKit

final class DispatchSemaphoreDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load All", for: .normal)
        button.accessibilityIdentifier = "dispatchSemaphore.loadAll"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Load All"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchSemaphore.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resourceStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let progressView: ProgressView = {
        let view = ProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchSemaphore.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var resourceRows: [ResourceProgressRow] = []
    private let totalTasks = 5
    private let maxConcurrent = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DispatchSemaphore Demo"
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
        view.addSubview(statusLabel)
        view.addSubview(activeLabel)
        view.addSubview(resourceStackView)
        view.addSubview(progressView)
        view.addSubview(resultLabel)

        for i in 0..<totalTasks {
            let row = ResourceProgressRow()
            row.configure(name: "Resource \(i)")
            row.heightAnchor.constraint(equalToConstant: 28).isActive = true
            resourceStackView.addArrangedSubview(row)
            resourceRows.append(row)
        }

        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 16),

            activeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            activeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),

            resourceStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resourceStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resourceStackView.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 16),

            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressView.topAnchor.constraint(equalTo: resourceStackView.bottomAnchor, constant: 20),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16)
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
        resourceRows.forEach { $0.setState(.waiting) }

        // TASK: Semaphore(maxConcurrent) + Group, 5 tasks, wait/signal in defer, row states + progress on main, notify → result
    }

    /// Симулирует загрузку ресурса. Вызывать только из фонового потока.
    /// Simulates resource load. Call only from background thread.
    private func loadResource(id: Int) -> String {
        SimulatedNetworkService.fetchResourceSync(id: id)
    }
}
