//
//  AsyncAwaitDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: загрузка данных через async/await.
//  Data loading via async/await.
//

import UIKit

/// UIViewController изолирован на MainActor — все UI-операции гарантированно на main thread.
/// @MainActor isolates the controller on main thread — all UI updates are safe.
@MainActor
final class AsyncAwaitDemoViewController: UIViewController {

    // MARK: - UI

    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load", for: .normal)
        button.accessibilityIdentifier = "asyncAwait.load"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Load"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "asyncAwait.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Текущая задача загрузки. Нужна для отмены при dismiss — иначе Task продолжит работу
    /// и попытается обновить UI уже закрытого контроллера.
    /// Current load task. Cancelled on dismiss to avoid updating UI of a dismissed controller.
    private var loadTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Async/Await Demo"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        setupUI()
        setupActions()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Отменяем загрузку при уходе с экрана — Task.sleep прервётся, UI не обновится.
        // Cancel load when leaving screen — Task.sleep will be interrupted, no UI update.
        loadTask?.cancel()
    }

    // MARK: - Actions

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    /// @objc-методы синхронны — нельзя вызывать await напрямую. Task { } создаёт async-контекст
    /// и наследует MainActor от класса, поэтому closure выполнится на main.
    /// @objc methods are sync — can't use await. Task { } creates async context and inherits MainActor.
    @objc private func loadTapped() {
        loadButton.isEnabled = false
        activityIndicator.startAnimating()

        loadTask = Task {
            // await приостанавливает выполнение, но не блокирует main thread — runtime переключается
            // на другую работу. После возврата из loadData() мы снова на main (MainActor).
            // await suspends execution without blocking main — runtime switches to other work.
            let result = await loadData()

            // Task мог быть отменён (пользователь закрыл экран). Проверяем перед обновлением UI.
            // Task may have been cancelled (user dismissed). Check before updating UI.
            guard !Task.isCancelled else { return }

            resultLabel.text = result
            activityIndicator.stopAnimating()
            loadButton.isEnabled = true
        }
    }

    // MARK: - Data Loading

    /// Асинхронная загрузка. Вызывать только с await внутри async-контекста (Task или async func).
    /// Simulates 2 sec load. Call only with await inside async context (Task or async func).
    private func loadData() async -> String {
        await SimulatedNetworkService.fetchText(delay: 2)
    }
}

// MARK: - Layout

private extension AsyncAwaitDemoViewController {

    func setupUI() {
        view.addSubview(loadButton)
        view.addSubview(activityIndicator)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 24)
        ])
    }

    func setupActions() {
        loadButton.addTarget(self, action: #selector(loadTapped), for: .touchUpInside)
    }
}
