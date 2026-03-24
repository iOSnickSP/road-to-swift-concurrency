//
//  ViewController.swift
//  RoadToSwiftConcurrency
//
//  Created by Сергей Вихляев on 07.03.2026.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - GCD (по возрастанию сложности)

    private let gcdDemoButton: UIButton = makeTopicButton(title: "GCD Demo", id: "topics.gcdDemo")
    private let dispatchGroupButton: UIButton = makeTopicButton(title: "DispatchGroup Demo", id: "topics.dispatchGroupDemo")
    private let dispatchSemaphoreButton: UIButton = makeTopicButton(title: "DispatchSemaphore Demo", id: "topics.dispatchSemaphoreDemo")
    private let dispatchWorkItemButton: UIButton = makeTopicButton(title: "DispatchWorkItem Demo", id: "topics.dispatchWorkItemDemo")
    private let dispatchBarrierButton: UIButton = makeTopicButton(title: "DispatchBarrier Demo", id: "topics.dispatchBarrierDemo")
    private let dispatchSourceButton: UIButton = makeTopicButton(title: "DispatchSource Demo", id: "topics.dispatchSourceDemo")
    private let operationQueueButton: UIButton = makeTopicButton(title: "OperationQueue Demo", id: "topics.operationQueueDemo")
    private let concurrentPerformButton: UIButton = makeTopicButton(title: "concurrentPerform Demo", id: "topics.concurrentPerformDemo")

    // MARK: - Modern Concurrency

    private let asyncAwaitButton: UIButton = makeTopicButton(title: "Async/Await Demo", id: "topics.asyncAwaitDemo")
    private let taskGroupDemoButton: UIButton = makeTopicButton(title: "TaskGroup Demo", id: "topics.taskGroupDemo")
    private let asyncLetDemoButton: UIButton = makeTopicButton(title: "async let Demo", id: "topics.asyncLetDemo")
    private let actorDemoButton: UIButton = makeTopicButton(title: "Actor Demo", id: "topics.actorDemo")
    private let sendableDemoButton: UIButton = makeTopicButton(title: "Sendable Demo", id: "topics.sendableDemo")
    private let uncheckedSendableDemoButton: UIButton = makeTopicButton(title: "@unchecked Sendable Demo", id: "topics.uncheckedSendableDemo")
    private let serialExecutorDemoButton: UIButton = makeTopicButton(title: "SerialExecutor Demo", id: "topics.serialExecutorDemo")

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Topics"
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let gcdLabel = makeSectionLabel("GCD")
        let gcdButtons: [UIButton] = [
            gcdDemoButton, dispatchGroupButton, dispatchSemaphoreButton, dispatchWorkItemButton,
            dispatchBarrierButton, dispatchSourceButton, operationQueueButton, concurrentPerformButton
        ]
        let gcdStack = makeSectionStack(header: gcdLabel, buttons: gcdButtons)

        let modernLabel = makeSectionLabel("Modern Concurrency")
        let modernButtons: [UIButton] = [
            asyncAwaitButton, taskGroupDemoButton, asyncLetDemoButton, actorDemoButton, sendableDemoButton,
            uncheckedSendableDemoButton, serialExecutorDemoButton
        ]
        let modernStack = makeSectionStack(header: modernLabel, buttons: modernButtons)

        contentStack.addArrangedSubview(gcdStack)
        contentStack.addArrangedSubview(modernStack)

        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }

    private func makeSectionStack(header: UILabel, buttons: [UIButton]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.addArrangedSubview(header)
        buttons.forEach { stack.addArrangedSubview($0) }
        return stack
    }

    private static func makeTopicButton(title: String, id: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = id
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupActions() {
        gcdDemoButton.addTarget(self, action: #selector(openGCDDemo), for: .touchUpInside)
        dispatchGroupButton.addTarget(self, action: #selector(openDispatchGroupDemo), for: .touchUpInside)
        dispatchSemaphoreButton.addTarget(self, action: #selector(openDispatchSemaphoreDemo), for: .touchUpInside)
        dispatchWorkItemButton.addTarget(self, action: #selector(openDispatchWorkItemDemo), for: .touchUpInside)
        dispatchBarrierButton.addTarget(self, action: #selector(openDispatchBarrierDemo), for: .touchUpInside)
        dispatchSourceButton.addTarget(self, action: #selector(openDispatchSourceDemo), for: .touchUpInside)
        operationQueueButton.addTarget(self, action: #selector(openOperationQueueDemo), for: .touchUpInside)
        concurrentPerformButton.addTarget(self, action: #selector(openConcurrentPerformDemo), for: .touchUpInside)
        asyncAwaitButton.addTarget(self, action: #selector(openAsyncAwaitDemo), for: .touchUpInside)
        taskGroupDemoButton.addTarget(self, action: #selector(openTaskGroupDemo), for: .touchUpInside)
        asyncLetDemoButton.addTarget(self, action: #selector(openAsyncLetDemo), for: .touchUpInside)
        actorDemoButton.addTarget(self, action: #selector(openActorDemo), for: .touchUpInside)
        sendableDemoButton.addTarget(self, action: #selector(openSendableDemo), for: .touchUpInside)
        uncheckedSendableDemoButton.addTarget(self, action: #selector(openUncheckedSendableDemo), for: .touchUpInside)
        serialExecutorDemoButton.addTarget(self, action: #selector(openSerialExecutorDemo), for: .touchUpInside)
    }

    @objc private func openSerialExecutorDemo() {
        let demo = SerialExecutorDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openUncheckedSendableDemo() {
        let demo = UncheckedSendableDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openSendableDemo() {
        let demo = SendableDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openActorDemo() {
        let demo = ActorDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openTaskGroupDemo() {
        let demo = TaskGroupDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openAsyncLetDemo() {
        let demo = AsyncLetDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openAsyncAwaitDemo() {
        let demo = AsyncAwaitDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openConcurrentPerformDemo() {
        let demo = ConcurrentPerformDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openOperationQueueDemo() {
        let demo = OperationQueueDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openDispatchSourceDemo() {
        let demo = DispatchSourceDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openDispatchBarrierDemo() {
        let demo = DispatchBarrierDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openDispatchWorkItemDemo() {
        let demo = DispatchWorkItemDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openDispatchSemaphoreDemo() {
        let demo = DispatchSemaphoreDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openDispatchGroupDemo() {
        let demo = DispatchGroupDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }

    @objc private func openGCDDemo() {
        let demo = GCDDemoViewController()
        let nav = UINavigationController(rootViewController: demo)
        present(nav, animated: true)
    }
}

