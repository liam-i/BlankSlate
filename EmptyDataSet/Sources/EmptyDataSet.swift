//
//  LPEmptyDataSet.swift
//  LPEmptyDataSet
//
//  Created by pengli on 2020/2/6.
//  Copyright © 2020 pengli. All rights reserved.
//

import UIKit

// MARK: - Extension UIScrollView

private var LPEmptyDataSetSourceKey: Void?
private var LPEmptyDataSetDelegateKey: Void?
private var LPEmptyDataSetViewKey: Void?
private var LPEmptyDataSetTypeKey: Void?
private let LPEmptyImageViewAnimationKey = "com.lp.emptyDataSet.imageViewAnimation"
private var LPIMPLookupTable = [String: (owner: AnyClass, selector: String)](minimumCapacity: 3)

/// 空数据集类型；适用于网络请求数据出差的情况。
public enum LPEmptyDataSetType {
    case empty // 数据请求成功，但数据为空
    case error // 数据请求出错
}

/// 空数据集元素类型
public enum LPEmptyDataSetElement: CaseIterable {
    case image  // 图片视图
    case title  // 标题标签
    case detail // 明细标签
    case button // 按钮控件
    case custom // 定制视图（如果您不想使用系统提供的`image`、`title`、`detail`和`button`元素；则可以考虑定制）
}

