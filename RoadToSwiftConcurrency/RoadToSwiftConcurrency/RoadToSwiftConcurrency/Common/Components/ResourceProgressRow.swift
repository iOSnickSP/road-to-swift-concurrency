//
//  ResourceProgressRow.swift
//  RoadToSwiftConcurrency
//
//  Single row: Resource N — waiting | loading | done.
//

import UIKit

enum ResourceProgressState {
    case waiting
    case loading
    case done(String)
}

final class ResourceProgressRow: UIView {

    private(set) var state: ResourceProgressState = .waiting

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .small)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(nameLabel)
        addSubview(spinner)
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 80),

            spinner.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: spinner.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    func configure(name: String) {
        nameLabel.text = name
        setState(.waiting)
    }

    func setState(_ newState: ResourceProgressState) {
        state = newState
        switch newState {
        case .waiting:
            spinner.stopAnimating()
            statusLabel.text = "—"
            statusLabel.textColor = .tertiaryLabel
        case .loading:
            spinner.startAnimating()
            statusLabel.text = "loading..."
            statusLabel.textColor = .systemBlue
        case .done(let result):
            spinner.stopAnimating()
            statusLabel.text = "✓ \(result)"
            statusLabel.textColor = .systemGreen
        }
    }
}
