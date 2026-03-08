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

    // Результаты загрузки. Обновляются только на main / Results, updated on main only
    private var results: [String] = []

    // Счётчик запущенных задач — нужен для корректного leave() при Cancel.
    // Counter of started tasks — needed for correct leave() on Cancel.
    // Work item, который уже запущен, вызовет leave() сам; отменённые — не запустятся, leave() делаем вручную.
    // A running work item will leave() itself; cancelled ones won't run, we leave() manually.
    private let lock = NSLock()
    private var _startedTasksCounter = 0

    private var startedTasksCounter: Int {
        lock.lock()
        defer { lock.unlock() }
        return _startedTasksCounter
    }

    private func incrementStartedTasksCounter() {
        lock.lock()
        defer { lock.unlock() }
        _startedTasksCounter += 1
    }

    // Для Cancel: отменяем work items, вызываем leave() для отменённых.
    // For Cancel: cancel work items, call leave() for cancelled ones.
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

        // Сброс состояния для повторного Load / Reset state for repeated Load
        workItems.removeAll()
        results.removeAll()
        lock.lock()
        _startedTasksCounter = 0
        lock.unlock()

        // Serial queue — задачи выполняются по одной, Cancel может «догнать» ещё не запущенные.
        // Serial queue — tasks run one by one, Cancel can catch those not yet started.
        let queue = DispatchQueue(label: "com.example.load", qos: .userInitiated)
        let group = DispatchGroup()
        self.group = group

        for i in 0..<totalTasks {
            workItems.append(DispatchWorkItem { [weak self] in
                // self == nil → leave() и выходим, иначе группа «зависнет».
                // self == nil → leave() and exit, otherwise group will hang.
                guard let self else {
                    group.leave()
                    return
                }
                defer { group.leave() }

                // Сразу помечаем «запущен» — для Cancel важно знать, кто уже в работе.
                // Mark as started immediately — Cancel needs to know who's already running.
                self.incrementStartedTasksCounter()
                let result = self.loadResource(id: i)

                // UI — только на main / UI — main only
                DispatchQueue.main.async { [weak self] in
                    guard let self, self.view.window != nil else { return }
                    self.results.append(result)
                    self.resultLabel.text = self.results.joined(separator: ",\n")
                    self.progressView.setProgress(
                        CGFloat(self.results.count) / CGFloat(self.totalTasks),
                        animated: true
                    )
                }
            })
        }

        // enter() перед async, leave() — внутри work item (defer).
        // enter() before async, leave() — inside work item (defer).
        for workItem in workItems {
            group.enter()
            queue.async(execute: workItem)
        }

        // Вызовется, когда все enter/leave сбалансированы (counter == 0).
        // Fires when all enter/leave are balanced (counter == 0).
        group.notify(queue: .main) { [weak self] in
            guard let self, self.view.window != nil else { return }
            self.loadButton.isEnabled = true
            self.cancelButton.isEnabled = false
            self.statusLabel.text = "Done"
            self.resultLabel.text = self.results.joined(separator: ",\n")
        }
    }

    @objc private func cancelTapped() {
        cancelButton.isEnabled = false

        // Отменяем все — уже запущенные продолжат (cancel не прерывает), остальные не запустятся.
        // Cancel all — running ones continue (cancel doesn't interrupt), others won't start.
        workItems.forEach { $0.cancel() }

        // Отменённые work items не выполнятся → не вызовут leave(). Вызываем вручную.
        // Cancelled work items won't run → won't leave(). We call leave() manually.
        for _ in 0..<(totalTasks - startedTasksCounter) {
            group?.leave()
        }

        DispatchQueue.main.async { [weak self] in
            guard let self, self.view.window != nil else { return }
            self.loadButton.isEnabled = true
            self.cancelButton.isEnabled = false
            self.statusLabel.text = "Cancelled"
        }
    }

    /// Симулирует загрузку ресурса. Вызывать только из фонового потока.
    /// Simulates resource load. Call from background thread only.
    private func loadResource(id: Int) -> String {
        SimulatedNetworkService.fetchResourceSync(id: id)
    }
}
