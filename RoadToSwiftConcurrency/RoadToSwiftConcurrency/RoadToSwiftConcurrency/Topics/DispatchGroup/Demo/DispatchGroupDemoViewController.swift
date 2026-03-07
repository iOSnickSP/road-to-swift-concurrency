//
//  DispatchGroupDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: параллельная загрузка 3 ресурсов через DispatchGroup.
//  Parallel load of 3 resources via DispatchGroup.
//

import UIKit

final class DispatchGroupDemoViewController: UIViewController {

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load All", for: .normal)
        button.accessibilityIdentifier = "dispatchGroup.loadAll"
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
        label.accessibilityIdentifier = "dispatchGroup.status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "dispatchGroup.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalTasks = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DispatchGroup Demo"
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

        // TODO: 1. Создать DispatchGroup / Create DispatchGroup
        // TODO: 2. Запустить 3 параллельные задачи / Start 3 parallel tasks on DispatchQueue.global(qos: .userInitiated)
        //       Для каждой: group.enter() в начале, defer { group.leave() } в блоке
        //       Внутри: вызвать loadResource(id:), получить результат
        //       После каждой завершённой задачи: на main queue обновить progressView и statusLabel
        //       (progress = completedCount / totalTasks, status = "Loaded X of 3")
        // TODO: 3. group.notify(queue: .main) { ... } — когда все готовы / when all complete:
        //       обновить resultLabel, включить кнопку, statusLabel = "Done"
    }

    /// Симулирует загрузку ресурса. Вызывать только из фонового потока.
    /// Simulates resource load. Call only from background thread.
    private func loadResource(id: Int) -> String {
        LoadSimulators.dispatchGroupLoadResource(id: id)
    }
}
