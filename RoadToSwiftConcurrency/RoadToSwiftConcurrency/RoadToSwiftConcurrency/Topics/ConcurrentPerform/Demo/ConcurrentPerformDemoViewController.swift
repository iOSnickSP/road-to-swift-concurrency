//
//  ConcurrentPerformDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: параллельная обработка через concurrentPerform.
//  Parallel processing via concurrentPerform.
//

import UIKit

final class ConcurrentPerformDemoViewController: UIViewController {

    private let processButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Process", for: .normal)
        button.accessibilityIdentifier = "concurrentPerform.process"
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
        label.text = "Tap Process"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "concurrentPerform.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "concurrentPerform.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalItems = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "concurrentPerform Demo"
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
        view.addSubview(processButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            processButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            processButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressView.topAnchor.constraint(equalTo: processButton.bottomAnchor, constant: 24),
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
        processButton.addTarget(self, action: #selector(processTapped), for: .touchUpInside)
    }

    @objc private func processTapped() {
        processButton.isEnabled = false
        progressView.reset()
        statusLabel.text = "Processing..."
        resultLabel.text = ""

        // TASK: DispatchQueue.global().async {
        //   var results = [String](repeating: "", count: totalItems)
        //   DispatchQueue.concurrentPerform(iterations: totalItems) { index in
        //     results[index] = SimulatedNetworkService.fetchResourceSync(id: index, delay: 0.5)
        //   }
        //   DispatchQueue.main.async { progress = 1, status, result, enable button }
        // }
    }
}
