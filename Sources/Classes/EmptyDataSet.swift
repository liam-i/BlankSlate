//
//  EmptyDataSet.swift
//  EmptyDataSet
//
//  Created by Liam on 2020/2/6.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

// MARK: - Extension UIScrollView

/// 空数据集类型；适用于网络请求数据出差的情况。
public enum EmptyDataSetType {
    /// 数据请求成功，但数据为空
    case empty
    /// 数据请求出错
    case error
}

/// 空数据集元素类型
public enum EmptyDataSetElement: CaseIterable {
    /// 图片视图
    case image
    /// 标题标签
    case title
    /// 明细标签
    case detail
    /// 按钮控件
    case button
    /// 定制视图（如果您不想使用系统提供的`image`、`title`、`detail`和`button`元素；则可以考虑定制）
    case custom
}

/// `UITableView` / `UICollectionView`父类的扩展，用于在视图无内容时自动显示空数据集
/// - Note: 只需遵循`EmptyDataSetDataSource`协议，并返回要显示的数据它将自动工作
extension UIScrollView: UIGestureRecognizerDelegate {
    /// 空数据集数据源
    public weak var emptyDataSetSource: EmptyDataSetDataSource? {
        get { (objc_getAssociatedObject(self, &EmptyDataSetSourceKey) as? WeakObject)?.value as? EmptyDataSetDataSource }
        set {
            if newValue == nil || emptyDataSetSource == nil {
                invalidate()
            }

            objc_setAssociatedObject(self, &EmptyDataSetSourceKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

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
        get { (objc_getAssociatedObject(self, &EmptyDataSetDelegateKey) as? WeakObject)?.value as? EmptyDataSetDelegate }
        set {
            if newValue == nil {
                invalidate()
            }
            objc_setAssociatedObject(self, &EmptyDataSetDelegateKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 空数据集类型
    public var emptyDataSetType: EmptyDataSetType? {
        get { objc_getAssociatedObject(self, &EmptyDataSetTypeKey) as? EmptyDataSetType }
        set { objc_setAssociatedObject(self, &EmptyDataSetTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// 如果空数据集可见，则为`true`
    public var isEmptyDataSetVisible: Bool {
        guard let view = objc_getAssociatedObject(self, &EmptyDataSetViewKey) as? EmptyDataSetView else { return false }
        return view.isHidden == false
    }

    /// 同时设置`EmptyDataSetDataSource` & `EmptyDataSetDelegate`
    public func setEmptyDataSetSourceAndDelegate(_ newValue: (EmptyDataSetDataSource & EmptyDataSetDelegate)?) {
        emptyDataSetSource = newValue
        emptyDataSetDelegate = newValue
    }

    /// 重新加载数据
    /// - Parameter type: 指定空数据集类型
    /// - Note: 调用此方法以自动按序执行`reloadData()` 和`reloadEmptyDataSet()`
    public func reloadAllData(with type: EmptyDataSetType) {
        emptyDataSetType = type
        switch self {
        case let tableView as UITableView:           tableView.reloadData()
        case let collectionView as UICollectionView: collectionView.reloadData()
        default:                                     reloadEmptyDataSet()
        }
    }

    /// 重新加载空数据集内容视图
    /// - Note: 调用此方法以强制刷新所有数据。类似于`reloadData()`，但这仅强制重新加载空数据集，而不强制重新加载整个表视图或集合视图
    public func reloadEmptyDataSet() {
        guard let emptyDataSetSource = emptyDataSetSource else { return }

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
                view.setCustomView(customView, edge: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .custom))
            } else {
                /// 配置 Image
                if let image = emptyDataSetSource.image(forEmptyDataSet: self) {
                    let tintColor = emptyDataSetSource.imageTintColor(forEmptyDataSet: self)
                    let imageView = view.createImageView(with: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .image))
                    imageView.image = image.withRenderingMode(tintColor != nil ? .alwaysTemplate : .alwaysOriginal)
                    imageView.tintColor = tintColor

                    // 配置图像视图动画
                    if let animation = emptyDataSetSource.imageAnimation(forEmptyDataSet: self) {
                        imageView.layer.add(animation, forKey: EmptyImageViewAnimationKey)
                    } else if imageView.layer.animation(forKey: EmptyImageViewAnimationKey) != nil {
                        imageView.layer.removeAnimation(forKey: EmptyImageViewAnimationKey)
                    }
                }

                /// 配置标题标签
                if let titleString = emptyDataSetSource.title(forEmptyDataSet: self) {
                    view.createTitleLabel(with: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .title)).attributedText = titleString
                }

                /// 配置详细标签
                if let detailString = emptyDataSetSource.detail(forEmptyDataSet: self) {
                    view.createDetailLabel(with: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .title)).attributedText = detailString
                }

                /// 配置按钮
                if let buttonImage = emptyDataSetSource.buttonImage(forEmptyDataSet: self, for: .normal) {
                    let button = view.createButton(with: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .button))
                    button.setImage(buttonImage, for: .normal)
                    button.setImage(emptyDataSetSource.buttonImage(forEmptyDataSet: self, for: .highlighted), for: .highlighted)
                    emptyDataSetSource.configure(forEmptyDataSet: self, for: button)
                } else if let titleString = emptyDataSetSource.buttonTitle(forEmptyDataSet: self, for: .normal) {
                    let button = view.createButton(with: emptyDataSetSource.edgeInsets(forEmptyDataSet: self, for: .button))
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

    public func invalidate() {
        var isEmptyDataSetVisible = false
        if let emptyDataSetView = emptyDataSetView {
            isEmptyDataSetVisible = true
            emptyDataSetDelegate?.emptyDataSetWillDisappear(self) // 通知委托空数据集视图将要消失

            emptyDataSetView.prepareForReuse()
            emptyDataSetView.removeFromSuperview()
            self.emptyDataSetView = nil
        }
        emptyDataSetType = nil
        isScrollEnabled = true

        if isEmptyDataSetVisible {
            emptyDataSetDelegate?.emptyDataSetDidDisappear(self) // 通知委托空数据集视图已经消失
        }
    }

    private var emptyDataSetView: EmptyDataSetView? {
        get { objc_getAssociatedObject(self, &EmptyDataSetViewKey) as? EmptyDataSetView }
        set { objc_setAssociatedObject(self, &EmptyDataSetViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var isTouchAllowed: Bool {
        emptyDataSetDelegate?.emptyDataSetShouldAllowTouch(self) ?? true
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

    @objc private func didTapContentView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        emptyDataSetDelegate?.emptyDataSet(self, didTap: view)
    }

    private func lp_create() -> EmptyDataSetView {
        let view = EmptyDataSetView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentView))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        view.tapGesture = tap
        self.emptyDataSetView = view
        return view
    }

    private func swizzleIfNeeded(_ originalClass: AnyClass, _ originalSelector: Selector) {
        /// 检查当前类是否实现了`originalSelector`方法
        guard responds(to: originalSelector) else { return assertionFailure() }

        let originalStringSelector = NSStringFromSelector(originalSelector)
        for info in IMPLookupTable.values where (info.selector == originalStringSelector && isKind(of: info.owner)) {
            return // 确保每个类（`UITableView`或`UICollectionView`）都只调用一次`method_setImplementation`
        }

        let key = "\(NSStringFromClass(originalClass))_\(originalStringSelector)"
        guard IMPLookupTable[key] == nil else { return } // 如果`originalClass`的实现已经存在，不在继续往下执行

        guard let originalMethod = class_getInstanceMethod(originalClass, originalSelector) else { return assertionFailure() }
        let originalImplementation = method_getImplementation(originalMethod)

        typealias OriginalIMP = @convention(c) (UIScrollView, Selector) -> Void

        /// `unsafeBitCast`将`originalImplementation`强制转换成`OriginalIMP`类型
        /// 两者的类型其实是相同的，都是一个`IMP`指针类型，即`id (*IMP)(id, SEL, ...)`
        let originalClosure = unsafeBitCast(originalImplementation, to: OriginalIMP.self)

        let swizzledBlock: @convention(block) (UIScrollView) -> Void = { (owner) in
            originalClosure(owner, originalSelector)
            owner.reloadEmptyDataSet() // 重新加载空数据集。在调用`isEmptyDataSetVisible`属性之前进行此操作
        }

        let swizzledImplementation = imp_implementationWithBlock(unsafeBitCast(swizzledBlock, to: AnyObject.self))
        method_setImplementation(originalMethod, swizzledImplementation)

        IMPLookupTable[key] = (originalClass, originalStringSelector) // 将新的实现存储在内存表中
    }

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = gestureRecognizer.view, view.isEqual(emptyDataSetView) {
            return isTouchAllowed
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let tapGesture = emptyDataSetView?.tapGesture
        if gestureRecognizer.isEqual(tapGesture) || otherGestureRecognizer.isEqual(tapGesture) {
            return true
        }

        guard let emptyDataSetDelegate = emptyDataSetDelegate else { return false }

        if let scrollView = emptyDataSetDelegate as? UIScrollView, scrollView == self {
            return false
        }

        let delegate = emptyDataSetDelegate as AnyObject
        if delegate.responds(to: #selector(gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:))) {
            return delegate.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        }
        return false
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

// MARK - EmptyDataSetView

private class EmptyDataSetView: UIView {
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        return contentView
    }()

    private(set) var elements: [EmptyDataSetElement: (UIView, UIEdgeInsets)] = [:]

    func createImageView(with edge: UIEdgeInsets) -> UIImageView {
        if let element = elements[.image] { element.0.removeFromSuperview() }

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        elements[.image] = (imageView, edge)
        return imageView
    }

    func createTitleLabel(with edge: UIEdgeInsets) -> UILabel {
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
        elements[.title] = (titleLabel, edge)
        return titleLabel
    }

    func createDetailLabel(with edge: UIEdgeInsets) -> UILabel {
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
        elements[.detail] = (detailLabel, edge)
        return detailLabel
    }

    func createButton(with edge: UIEdgeInsets) -> UIButton {
        if let element = elements[.button] { element.0.removeFromSuperview() }

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        contentView.addSubview(button)
        elements[.button] = (button, edge)
        return button
    }

    func setCustomView(_ view: UIView, edge: UIEdgeInsets) {
        if let element = elements[.custom] { element.0.removeFromSuperview() }

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        elements[.custom] = (view, edge)
    }

    weak var tapGesture: UITapGestureRecognizer?
    var verticalOffset: CGFloat = 0 // 自定义垂直偏移量
    var fadeInDuration: TimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
    }

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
        if hitView.isEqual(contentView) || hitView.isEqual(elements[.custom]) {
            return hitView
        }
        return nil
    }

    @objc private func didTapButton(_ sender: UIButton) {
        guard let superview = superview as? UIScrollView else { return }
        superview.emptyDataSetDelegate?.emptyDataSet(superview, didTap: sender)
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
            let edge = element.1
            constraints += [
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge.left),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge.right),
                view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edge.top),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -edge.bottom)
            ]
        } else {
            var previous: (UIView, UIEdgeInsets)?
            for key in EmptyDataSetElement.allCases {
                guard let element = elements[key] else { continue }
                let view = element.0
                let edge = element.1
                if let previous = previous { // 上一个视图
                    constraints.append(view.topAnchor.constraint(equalTo: previous.0.bottomAnchor, constant: edge.top))
                } else { // 第一个视图
                    constraints.append(view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edge.top))
                }
                constraints.append(view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge.left))
                constraints.append(view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge.right))
                previous = element // 保存上一个视图
            }
            if let last = previous { // 最后一个视图
                constraints.append(last.0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -last.1.bottom))
            }
        }
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Private keys

private var EmptyDataSetSourceKey: Void?
private var EmptyDataSetDelegateKey: Void?
private var EmptyDataSetViewKey: Void?
private var EmptyDataSetTypeKey: Void?
private let EmptyImageViewAnimationKey = "com.lp.emptyDataSet.imageViewAnimation"
private var IMPLookupTable = [String: (owner: AnyClass, selector: String)](minimumCapacity: 3)