/// `UITableView` / `UICollectionView`父类的扩展，用于在视图无内容时自动显示空数据集
/// - Note: 只需遵循`LPEmptyDataSetDataSource`协议，并返回要显示的数据它将自动工作
extension UIScrollView: UIGestureRecognizerDelegate {
    /// 空数据集数据源
    public weak var emptyDataSetSource: LPEmptyDataSetDataSource? {
        get { (objc_getAssociatedObject(self, &LPEmptyDataSetSourceKey) as? LPWeakObject)?.weakObject as? LPEmptyDataSetDataSource }
        set {
            if newValue == nil || !lp_canDisplay { lp_invalidate() }
            
            objc_setAssociatedObject(self, &LPEmptyDataSetSourceKey, LPWeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            /// 使用runtime swizzle将`lp_reloadData()`和`reloadData()`交换
            switch self {
            case is UITableView:
                lp_swizzleIfNeeded(UITableView.self, #selector(UITableView.reloadData))
                lp_swizzleIfNeeded(UITableView.self, #selector(UITableView.endUpdates))
            case is UICollectionView:
                lp_swizzleIfNeeded(UICollectionView.self, #selector(UICollectionView.reloadData))
            default:
                assert(false)
            }
        }
    }
    
    /// 空数据集委托
    public weak var emptyDataSetDelegate: LPEmptyDataSetDelegate? {
        get { (objc_getAssociatedObject(self, &LPEmptyDataSetDelegateKey) as? LPWeakObject)?.weakObject as? LPEmptyDataSetDelegate }
        set {
            if newValue == nil { lp_invalidate() }
            objc_setAssociatedObject(self, &LPEmptyDataSetDelegateKey, LPWeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 空数据集类型
    public var emptyDataSetType: LPEmptyDataSetType? {
        get { objc_getAssociatedObject(self, &LPEmptyDataSetTypeKey) as? LPEmptyDataSetType }
        set { objc_setAssociatedObject(self, &LPEmptyDataSetTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 如果空数据集可见，则为`true`
    public var isEmptyDataSetVisible: Bool {
        guard let view = objc_getAssociatedObject(self, &LPEmptyDataSetViewKey) as? LPEmptyDataSetView else { return false }
        return !view.isHidden
    }
    
    /// 重新加载数据
    /// - Parameter type: 指定空数据集类型
    /// - Note: 调用此方法以自动按序执行`reloadData()` 和`reloadEmptyDataSet()`
    public func reloadAllData(with type: LPEmptyDataSetType) {
        emptyDataSetType = type
        switch self {
        case let tableView as UITableView:           tableView.reloadData()
        case let collectionView as UICollectionView: collectionView.reloadData()
        default:                                     assert(false)
        }
    }
    
    /// 重新加载空数据集内容视图
    /// - Note: 调用此方法以强制刷新所有数据。类似于`reloadData()`，但这仅强制重新加载空数据集，而不强制重新加载整个表视图或集合视图
    public func reloadEmptyDataSet() {
        guard let emptyDataSetSource = emptyDataSetSource, lp_canDisplay else { return }
        
        if ((emptyDataSetDelegate?.emptyDataSetShouldDisplay(self) ?? true) && (lp_itemsCount == 0))
            || (emptyDataSetDelegate?.emptyDataSetShouldBeForcedToDisplay(self) ?? false) {
            let view = lp_emptyDataSetView ?? lp_create()
            
            emptyDataSetDelegate?.emptyDataSetWillAppear(self) // 通知委托空数据集视图将要呈现
            
            view.fadeInDuration = emptyDataSetSource.fadeInDuration(forEmptyDataSet: self) // 设置空数据集淡入持续时间
            
            if view.superview == nil {
                /// 如果`UITableView`/`UICollectionView`有内容存在则将空数据集插入到视图最底层
                if (self is UITableView || self is UICollectionView) && subviews.count > 1 {
                    insertSubview(view, at: 0)
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
                        imageView.layer.add(animation, forKey: LPEmptyImageViewAnimationKey)
                    } else if imageView.layer.animation(forKey: LPEmptyImageViewAnimationKey) != nil {
                        imageView.layer.removeAnimation(forKey: LPEmptyImageViewAnimationKey)
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
            view.isUserInteractionEnabled = lp_isTouchAllowed // 设置空数据集的用户交互权限
            if !view.isHidden { view.setupConstraints() } // 如果视图集不为空，则设置约束
            
            UIView.performWithoutAnimation { view.layoutIfNeeded() }
            isScrollEnabled = emptyDataSetDelegate?.emptyDataSetShouldAllowScroll(self) ?? false // 设置滚动权限
            
            emptyDataSetDelegate?.emptyDataSetDidAppear(self) // 通知委托空数据集视图已经呈现
        } else if isEmptyDataSetVisible {
            lp_invalidate()
        }
    }
    
    private var lp_emptyDataSetView: LPEmptyDataSetView? {
        get { objc_getAssociatedObject(self, &LPEmptyDataSetViewKey) as? LPEmptyDataSetView }
        set { objc_setAssociatedObject(self, &LPEmptyDataSetViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var lp_canDisplay: Bool {
        (emptyDataSetSource != nil) && (self is UITableView || self is UICollectionView)
    }
    
    private var lp_isTouchAllowed: Bool {
        emptyDataSetDelegate?.emptyDataSetShouldAllowTouch(self) ?? true
    }
    
    private var lp_itemsCount: Int {
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
            assert(false)
        }
        return items
    }
    
    @objc private func lp_didTapContentView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        emptyDataSetDelegate?.emptyDataSet(self, didTap: view)
    }
    
    private func lp_create() -> LPEmptyDataSetView {
        let view = LPEmptyDataSetView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(lp_didTapContentView))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        view.tapGesture = tap
        self.lp_emptyDataSetView = view
        return view
    }
    
    private func lp_invalidate() {
        emptyDataSetDelegate?.emptyDataSetWillDisappear(self) // 通知委托空数据集视图将要消失
        
        if let emptyDataSetView = lp_emptyDataSetView {
            emptyDataSetView.prepareForReuse()
            emptyDataSetView.removeFromSuperview()
            lp_emptyDataSetView = nil
        }
        emptyDataSetType = nil
        
        isScrollEnabled = true
        emptyDataSetDelegate?.emptyDataSetDidDisappear(self) // 通知委托空数据集视图已经消失
    }
    
    private func lp_swizzleIfNeeded(_ originalClass: AnyClass, _ originalSelector: Selector) {
        /// 检查当前类是否实现了`originalSelector`方法
        guard responds(to: originalSelector) else { return assert(false) }
        
        let originalStringSelector = NSStringFromSelector(originalSelector)
        for info in LPIMPLookupTable.values where (info.selector == originalStringSelector && isKind(of: info.owner)) {
            return // 确保每个类（`UITableView`或`UICollectionView`）都只调用一次`method_setImplementation`
        }
        
        let key = "\(NSStringFromClass(originalClass))_\(originalStringSelector)"
        guard LPIMPLookupTable[key] == nil else { return } // 如果`originalClass`的实现已经存在，不在继续往下执行
        
        guard let originalMethod = class_getInstanceMethod(originalClass, originalSelector) else { return assert(false) }
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
        
        LPIMPLookupTable[key] = (originalClass, originalStringSelector) // 将新的实现存储在内存表中
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = gestureRecognizer.view, view.isEqual(lp_emptyDataSetView) {
            return lp_isTouchAllowed
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let tapGesture = lp_emptyDataSetView?.tapGesture
        if gestureRecognizer.isEqual(tapGesture) || otherGestureRecognizer.isEqual(tapGesture) {
            return true
        }
        /// 如果可用，请遵循emptyDataSetDelegate的实现方法
        if let emptyDataSetDelegate = emptyDataSetDelegate, !emptyDataSetDelegate.isEqual(self) {
            let delegate = emptyDataSetDelegate as AnyObject
            if delegate.responds(to: #selector(gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:))) {
                return delegate.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
            }
        }
        return false
    }
}

// MARK: - LPWeakObject

private class LPWeakObject {
    private(set) weak var weakObject: AnyObject?
    init?(_ object: AnyObject?) {
        guard let object = object else { return nil }
        weakObject = object
    }
    deinit {
        #if DEBUG
        print("LPWeakObject: -> release memory.")
        #endif
    }
}

// MARK - LPEmptyDataSetView

private class LPEmptyDataSetView: UIView {
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        return contentView
    }()
    
    private(set) var elements: [LPEmptyDataSetElement: (UIView, UIEdgeInsets)] = [:]
    
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
        print("LPEmptyDataSetView: -> release memory.")
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
            for key in LPEmptyDataSetElement.allCases {
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

// MARK: - LPEmptyDataSetDataSource

/// 空数据集的数据源协议
/// - Note: 数据源必须采用`LPEmptyDataSetDataSource`协议。所有数据源方法都是可选的
public protocol LPEmptyDataSetDataSource: NSObjectProtocol {
    /// 向数据源请求数据集的图像。默认`nil`
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    
    /// 向数据源请求数据集图像的`TintColor`。默认`nil`
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?
    
    /// 向数据源请求数据集的图像动画，默认`nil`
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation?
    
    /// 向数据源请求数据集的标题文本。默认`nil`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// 向数据源请求数据集的明细文本。默认`nil`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func detail(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// 向数据源请求用于指定按钮状态的标题。默认`nil`
    /// - Parameter state: 指定标题的状态。详情请见`UIControl.State`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString?
    
    /// 向数据源请求用于指定按钮状态的背景图像。默认`nil`
    /// - Parameter state: 指定图像的状态。详情请见`UIControl.State`
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?
    
    /// 向数据源请求用于指定按钮状态的图像。默认`nil`
    /// - Parameter state: 指定图像的状态。详情请见`UIControl.State`
    /// - Note: 此方法将覆盖`buttonTitle(forEmptyDataSet:for:)`函数
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?
    
    /// 向数据源请求去配置按钮样式
    /// - Parameter button: 需要配置的按钮
    func configure(forEmptyDataSet scrollView: UIScrollView, for button: UIButton)
    
    /// 向数据源请求数据集的背景色。 默认`UIColor.clear`
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?
    
    /// 向数据源请求自定义空数据集视图，而不显示默认视图，例如`labels`、`imageview`和`button`。默认`nil`
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView?
    
    /// 向数据源请求内容垂直对齐的偏移量。默认`0pt`
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
    
    /// 向数据源请求`LPEmptyDataSetElement`的上下左右间距。默认：`UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)`
    func edgeInsets(forEmptyDataSet scrollView: UIScrollView, for element: LPEmptyDataSetElement) -> UIEdgeInsets
    
    /// 向数据源请求在显示空数据集时采用淡入动画的持续时间。默认`0`
    /// - Note: 如果`fadeInDuration <= 0`则不执行动画
    func fadeInDuration(forEmptyDataSet scrollView: UIScrollView) -> TimeInterval
}

extension LPEmptyDataSetDataSource {
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? { nil }
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? { nil }
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? { nil }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? { nil }
    
    func detail(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? { nil }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { nil }
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    func configure(forEmptyDataSet scrollView: UIScrollView, for button: UIButton) { }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? { UIColor.clear }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? { nil }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat { 0.0 }
    
    func edgeInsets(forEmptyDataSet scrollView: UIScrollView, for element: LPEmptyDataSetElement) -> UIEdgeInsets { UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16) }
    
    func fadeInDuration(forEmptyDataSet scrollView: UIScrollView) -> TimeInterval { 0.0 }
}

// MARK: - LPEmptyDataSetDelegate

/// 空数据集的委托协议
/// - Note: 所有委托方法都是可选的。使用此委托来接收操作回调
public protocol LPEmptyDataSetDelegate: NSObjectProtocol {
    /// 向委托请求当items数大于0时是否仍然显示空数据集。默认`false`
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool
    
    /// 向委托请求是否允许显示空数据集。 默认为`true`
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool
    
    /// 向委托请求是否允许响应触摸手势。 默认为`true`
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool
    
    /// 向委托请求是否允许滚动。 默认为`false`
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool
    
    /// 通知委托该空数据集视图被触摸
    /// - Parameter view: 用户点击的视图
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView)
    
    /// 通知委托该操作按钮被点击
    /// - Parameter button: 用户点击的按钮
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton)
    
    /// 通知委托该空数据集将要显示
    func emptyDataSetWillAppear(_ scrollView: UIScrollView)
    
    /// 通知委托该空数据集已经显示
    func emptyDataSetDidAppear(_ scrollView: UIScrollView)
    
    /// 通知委托该空数据集将要消失
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView)
    
    /// 通知委托该空数据集已经消失
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView)
}

extension LPEmptyDataSetDelegate {
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool { false }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool { true }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool { true }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool { false }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) { }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) { }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) { }
    
    func emptyDataSetDidAppear(_ scrollView: UIScrollView) { }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) { }
    
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView) { }
}
