//
//  Impl.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by Liam on 2020/2/6.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

/// `UITableView` / `UICollectionView`父类的扩展，用于在视图无内容时自动显示空数据集
/// - Note: 只需遵循`NoDataSetDataSource`协议，并返回要显示的数据它将自动工作
extension UIScrollView {
    /// 空数据集数据源
    weak var noDataSetSource: NoDataSetDataSource? {
        get { (objc_getAssociatedObject(self, &kNoDataSetSourceKey) as? WeakObject)?.value as? NoDataSetDataSource }
        set {
            if newValue == nil || noDataSetSource == nil {
                dismissNoDataSetIfNeeded()
            }

            objc_setAssociatedObject(self, &kNoDataSetSourceKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            /// 使用runtime swizzle将`reloadNoDataSetIfNeeded()`和`reloadData()`交换
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
    weak var noDataSetDelegate: NoDataSetDelegate? {
        get { (objc_getAssociatedObject(self, &kNoDataSetDelegateKey) as? WeakObject)?.value as? NoDataSetDelegate }
        set {
            if newValue == nil {
                dismissNoDataSetIfNeeded()
            }
            objc_setAssociatedObject(self, &kNoDataSetDelegateKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 数据加载状态
    /// - Note: 为`UITableView`和`UICollectionView`设置此属性时自动执行`reloadData()`方法
    var dataLoadStatus: NoDataSet.DataLoadStatus? {
        get { objc_getAssociatedObject(self, &kNoDataSetStatusKey) as? NoDataSet.DataLoadStatus }
        set {
            objc_setAssociatedObject(self, &kNoDataSetStatusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            guard let newValue = newValue, newValue != .loading else {
                return reloadNoDataSetIfNeeded()
            }

            switch self {
            case let tableView as UITableView:
                tableView.reloadData()
            case let collectionView as UICollectionView:
                collectionView.reloadData()
            default:
                reloadNoDataSetIfNeeded()
            }
        }
    }

    /// 如果空数据集可见，则为`true`
    var isNoDataSetVisible: Bool {
        guard let view = objc_getAssociatedObject(self, &kNoDataSetViewKey) as? NoDataSet.View else { return false }
        return view.isHidden == false
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// 重新加载空数据集内容视图
    /// - Note: 调用此方法以强制刷新所有数据。类似于`reloadData()`，但这仅强制重新加载空数据集，而不强制重新加载整个表视图或集合视图
    func reloadNoDataSetIfNeeded() {
        guard let noDataSetSource = noDataSetSource else {
            dismissNoDataSetIfNeeded()
            return
        }

        if ((noDataSetDelegate?.noDataSetShouldDisplay(self) ?? true) && (itemsCount == 0))
            || (noDataSetDelegate?.noDataSetShouldBeForcedToDisplay(self) ?? false) {
            let view = noDataSetView ?? makeNoDataSetView()

            noDataSetDelegate?.noDataSetWillAppear(self) // 通知委托空数据集视图将要呈现

            view.fadeInDuration = noDataSetSource.fadeInDuration(forNoDataSet: self) // 设置空数据集淡入持续时间

            if view.superview == nil {
                if subviews.count > 1 {
                    let index = noDataSetDelegate?.noDataSetShouldBeInsertAtIndex(self) ?? 0
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
            if let customView = noDataSetSource.customView(forNoDataSet: self) {
                view.setCustomView(customView, layout: noDataSetSource.layout(forNoDataSet: self, for: .custom))
            } else {
                /// 配置 Image
                if let image = noDataSetSource.image(forNoDataSet: self) {
                    let tintColor = noDataSetSource.imageTintColor(forNoDataSet: self)
                    let imageView = view.createImageView(with: noDataSetSource.layout(forNoDataSet: self, for: .image))
                    imageView.image = image.withRenderingMode(tintColor != nil ? .alwaysTemplate : .alwaysOriginal)
                    imageView.tintColor = tintColor
                    imageView.alpha = noDataSetSource.imageAlpha(forNoDataSet: self)

                    // 配置图像视图动画
                    if let animation = noDataSetSource.imageAnimation(forNoDataSet: self) {
                        imageView.layer.add(animation, forKey: kEmptyImageViewAnimationKey)
                    } else if imageView.layer.animation(forKey: kEmptyImageViewAnimationKey) != nil {
                        imageView.layer.removeAnimation(forKey: kEmptyImageViewAnimationKey)
                    }
                }

                /// 配置标题标签
                if let titleString = noDataSetSource.title(forNoDataSet: self) {
                    view.createTitleLabel(with: noDataSetSource.layout(forNoDataSet: self, for: .title)).attributedText = titleString
                }

                /// 配置详细标签
                if let detailString = noDataSetSource.detail(forNoDataSet: self) {
                    view.createDetailLabel(with: noDataSetSource.layout(forNoDataSet: self, for: .title)).attributedText = detailString
                }

                /// 配置按钮
                if let buttonImage = noDataSetSource.buttonImage(forNoDataSet: self, for: .normal) {
                    let button = view.createButton(with: noDataSetSource.layout(forNoDataSet: self, for: .button))
                    button.setImage(buttonImage, for: .normal)
                    button.setImage(noDataSetSource.buttonImage(forNoDataSet: self, for: .highlighted), for: .highlighted)
                    noDataSetSource.configure(forNoDataSet: self, for: button)
                } else if let titleString = noDataSetSource.buttonTitle(forNoDataSet: self, for: .normal) {
                    let button = view.createButton(with: noDataSetSource.layout(forNoDataSet: self, for: .button))
                    button.setAttributedTitle(titleString, for: .normal)
                    button.setAttributedTitle(noDataSetSource.buttonTitle(forNoDataSet: self, for: .highlighted), for: .highlighted)
                    button.setBackgroundImage(noDataSetSource.buttonBackgroundImage(forNoDataSet: self, for: .normal), for: .normal)
                    button.setBackgroundImage(noDataSetSource.buttonBackgroundImage(forNoDataSet: self, for: .highlighted), for: .highlighted)
                    noDataSetSource.configure(forNoDataSet: self, for: button)
                }
            }

            view.verticalOffset = noDataSetSource.verticalOffset(forNoDataSet: self)

            // 配置空数据集视图
            view.backgroundColor = noDataSetSource.backgroundColor(forNoDataSet: self) ?? UIColor.clear
            view.isHidden = view.elements.isEmpty // 如果视图集为空，则不显示
            view.clipsToBounds = true
            view.isUserInteractionEnabled = noDataSetDelegate?.noDataSetShouldAllowTouch(self) ?? true // 设置空数据集的用户交互权限
            if !view.isHidden { view.setupConstraints() } // 如果视图集不为空，则设置约束

            UIView.performWithoutAnimation { view.layoutIfNeeded() }
            isScrollEnabled = noDataSetDelegate?.noDataSetShouldAllowScroll(self) ?? false // 设置滚动权限

            noDataSetDelegate?.noDataSetDidAppear(self) // 通知委托空数据集视图已经呈现
        } else if isNoDataSetVisible {
            dismissNoDataSetIfNeeded()
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    func dismissNoDataSetIfNeeded() {
        var isNoDataSetVisible = false
        if let noDataSetView = noDataSetView {
            isNoDataSetVisible = true
            noDataSetDelegate?.noDataSetWillDisappear(self) // 通知委托空数据集视图将要消失

            noDataSetView.prepareForReuse()
            noDataSetView.removeFromSuperview()
            self.noDataSetView = nil
        }

        if isNoDataSetVisible {
            isScrollEnabled = noDataSetDelegate?.shouldAllowScrollAfterNoDataSetDisappear(self) ?? true
            noDataSetDelegate?.noDataSetDidDisappear(self) // 通知委托空数据集视图已经消失
        }
    }

    var noDataSetView: NoDataSet.View? {
        get { objc_getAssociatedObject(self, &kNoDataSetViewKey) as? NoDataSet.View }
        set { objc_setAssociatedObject(self, &kNoDataSetViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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

    private func makeNoDataSetView() -> NoDataSet.View {
        let view = NoDataSet.View(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        view.isTouchAllowed = { [weak self] in
            guard let `self` = self, let noDataSetDelegate = noDataSetDelegate else { return true }
            return noDataSetDelegate.noDataSetShouldAllowTouch(self)
        }
        view.shouldRecognizeSimultaneously = { [weak self](other, of) in
            guard let `self` = self, let noDataSetDelegate = noDataSetDelegate else { return false }
            if let scrollView = noDataSetDelegate as? UIScrollView, scrollView == self {
                return false
            }
            if let delegate = noDataSetDelegate as? UIGestureRecognizerDelegate {
                return delegate.gestureRecognizer?(of, shouldRecognizeSimultaneouslyWith: other) ?? false
            }
            return false
        }
        view.didTap = { [weak self] in
            guard let `self` = self, let noDataSetDelegate = noDataSetDelegate else { return }
            noDataSetDelegate.noDataSet(self, didTap: $0)
        }
        self.noDataSetView = view
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
            owner.reloadNoDataSetIfNeeded() // 重新加载空数据集。在调用`isNoDataSetVisible`属性之前进行此操作
        }

        let swizzledImplementation = imp_implementationWithBlock(unsafeBitCast(swizzledBlock, to: AnyObject.self))
        method_setImplementation(originalMethod, swizzledImplementation)

        kIMPLookupTable[key] = (originalClass, originalStringSelector) // 将新的实现存储在内存表中
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

// MARK: - Private keys

private var kNoDataSetSourceKey: Void?
private var kNoDataSetDelegateKey: Void?
private var kNoDataSetViewKey: Void?
private var kNoDataSetStatusKey: Void?
private let kEmptyImageViewAnimationKey = "com.liam.noDataSet.imageViewAnimation"
private var kIMPLookupTable = [String: (owner: AnyClass, selector: String)](minimumCapacity: 3)
