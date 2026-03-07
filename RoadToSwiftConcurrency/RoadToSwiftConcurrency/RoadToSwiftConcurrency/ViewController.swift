//
//  ViewController.swift
//  RoadToSwiftConcurrency
//
//  Created by Сергей Вихляев on 07.03.2026.
//

import UIKit

class ViewController: UIViewController {

    private let gcdDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GCD Demo", for: .normal)
        button.accessibilityIdentifier = "topics.gcdDemo"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dispatchGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("DispatchGroup Demo", for: .normal)
        button.accessibilityIdentifier = "topics.dispatchGroupDemo"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dispatchSemaphoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("DispatchSemaphore Demo", for: .normal)
        button.accessibilityIdentifier = "topics.dispatchSemaphoreDemo"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dispatchWorkItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("DispatchWorkItem Demo", for: .normal)
        button.accessibilityIdentifier = "topics.dispatchWorkItemDemo"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Topics"
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(gcdDemoButton)
        view.addSubview(dispatchGroupButton)
        view.addSubview(dispatchSemaphoreButton)
        view.addSubview(dispatchWorkItemButton)
        NSLayoutConstraint.activate([
            gcdDemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gcdDemoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),

            dispatchGroupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dispatchGroupButton.topAnchor.constraint(equalTo: gcdDemoButton.bottomAnchor, constant: 16),

            dispatchSemaphoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dispatchSemaphoreButton.topAnchor.constraint(equalTo: dispatchGroupButton.bottomAnchor, constant: 16),

            dispatchWorkItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dispatchWorkItemButton.topAnchor.constraint(equalTo: dispatchSemaphoreButton.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        gcdDemoButton.addTarget(self, action: #selector(openGCDDemo), for: .touchUpInside)
        dispatchGroupButton.addTarget(self, action: #selector(openDispatchGroupDemo), for: .touchUpInside)
        dispatchSemaphoreButton.addTarget(self, action: #selector(openDispatchSemaphoreDemo), for: .touchUpInside)
        dispatchWorkItemButton.addTarget(self, action: #selector(openDispatchWorkItemDemo), for: .touchUpInside)
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

