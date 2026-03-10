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
        // 1. Отмена старого таймера — защита от двойного Start / Cancel old timer — double Start guard
        timer?.cancel()
        timer = nil

        // 2. Сброс состояния и UI / Reset state and UI
        _seconds = 0
        valueLabel.text = "0"
        startButton.isEnabled = false
        statusLabel.text = "Running"

        // 3. Создание таймера на своей очереди (не RunLoop) / Create timer on its own queue (not RunLoop)
        let newTimer = DispatchSource.makeTimerSource(queue: queue)
        self.timer = newTimer
        newTimer.schedule(deadline: .now(), repeating: 1.0)

        // 4. Обработчик тика — выполняется на queue / Tick handler — runs on queue
        newTimer.setEventHandler { [weak self] in
            guard let self else { return }
            self._seconds += 1
            // Захватываем count на queue, передаём в main — избегаем data race (чтение _seconds с main)
            // Capture count on queue, pass to main — avoid data race (reading _seconds from main)
            let count = self._seconds
            DispatchQueue.main.async { [weak self] in
                guard let self, self.view.window != nil else { return }
                self.valueLabel.text = "\(count)"
            }
        }

        // 5. При отмене — сброс и включение Start / On cancel — reset and re-enable Start
        newTimer.setCancelHandler { [weak self] in
            guard let self else { return }
            self._seconds = 0
            DispatchQueue.main.async { [weak self] in
                guard let self, self.view.window != nil else { return }
                self.startButton.isEnabled = true
            }
        }

        // 6. resume() обязателен — без него таймер не запустится / resume() required — timer won't start without it
        newTimer.resume()
    }

    @objc private func stopTapped() {
        timer?.cancel()
        timer = nil
        // Синхронно включаем Start — cancel handler асинхронный, тест может tap до его выполнения
        // Enable Start synchronously — cancel handler is async, test may tap before it runs
        startButton.isEnabled = true
        statusLabel.text = "Stopped"
    }
}
