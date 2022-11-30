//
//  EmptyDataSet.swift
//  EmptyDataSet <https://github.com/liam-i/EmptyDataSet>
//
//  Created by Liam on 2020/2/6.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

// MARK: - Extension UIScrollView

/// `UITableView` / `UICollectionView`父类的扩展，用于在视图无内容时自动显示空数据集
/// - Note: 只需遵循`EmptyDataSetDataSource`协议，并返回要显示的数据它将自动工作
extension UIScrollView {
    /// 空数据集数据源
    public weak var emptyDataSetSource: EmptyDataSetDataSource? {
        get { (objc_getAssociatedObject(self, &kEmptyDataSetSourceKey) as? WeakObject)?.value as? EmptyDataSetDataSource }
        set {
            if newValue == nil || emptyDataSetSource == nil {
                invalidate()
            }

            objc_setAssociatedObject(self, &kEmptyDataSetSourceKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            /// 使用runtime swizzle将`lp_reloadData()`和`reloadData()`交换
            switch self {
            case is UITableView:
                swizzleIfNeeded(UITableView.self, #selector(UITableView.reloadData))
                swizzleIfNeeded(UITableView.self, #selector(UITableView.endUpdates))
            case is UICollectionView:
                swizzleIfNeeded(UICollectionView.self, #selector(UICollectionView.reloadData))
            default:
                break
            }
        }
    }

    /// 空数据集委托
    public weak var emptyDataSetDelegate: EmptyDataSetDelegate? {
        get { (objc_getAssociatedObject(self, &kEmptyDataSetDelegateKey) as? WeakObject)?.value as? EmptyDataSetDelegate }
        set {
            if newValue == nil {
                invalidate()
            }
            objc_setAssociatedObject(self, &kEmptyDataSetDelegateKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 数据加载状态
    /// - Note: 为`UITableView`和`UICollectionView`设置此属性时自动执行`reloadData()`方法
    public var dataLoadStatus: EmptyDataLoadStatus? {
        get { objc_getAssociatedObject(self, &kEmptyDataSetStatusKey) as? EmptyDataLoadStatus }
        set {
            objc_setAssociatedObject(self, &kEmptyDataSetStatusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            guard let newValue = newValue, newValue != .loading else {
                return reloadEmptyDataSet()
            }

            switch self {
            case let tableView as UITableView:
                tableView.reloadData()
            case let collectionView as UICollectionView:
                collectionView.reloadData()
            default:
                reloadEmptyDataSet()
            }
        }
    }

    /// 空视图集内容视图
    public var emptyDataSetContentView: UIView? {
        emptyDataSetView
    }

    /// 如果空数据集可见，则为`true`
    public var isEmptyDataSetVisible: Bool {
        guard let view = objc_getAssociatedObject(self, &kEmptyDataSetViewKey) as? EmptyDataSetView else { return false }
        return view.isHidden == false
    }

    /// 同时设置`EmptyDataSetDataSource` & `EmptyDataSetDelegate`
    public func setEmptyDataSetSourceAndDelegate(_ newValue: (EmptyDataSetDataSource & EmptyDataSetDelegate)?) {
        emptyDataSetSource = newValue
        emptyDataSetDelegate = newValue
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// 重新加载空数据集内容视图
    /// - Note: 调用此方法以强制刷新所有数据。类似于`reloadData()`，但这仅强制重新加载空数据集，而不强制重新加载整个表视图或集合视图
    public func reloadEmptyDataSet() {
        guard let emptyDataSetSource = emptyDataSetSource else {
            invalidate()
            return
        }

        if ((emptyDataSetDelegate?.emptyDataSetShouldDisplay(self) ?? true) && (itemsCount == 0))
            || (emptyDataSetDelegate?.emptyDataSetShouldBeForcedToDisplay(self) ?? false) {
            let view = emptyDataSetView ?? lp_create()

            emptyDataSetDelegate?.emptyDataSetWillAppear(self) // 通知委托空数据集视图将要呈现

            view.fadeInDuration = emptyDataSetSource.fadeInDuration(forEmptyDataSet: self) // 设置空数据集淡入持续时间

            if view.superview == nil {
                if subviews.count > 1 {
                    let index = emptyDataSetDelegate?.emptyDataSetShouldBeInsertAtIndex(self) ?? 0
                    if index >= 0 && index < subviews.count {
                        insertSubview(view, at: index)
                    } else {
                        addSubview(view)
                    }
                } else {
                    addSubview(view)
                }
            }

            /// 重置视图以及约束
            view.prepareForReuse()

            /// 如果允许，则设置自定义视图
            if let customView = emptyDataSetSource.customView(forEmptyDataSet: self) {
                view.setCustomView(customView, layout: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .custom))
            } else {
                /// 配置 Image
                if let image = emptyDataSetSource.image(forEmptyDataSet: self) {
                    let tintColor = emptyDataSetSource.imageTintColor(forEmptyDataSet: self)
                    let imageView = view.createImageView(with: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .image))
                    imageView.image = image.withRenderingMode(tintColor != nil ? .alwaysTemplate : .alwaysOriginal)
                    imageView.tintColor = tintColor
                    imageView.alpha = emptyDataSetSource.imageAlpha(forEmptyDataSet: self)

                    // 配置图像视图动画
                    if let animation = emptyDataSetSource.imageAnimation(forEmptyDataSet: self) {
                        imageView.layer.add(animation, forKey: kEmptyImageViewAnimationKey)
                    } else if imageView.layer.animation(forKey: kEmptyImageViewAnimationKey) != nil {
                        imageView.layer.removeAnimation(forKey: kEmptyImageViewAnimationKey)
                    }
                }

                /// 配置标题标签
                if let titleString = emptyDataSetSource.title(forEmptyDataSet: self) {
                    view.createTitleLabel(with: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .title)).attributedText = titleString
                }

                /// 配置详细标签
                if let detailString = emptyDataSetSource.detail(forEmptyDataSet: self) {
                    view.createDetailLabel(with: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .title)).attributedText = detailString
                }

                /// 配置按钮
                if let buttonImage = emptyDataSetSource.buttonImage(forEmptyDataSet: self, for: .normal) {
                    let button = view.createButton(with: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .button))
                    button.setImage(buttonImage, for: .normal)
                    button.setImage(emptyDataSetSource.buttonImage(forEmptyDataSet: self, for: .highlighted), for: .highlighted)
                    emptyDataSetSource.configure(forEmptyDataSet: self, for: button)
                } else if let titleString = emptyDataSetSource.buttonTitle(forEmptyDataSet: self, for: .normal) {
                    let button = view.createButton(with: emptyDataSetSource.elementLayout(forEmptyDataSet: self, for: .button))
                    button.setAttributedTitle(titleString, for: .normal)
                    button.setAttributedTitle(emptyDataSetSource.buttonTitle(forEmptyDataSet: self, for: .highlighted), for: .highlighted)
                    button.setBackgroundImage(emptyDataSetSource.buttonBackgroundImage(forEmptyDataSet: self, for: .normal), for: .normal)
                    button.setBackgroundImage(emptyDataSetSource.buttonBackgroundImage(forEmptyDataSet: self, for: .highlighted), for: .highlighted)
                    emptyDataSetSource.configure(forEmptyDataSet: self, for: button)
                }
            }

            view.verticalOffset = emptyDataSetSource.verticalOffset(forEmptyDataSet: self)

            // 配置空数据集视图
            view.backgroundColor = emptyDataSetSource.backgroundColor(forEmptyDataSet: self) ?? UIColor.clear
            view.isHidden = view.elements.isEmpty // 如果视图集为空，则不显示
            view.clipsToBounds = true
            view.isUserInteractionEnabled = isTouchAllowed // 设置空数据集的用户交互权限
            if !view.isHidden { view.setupConstraints() } // 如果视图集不为空，则设置约束

            UIView.performWithoutAnimation { view.layoutIfNeeded() }
            isScrollEnabled = emptyDataSetDelegate?.emptyDataSetShouldAllowScroll(self) ?? false // 设置滚动权限

            emptyDataSetDelegate?.emptyDataSetDidAppear(self) // 通知委托空数据集视图已经呈现
        } else if isEmptyDataSetVisible {
            invalidate()
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    public func invalidate() {
        var isEmptyDataSetVisible = false
        if let emptyDataSetView = emptyDataSetView {
            isEmptyDataSetVisible = true
            emptyDataSetDelegate?.emptyDataSetWillDisappear(self) // 通知委托空数据集视图将要消失

            emptyDataSetView.prepareForReuse()
            emptyDataSetView.removeFromSuperview()
            self.emptyDataSetView = nil
        }

        if isEmptyDataSetVisible {
            isScrollEnabled = emptyDataSetDelegate?.shouldAllowScrollAfterEmptyDataSetDisappear(self) ?? true
            emptyDataSetDelegate?.emptyDataSetDidDisappear(self) // 通知委托空数据集视图已经消失
        }
    }

    private var emptyDataSetView: EmptyDataSetView? {
        get { objc_getAssociatedObject(self, &kEmptyDataSetViewKey) as? EmptyDataSetView }
        set { objc_setAssociatedObject(self, &kEmptyDataSetViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var itemsCount: Int {
        var items: Int = 0
        switch self {
        case let tableView as UITableView: // UITableView 支持
            if let dataSource = tableView.dataSource {
                let sections = dataSource.numberOfSections?(in: tableView) ?? 1
                (0..<sections).forEach {
                    items += dataSource.tableView(tableView, numberOfRowsInSection: $0)
                }
            }
        case let collectionView as UICollectionView: // UICollectionView 支持
            if let dataSource = collectionView.dataSource {
                let sections = dataSource.numberOfSections?(in: collectionView) ?? 1
                (0..<sections).forEach {
                    items += dataSource.collectionView(collectionView, numberOfItemsInSection: $0)
                }
            }
        default:
            break
        }
        return items
    }

    private func lp_create() -> EmptyDataSetView {
        let view = EmptyDataSetView(delegate: self)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        self.emptyDataSetView = view
        return view
    }

    private func swizzleIfNeeded(_ originalClass: AnyClass, _ originalSelector: Selector) {
        /// 检查当前类是否实现了`originalSelector`方法
        guard responds(to: originalSelector) else { return assertionFailure() }

        let originalStringSelector = NSStringFromSelector(originalSelector)
        for info in kIMPLookupTable.values where (info.selector == originalStringSelector && isKind(of: info.owner)) {
            return // 确保每个类（`UITableView`或`UICollectionView`）都只调用一次`method_setImplementation`
        }

        let key = "\(NSStringFromClass(originalClass))_\(originalStringSelector)"
        guard kIMPLookupTable[key] == nil else { return } // 如果`originalClass`的实现已经存在，不在继续往下执行

        guard let originalMethod = class_getInstanceMethod(originalClass, originalSelector) else { return assertionFailure() }
        let originalImplementation = method_getImplementation(originalMethod)

        typealias OriginalIMP = @convention(c) (UIScrollView, Selector) -> Void

        /// `unsafeBitCast`将`originalImplementation`强制转换成`OriginalIMP`类型
        /// 两者的类型其实是相同的，都是一个`IMP`指针类型，即`id (*IMP)(id, SEL, ...)`
        let originalClosure = unsafeBitCast(originalImplementation, to: OriginalIMP.self)

        let swizzledBlock: @convention(block) (UIScrollView) -> Void = { owner in
            originalClosure(owner, originalSelector)
            owner.reloadEmptyDataSet() // 重新加载空数据集。在调用`isEmptyDataSetVisible`属性之前进行此操作
        }

        let swizzledImplementation = imp_implementationWithBlock(unsafeBitCast(swizzledBlock, to: AnyObject.self))
        method_setImplementation(originalMethod, swizzledImplementation)

        kIMPLookupTable[key] = (originalClass, originalStringSelector) // 将新的实现存储在内存表中
    }
}

extension UIScrollView: EmptyDataSetViewDelegate {
    fileprivate var isTouchAllowed: Bool {
        emptyDataSetDelegate?.emptyDataSetShouldAllowTouch(self) ?? true
    }

    fileprivate func shouldRecognizeSimultaneously(with otherGestureRecognizer: UIGestureRecognizer,
                                                   of gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let emptyDataSetDelegate = emptyDataSetDelegate else { return false }
        if let scrollView = emptyDataSetDelegate as? UIScrollView, scrollView == self {
            return false
        }
        if let delegate = emptyDataSetDelegate as? UIGestureRecognizerDelegate {
            return delegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
        }
        return false
    }

    fileprivate func didTap(_ view: UIView) {
        emptyDataSetDelegate?.emptyDataSet(self, didTap: view)
    }
}

// MARK: - WeakObject

private class WeakObject {
    private(set) weak var value: AnyObject?

    init?(_ value: AnyObject?) {
        guard let value = value else { return nil }
        self.value = value
    }

    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 WeakObject is released.")
        #endif
    }
}

// MARK: - EmptyDataSetViewDelegate & EmptyDataSetView

private protocol EmptyDataSetViewDelegate: AnyObject {
    var isTouchAllowed: Bool { get }

    func shouldRecognizeSimultaneously(with otherGestureRecognizer: UIGestureRecognizer,
                                       of gestureRecognizer: UIGestureRecognizer) -> Bool
    func didTap(_ view: UIView)
}

private class EmptyDataSetView: UIView, UIGestureRecognizerDelegate {
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        return contentView
    }()

    private(set) var elements: [EmptyDataSetElement: (UIView, ElementLayout)] = [:]

    func createImageView(with layout: ElementLayout) -> UIImageView {
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

    func createTitleLabel(with layout: ElementLayout) -> UILabel {
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

    func createDetailLabel(with layout: ElementLayout) -> UILabel {
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

    func createButton(with layout: ElementLayout) -> UIButton {
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

    func setCustomView(_ view: UIView, layout: ElementLayout) {
        if let element = elements[.custom] { element.0.removeFromSuperview() }

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        elements[.custom] = (view, layout)
    }

    private weak var delegate: EmptyDataSetViewDelegate?
    private weak var tapGesture: UITapGestureRecognizer?
    fileprivate var verticalOffset: CGFloat = 0 // 自定义垂直偏移量
    fileprivate var fadeInDuration: TimeInterval = 0

    init(delegate: EmptyDataSetViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
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
        print("👍🏻👍🏻👍🏻 EmptyDataSetView is released.")
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
        delegate?.didTap(sender)
    }

    @objc
    private func didTapContentView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        delegate?.didTap(view)
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
            var previous: (UIView, ElementLayout)?
            for key in EmptyDataSetElement.allCases {
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
        if let delegate = delegate, isEqual(gestureRecognizer.view) {
            return delegate.isTouchAllowed
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(tapGesture) || otherGestureRecognizer.isEqual(tapGesture) {
            return true
        }

        guard let delegate = delegate else { return false }
        return delegate.shouldRecognizeSimultaneously(with: otherGestureRecognizer, of: gestureRecognizer)
    }
}

// MARK: - Private keys

private var kEmptyDataSetSourceKey: Void?
private var kEmptyDataSetDelegateKey: Void?
private var kEmptyDataSetViewKey: Void?
private var kEmptyDataSetStatusKey: Void?
private let kEmptyImageViewAnimationKey = "com.lp.emptyDataSet.imageViewAnimation"
private var kIMPLookupTable = [String: (owner: AnyClass, selector: String)](minimumCapacity: 3)
