//
//  UncheckedSendableDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: ThreadSafeBox с @unchecked Sendable.
//  Thread-safe wrapper with @unchecked Sendable.
//

import UIKit

/// TODO: Добавь : @unchecked Sendable — lock защищает доступ, класс потокобезопасен.
/// Add : @unchecked Sendable — lock protects access, class is thread-safe.
final class ThreadSafeBox<T> {
    private let lock = NSLock()
    private var _value: T?

    func get() -> T? {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func set(_ value: T?) {
        lock.lock()
        defer { lock.unlock() }
        _value = value
    }
}

@MainActor
final class UncheckedSendableDemoViewController: UIViewController {

    private let box = ThreadSafeBox<String>()

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter text"
        field.borderStyle = .roundedRect
        field.accessibilityIdentifier = "uncheckedSendable.input"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let storeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Store", for: .normal)
        button.accessibilityIdentifier = "uncheckedSendable.store"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let retrieveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retrieve", for: .normal)
        button.accessibilityIdentifier = "uncheckedSendable.retrieve"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Retrieve to get value"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "uncheckedSendable.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "@unchecked Sendable Demo"
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

    @objc private func storeTapped() {
        let text = textField.text ?? ""
        Task {
            box.set(text)
        }
    }

    @objc private func retrieveTapped() {
        Task {
            let value = box.get()
            resultLabel.text = value ?? "(empty)"
        }
    }

    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(storeButton)
        view.addSubview(retrieveButton)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            textField.heightAnchor.constraint(equalToConstant: 44),

            storeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            storeButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            retrieveButton.leadingAnchor.constraint(equalTo: storeButton.trailingAnchor, constant: 16),
            retrieveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: storeButton.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        storeButton.addTarget(self, action: #selector(storeTapped), for: .touchUpInside)
        retrieveButton.addTarget(self, action: #selector(retrieveTapped), for: .touchUpInside)
    }
}
