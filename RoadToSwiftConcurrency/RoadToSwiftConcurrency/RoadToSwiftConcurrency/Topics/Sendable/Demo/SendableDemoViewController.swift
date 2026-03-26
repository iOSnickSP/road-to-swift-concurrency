//
//  SendableDemoViewController.swift
//  RoadToSwiftConcurrency
//
//  Демо / Demo: Message Relay — передача данных через границу Actor.
//  Data passing across Actor boundary. RelayMessage must be Sendable.
//

import UIKit

/// Сообщение для передачи в Actor. Должен быть Sendable.
/// Message for passing to Actor. Must be Sendable.
struct RelayMessage {
    let id: UUID
    let text: String
    let createdAt: Date
    let source: UIViewController  // TASK: сделай весь тип Sendable (см. THEORY.md)
}

actor MessageRelay {
    private var lastMessage: RelayMessage?

    func send(_ message: RelayMessage) async {
        lastMessage = message
    }

    func receive() async -> RelayMessage? {
        lastMessage
    }
}

@MainActor
final class SendableDemoViewController: UIViewController {

    private let relay = MessageRelay()

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter message"
        field.borderStyle = .roundedRect
        field.accessibilityIdentifier = "sendableDemo.input"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.accessibilityIdentifier = "sendableDemo.send"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let receiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Receive", for: .normal)
        button.accessibilityIdentifier = "sendableDemo.receive"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Receive to get message"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "sendableDemo.result"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sendable Demo"
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

    @objc private func sendTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        let message = RelayMessage(
            id: UUID(),
            text: text,
            createdAt: Date(),
            source: self
        )
        Task {
            await relay.send(message)
        }
    }

    @objc private func receiveTapped() {
        Task {
            let message = await relay.receive()
            resultLabel.text = message?.text ?? "(empty)"
        }
    }

    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(sendButton)
        view.addSubview(receiveButton)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            textField.heightAnchor.constraint(equalToConstant: 44),

            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            receiveButton.leadingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 16),
            receiveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resultLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 24)
        ])
    }

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveTapped), for: .touchUpInside)
    }
}
