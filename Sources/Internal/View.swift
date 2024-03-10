//
//  View.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by Liam on 2024/3/9.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

extension NoDataSet {
    class View: UIView, UIGestureRecognizerDelegate {
        private let contentView: UIView = {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = UIColor.clear
            contentView.isUserInteractionEnabled = true
            contentView.alpha = 0
            return contentView
        }()

        private(set) var elements: [Element: (UIView, Layout)] = [:]

        func createImageView(with layout: Layout) -> UIImageView {
            if let element = elements[.image] { element.0.removeFromSuperview() }

            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = UIColor.clear
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
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.font = UIFont.systemFont(ofSize: 27.0)
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
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.font = UIFont.systemFont(ofSize: 17.0)
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
            button.backgroundColor = UIColor.clear
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
        var verticalOffset: CGFloat = 0 // 自定义垂直偏移量
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
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            #if DEBUG
            print("👍🏻👍🏻👍🏻 NoDataSet.View is released.")
            #endif
        }

        override func didMoveToSuperview() {
            guard let superview = superview else { return }
            frame = superview.bounds

            guard fadeInDuration > 0.0 else {
                return contentView.alpha = 1.0
            }
            UIView.animate(withDuration: fadeInDuration) { [weak self] in
                self?.contentView.alpha = 1.0
            }
            print("didMoveToSuperview", safeAreaInsets)
        }

        override func layoutSubviews() {
            print("safeAreaInsets", safeAreaInsets)
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hitView = super.hitTest(point, with: event) else { return nil }

            /// 返回任何`UIControl`实例，例如`UIButton、UISegmentedControl、UISwitch`等
            if hitView is UIControl {
                return hitView
            }

            /// 返回`contentView`或`customView`
            if hitView.isEqual(contentView) || hitView.isEqual(elements[.custom]?.0) {
                return hitView
            }
            return nil
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
            /// 首先，配置内容视图约束
            var constraints = [
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: verticalOffset),
                contentView.widthAnchor.constraint(equalTo: widthAnchor)
            ]

            /// 如果允许，设置自定义视图的约束
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
                    if let previous = previous { // 上一个视图
                        constraints.append(view.topAnchor.constraint(equalTo: previous.0.bottomAnchor, constant: layout.edgeInsets.top))
                    } else { // 第一个视图
                        constraints.append(view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layout.edgeInsets.top))
                    }
                    constraints.append(view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: layout.edgeInsets.left))
                    constraints.append(view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -layout.edgeInsets.right))

                    if let height = layout.height {
                        constraints.append(view.heightAnchor.constraint(equalToConstant: height))
                    }
                    previous = element // 保存上一个视图
                }
                if let last = previous { // 最后一个视图
                    constraints.append(last.0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -last.1.edgeInsets.bottom))
                }
            }

            NSLayoutConstraint.activate(constraints)
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

            return shouldRecognizeSimultaneously?(otherGestureRecognizer, gestureRecognizer) ?? false
        }
    }
}
