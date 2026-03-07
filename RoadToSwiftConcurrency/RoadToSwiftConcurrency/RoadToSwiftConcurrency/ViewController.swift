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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Topics"
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(gcdDemoButton)
        view.addSubview(dispatchGroupButton)
        NSLayoutConstraint.activate([
            gcdDemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gcdDemoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),

            dispatchGroupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dispatchGroupButton.topAnchor.constraint(equalTo: gcdDemoButton.bottomAnchor, constant: 16)
        ])
    }

    private func setupActions() {
        gcdDemoButton.addTarget(self, action: #selector(openGCDDemo), for: .touchUpInside)
        dispatchGroupButton.addTarget(self, action: #selector(openDispatchGroupDemo), for: .touchUpInside)
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

