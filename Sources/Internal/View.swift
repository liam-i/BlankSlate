//
//  View.swift
//  BlankSlate <https://github.com/liam-i/BlankSlate>
//
//  Created by Liam on 2024/3/9.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

extension BlankSlate {
    class View: UIView, UIGestureRecognizerDelegate {
        private let contentView: UIView = {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = .clear
            contentView.isUserInteractionEnabled = true
            contentView.alpha = 0
            return contentView
        }()

        private(set) var elements: [Element: (UIView, Layout)] = [:]

        func createImageView(with layout: Layout) -> UIImageView {
            if let element = elements[.image] { element.0.removeFromSuperview() }

            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .clear
            imageView.isUserInteractionEnabled = false
            imageView.contentMode = .scaleAspectFit
            contentView.addSubview(imageView)
            elements[.image] = (imageView, layout)
            return imageView
        }

        func createTitleLabel(with layout: Layout) -> UILabel {
            if let element = elements[.title] { element.0.removeFromSuperview() }

            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.backgroundColor = .clear
            titleLabel.font = .systemFont(ofSize: 27.0)
            titleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.numberOfLines = 0
            contentView.addSubview(titleLabel)
            elements[.title] = (titleLabel, layout)
            return titleLabel
        }

        func createDetailLabel(with layout: Layout) -> UILabel {
            if let element = elements[.detail] { element.0.removeFromSuperview() }

            let detailLabel = UILabel()
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.backgroundColor = .clear
            detailLabel.font = .systemFont(ofSize: 17.0)
            detailLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
            detailLabel.textAlignment = .center
            detailLabel.lineBreakMode = .byWordWrapping
            detailLabel.numberOfLines = 0
            contentView.addSubview(detailLabel)
            elements[.detail] = (detailLabel, layout)
            return detailLabel
        }

        func createButton(with layout: Layout) -> UIButton {
            if let element = elements[.button] { element.0.removeFromSuperview() }

            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .clear
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .center
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            contentView.addSubview(button)
            elements[.button] = (button, layout)
            return button
        }

        func setCustomView(_ view: UIView, layout: Layout) {
            if let element = elements[.custom] { element.0.removeFromSuperview() }

            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            elements[.custom] = (view, layout)
        }

        private weak var tapGesture: UITapGestureRecognizer?
        var offset: CGPoint = .zero
        var fadeInDuration: TimeInterval = 0

        var isTouchAllowed: (() -> Bool)?
        var shouldRecognizeSimultaneously: ((_ withOther: UIGestureRecognizer, _ of: UIGestureRecognizer) -> Bool)?
        var didTap: ((_ view: UIView) -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(contentView)

            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentView))
            tap.delegate = self
            addGestureRecognizer(tap)
            tapGesture = tap

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateForCurrentOrientation),
                name: UIApplication.didChangeStatusBarOrientationNotification,
                object: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
            #if DEBUG
            print("👍🏻👍🏻👍🏻 BlankSlate.View is released.")
            #endif
        }

        override func didMoveToSuperview() {
            updateForCurrentOrientation()

            guard fadeInDuration > 0.0 else {
                return contentView.alpha = 1.0
            }
            UIView.animate(withDuration: fadeInDuration) { [weak self] in
                self?.contentView.alpha = 1.0
            }
        }

        override func didMoveToWindow() {
            updateForCurrentOrientation()
        }

        @objc
        private func updateForCurrentOrientation() {
            guard window != nil, let scrollView = superview as? UIScrollView else { return }
            func syncFrame() {
                let size = scrollView.bounds.size
                let safe = scrollView.safeAreaInsets
                let isVerticalScroll = scrollView.contentSize.width == scrollView.bounds.width
                let x = isVerticalScroll ? safe.left : 0.0
                frame = CGRect(x: x, y: 0.0, 
                               width: size.width - safe.left - safe.right,
                               height: size.height - safe.top - safe.bottom)
            }

            syncFrame()
            DispatchQueue.main.async { syncFrame() }
        }

        @objc
        private func didTapButton(_ sender: UIButton) {
            didTap?(sender)
        }

        @objc
        private func didTapContentView(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view else { return }
            didTap?(view)
        }

        func prepareForReuse() {
            elements.values.forEach { $0.0.removeFromSuperview() }
            elements.removeAll()

            removeConstraints(constraints)
            contentView.removeConstraints(contentView.constraints)
        }

        func setupConstraints() {
            // First, configure the content view constaints
            // The content view must alway be centered to its superview
            var constraints = [
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y),
                contentView.widthAnchor.constraint(equalTo: widthAnchor)
            ]

            // If applicable, set the custom view's constraints
            if let element = elements[.custom] {
                let view = element.0
                let layout = element.1
                constraints += [
                    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: layout.edgeInsets.left),
                    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -layout.edgeInsets.right),
                    view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layout.edgeInsets.top),
                    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -layout.edgeInsets.bottom)
                ]
                if let height = layout.height {
                    constraints.append(view.heightAnchor.constraint(equalToConstant: height))
                }
            } else {
                var previous: (UIView, Layout)?
                for key in Element.allCases {
                    guard let element = elements[key] else { continue }

                    let view = element.0
                    let layout = element.1
                    if let previous = previous { // Previous view
                        constraints.append(view.topAnchor.constraint(equalTo: previous.0.bottomAnchor, constant: layout.edgeInsets.top))
                    } else { // First view
                        constraints.append(view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layout.edgeInsets.top))
                    }
                    constraints.append(view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: layout.edgeInsets.left))
                    constraints.append(view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -layout.edgeInsets.right))

                    if let height = layout.height {
                        constraints.append(view.heightAnchor.constraint(equalToConstant: height))
                    }
                    previous = element // Save previous view
                }
                if let last = previous { // Last view
                    constraints.append(last.0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -last.1.edgeInsets.bottom))
                }
            }

            NSLayoutConstraint.activate(constraints)
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hitView = super.hitTest(point, with: event) else { return nil }
            // Return any UIControl instance such as buttons, segmented controls, switches, etc.
            if hitView is UIControl {
                return hitView
            }

            // Return either the contentView or customView
            if hitView.isEqual(contentView) || hitView.isEqual(elements[.custom]?.0) {
                return hitView
            }
            return nil
        }

        // MARK: - UIGestureRecognizerDelegate
        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if let isTouchAllowed = isTouchAllowed, isEqual(gestureRecognizer.view) {
                return isTouchAllowed()
            }
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer.isEqual(tapGesture) || otherGestureRecognizer.isEqual(tapGesture) {
                return true
            }
            // defer to blankSlateDelegate's implementation if available
            return shouldRecognizeSimultaneously?(otherGestureRecognizer, gestureRecognizer) ?? false
        }
    }
}
