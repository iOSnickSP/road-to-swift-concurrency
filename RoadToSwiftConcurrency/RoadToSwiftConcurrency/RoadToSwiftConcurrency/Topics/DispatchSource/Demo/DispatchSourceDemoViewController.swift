//
//  DispatchSourceDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: секундомер через DispatchSource.timer.
//  Stopwatch via DispatchSource.timer.
//

import UIKit

final class DispatchSourceDemoViewController: UIViewController {

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.accessibilityIdentifier = "dispatchSource.start"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.accessibilityIdentifier = "dispatchSource.stop"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.accessibilityIdentifier = "dispatchSource.value"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Start to begin"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchSource.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let queue = DispatchQueue(label: "com.example.timer")
    private var timer: DispatchSourceTimer?
    private var _seconds = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DispatchSource Demo"
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
        timer?.cancel()
        timer = nil
        dismiss(animated: true)
    }

    private func setupUI() {
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(valueLabel)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
            stopButton.topAnchor.constraint(equalTo: startButton.topAnchor),

            valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 40),

            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statusLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        statusLabel.text = "Running"
        // TASK: cancel existing timer, reset _seconds, create DispatchSource.makeTimerSource(queue:),
        // schedule(deadline: .now(), repeating: 1), setEventHandler { _seconds += 1; main.async update UI },
        // resume()
    }

    @objc private func stopTapped() {
        // TASK: timer?.cancel(), timer = nil, status = "Stopped"
    }
}
