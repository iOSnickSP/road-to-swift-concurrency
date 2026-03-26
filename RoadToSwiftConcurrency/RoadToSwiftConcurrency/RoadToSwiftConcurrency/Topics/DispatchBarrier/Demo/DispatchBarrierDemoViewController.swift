//
//  DispatchBarrierDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: thread-safe счётчик через DispatchQueue.barrier.
//  Thread-safe counter via DispatchQueue.barrier.
//

import UIKit

final class DispatchBarrierDemoViewController: UIViewController {

    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Increment", for: .normal)
        button.accessibilityIdentifier = "dispatchBarrier.increment"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let readButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read", for: .normal)
        button.accessibilityIdentifier = "dispatchBarrier.read"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.accessibilityIdentifier = "dispatchBarrier.value"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Increment or Read"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchBarrier.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Concurrent queue + storage, доступ только через queue / access only via queue
    private let queue = DispatchQueue(label: "com.example.counter", attributes: .concurrent)
    private var _count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DispatchBarrier Demo"
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
        view.addSubview(incrementButton)
        view.addSubview(readButton)
        view.addSubview(valueLabel)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            incrementButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            readButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
            readButton.topAnchor.constraint(equalTo: incrementButton.topAnchor),

            valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: incrementButton.bottomAnchor, constant: 40),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        readButton.addTarget(self, action: #selector(readTapped), for: .touchUpInside)
    }

    @objc private func incrementTapped() {
        statusLabel.text = "Incrementing..."
        // TASK: queue.async(flags: .barrier) { _count += 1 }, main.async status = "Incremented"
    }

    @objc private func readTapped() {
        // TASK: queue.sync { count }, main.async valueLabel.text = "\(count)"
    }
}
