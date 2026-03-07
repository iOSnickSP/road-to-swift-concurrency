//
//  ProgressView.swift
//  RoadToSwiftConcurrency
//
//  Переиспользуемый UI-компонент для отображения прогресса (0...1).
//  Reusable UI component for displaying progress (0...1).
//

import UIKit

/// Горизонтальный прогресс-бар. Переиспользуемый компонент.
/// Horizontal progress bar. Reusable component.
final class ProgressView: UIView {

    // MARK: - Public

    /// Прогресс от 0 до 1. Обновление UI — только с main thread.
    /// Progress 0 to 1. UI updates — main thread only.
    var progress: CGFloat {
        get { _progress }
        set { setProgress(newValue, animated: false) }
    }

    /// Цвет заполненной части / Fill color
    var progressColor: UIColor = .systemBlue {
        didSet { fillLayer.backgroundColor = progressColor.cgColor }
    }

    /// Цвет фона (трек) / Track (background) color
    var trackColor: UIColor = .systemGray5 {
        didSet { trackLayer.backgroundColor = trackColor.cgColor }
    }

    /// Высота бара / Bar height
    var barHeight: CGFloat = 8 {
        didSet { setNeedsLayout() }
    }

    /// Скругление углов / Corner radius
    var cornerRadius: CGFloat = 4 {
        didSet {
            trackLayer.cornerRadius = cornerRadius
            fillLayer.cornerRadius = cornerRadius
        }
    }

    // MARK: - Private

    private var _progress: CGFloat = 0

    private let trackLayer: CALayer = {
        let layer = CALayer()
        layer.masksToBounds = true
        return layer
    }()

    private let fillLayer: CALayer = {
        let layer = CALayer()
        layer.masksToBounds = true
        return layer
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(fillLayer)
        trackLayer.backgroundColor = trackColor.cgColor
        fillLayer.backgroundColor = progressColor.cgColor
        trackLayer.cornerRadius = cornerRadius
        fillLayer.cornerRadius = cornerRadius
        fillLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        backgroundColor = .clear
    }

    // MARK: - Layout

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard layer == self.layer else { return }

        let y = (bounds.height - barHeight) / 2
        trackLayer.frame = CGRect(x: 0, y: y, width: bounds.width, height: barHeight)

        let fillWidth = bounds.width * max(0, min(1, _progress))
        fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)
        fillLayer.bounds = CGRect(x: 0, y: 0, width: fillWidth, height: barHeight)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: barHeight)
    }

    // MARK: - Public API

    /// Установить прогресс с опциональной анимацией / Set progress with optional animation
    func setProgress(_ value: CGFloat, animated: Bool) {
        let clamped = max(0, min(1, value))
        let oldProgress = _progress
        _progress = clamped

        if animated, bounds.width > 0 {
            let oldWidth = bounds.width * max(0, min(1, oldProgress))
            let newWidth = bounds.width * clamped
            fillLayer.bounds = CGRect(x: 0, y: 0, width: newWidth, height: barHeight)
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: oldWidth, height: barHeight))
            animation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: newWidth, height: barHeight))
            animation.duration = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            fillLayer.add(animation, forKey: "progress")
        } else {
            setNeedsLayout()
        }
    }

    /// Сбросить прогресс в 0 / Reset progress to 0
    func reset() {
        setProgress(0, animated: false)
    }
}
