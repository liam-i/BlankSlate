//
//  Impl.swift
//  BlankSlate <https://github.com/liam-i/BlankSlate>
//
//  Created by Liam on 2020/2/6.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

/// A drop-in UIView extension for showing empty datasets whenever the view has no content to display.
/// - Attention: It will work automatically, by just conforming to `BlankSlate.DataSource`, and returning the data you want to show.
extension UIView {
    weak var blankSlateDataSource: BlankSlate.DataSource? {
        get { (objc_getAssociatedObject(self, &kBlankSlateDataSourceKey) as? WeakObject)?.value as? BlankSlate.DataSource }
        set {
            if newValue == nil || blankSlateDataSource == nil {
                dismissBlankSlateIfNeeded()
            }

            objc_setAssociatedObject(self, &kBlankSlateDataSourceKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // We add method sizzling for injecting `reloadBlankSlateIfNeeded()` implementation to the native `reloadData()` implementation
            // Exclusively for UITableView, we also inject `reloadBlankSlateIfNeeded()` to `endUpdates()`
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

    weak var blankSlateDelegate: BlankSlate.Delegate? {
        get { (objc_getAssociatedObject(self, &kBlankSlateDelegateKey) as? WeakObject)?.value as? BlankSlate.Delegate }
        set {
            if newValue == nil {
                dismissBlankSlateIfNeeded()
            }
            objc_setAssociatedObject(self, &kBlankSlateDelegateKey, WeakObject(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dataLoadStatus: BlankSlate.DataLoadStatus? {
        get { objc_getAssociatedObject(self, &kBlankSlateStatusKey) as? BlankSlate.DataLoadStatus }
        set { objc_setAssociatedObject(self, &kBlankSlateStatusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func reloadIfNeeded() {
        switch self {
        case let tableView as UITableView:              tableView.reloadData()
        case let collectionView as UICollectionView:    collectionView.reloadData()
        default:                                        reloadBlankSlateIfNeeded()
        }
    }

    var blankSlateView: BlankSlate.View? {
        get { objc_getAssociatedObject(self, &kBlankSlateViewKey) as? BlankSlate.View }
        set { objc_setAssociatedObject(self, &kBlankSlateViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var isBlankSlateVisible: Bool {
        guard let blankSlateView else { return false }
        return blankSlateView.isHidden == false
    }

    func dismissBlankSlateIfNeeded() {
        guard let blankSlateView else { return }
        blankSlateDelegate?.blankSlateWillDisappear(self) // Notifies that the empty dataset view will disappear

        blankSlateView.prepareForReuse()
        blankSlateView.removeFromSuperview()
        self.blankSlateView = nil

        if let scrollView = self as? UIScrollView {
            scrollView.isScrollEnabled = blankSlateDelegate?.shouldAllowScrollAfterBlankSlateDisappear(scrollView) ?? true
        }
        blankSlateDelegate?.blankSlateDidDisappear(self) // Notifies that the empty dataset view did disappear
    }

    func reloadBlankSlateIfNeeded() {
        guard let blankSlateDataSource else {
            return dismissBlankSlateIfNeeded()
        }

        if ((blankSlateDelegate?.blankSlateShouldDisplay(self) ?? true) && (itemsCount == 0))
            || (blankSlateDelegate?.blankSlateShouldBeForcedToDisplay(self) ?? false) {
            blankSlateDelegate?.blankSlateWillAppear(self) // Notifies that the empty dataset view will appear

            configureView(blankSlateView ?? makeBlankSlateView(), with: blankSlateDataSource)

            blankSlateDelegate?.blankSlateDidAppear(self) // Notifies that the empty dataset view did appear
        } else if isBlankSlateVisible {
            dismissBlankSlateIfNeeded()
        }
    }

    private func configureView(_ view: BlankSlate.View, with blankSlateDataSource: BlankSlate.DataSource) {
        var fadeInDuration: TimeInterval = 0.0
        if view.superview == nil {
            // Configure empty dataset fade in display. Only the first "addSubview" requires gradient animation.
            fadeInDuration = blankSlateDataSource.fadeInDuration(forBlankSlate: self)
            view.alpha = 0.0

            if subviews.count > 1 && blankSlateDelegate?.blankSlateShouldBeInsertedAtBack(self) ?? true {
                insertSubview(view, at: 0)
            } else {
                addSubview(view)
            }
        }

        // Removing view resetting the view and its constraints it very important to guarantee a good state
        view.prepareForReuse()

        configureElements(for: view, with: blankSlateDataSource)

        // Configure offset
        view.alignment = blankSlateDataSource.alignment(forBlankSlate: self)

        // Configure the empty dataset view
        view.backgroundColor = blankSlateDataSource.backgroundColor(forBlankSlate: self) ?? .clear
        if let backgroundGradient = blankSlateDataSource.backgroundGradient(forBlankSlate: self) {
            view.layer.insertSublayer(backgroundGradient, at: 0)
        }
        view.isHidden = false
        view.isUserInteractionEnabled = blankSlateDelegate?.blankSlateShouldAllowTouch(self) ?? true // Configure empty dataset userInteraction permission
        view.setupConstraints()

        UIView.performWithoutAnimation { view.layoutIfNeeded() }

        if let scrollView = self as? UIScrollView {
            scrollView.isScrollEnabled = blankSlateDelegate?.blankSlateShouldAllowScroll(scrollView) ?? false // Configure scroll permission
        }

        guard fadeInDuration > 0.0 else {
            return view.alpha = 1.0
        }
        UIView.animate(withDuration: fadeInDuration) {
            view.alpha = 1.0
        }
    }

    private func configureElements(for view: BlankSlate.View, with blankSlateDataSource: BlankSlate.DataSource) {
        // If a non-nil custom view is available, let's configure it instead
        if let customView = blankSlateDataSource.customView(forBlankSlate: self) {
            return view.setCustomView(customView, layout: blankSlateDataSource.layout(forBlankSlate: self, for: .custom))
        }

        // Configure Image
        if let image = blankSlateDataSource.image(forBlankSlate: self) {
            let tintColor = blankSlateDataSource.imageTintColor(forBlankSlate: self)
            let imageView = view.makeImageView(with: blankSlateDataSource.layout(forBlankSlate: self, for: .image))
            imageView.image = image.withRenderingMode(tintColor != nil ? .alwaysTemplate : .alwaysOriginal)
            imageView.tintColor = tintColor
            imageView.alpha = blankSlateDataSource.imageAlpha(forBlankSlate: self)

            // Configure image view animation
            if let animation = blankSlateDataSource.imageAnimation(forBlankSlate: self) {
                imageView.layer.add(animation, forKey: kEmptyImageViewAnimationKey)
            } else if imageView.layer.animation(forKey: kEmptyImageViewAnimationKey) != nil {
                imageView.layer.removeAnimation(forKey: kEmptyImageViewAnimationKey)
            }
        }

        // Configure title label
        if let titleString = blankSlateDataSource.title(forBlankSlate: self) {
            view.makeTitleLabel(with: blankSlateDataSource.layout(forBlankSlate: self, for: .title)).attributedText = titleString
        }

        // Configure detail label
        if let detailString = blankSlateDataSource.detail(forBlankSlate: self) {
            view.makeDetailLabel(with: blankSlateDataSource.layout(forBlankSlate: self, for: .title)).attributedText = detailString
        }

        // Configure button
        if let buttonImage = blankSlateDataSource.buttonImage(forBlankSlate: self, for: .normal) {
            let button = view.makeButton(with: blankSlateDataSource.layout(forBlankSlate: self, for: .button))
            button.setImage(buttonImage, for: .normal)
            button.setImage(blankSlateDataSource.buttonImage(forBlankSlate: self, for: .highlighted), for: .highlighted)
            blankSlateDataSource.blankSlate(self, configure: button)
        } else if let titleString = blankSlateDataSource.buttonTitle(forBlankSlate: self, for: .normal) {
            let button = view.makeButton(with: blankSlateDataSource.layout(forBlankSlate: self, for: .button))
            button.setAttributedTitle(titleString, for: .normal)
            button.setAttributedTitle(blankSlateDataSource.buttonTitle(forBlankSlate: self, for: .highlighted), for: .highlighted)
            button.setBackgroundImage(blankSlateDataSource.buttonBackgroundImage(forBlankSlate: self, for: .normal), for: .normal)
            button.setBackgroundImage(blankSlateDataSource.buttonBackgroundImage(forBlankSlate: self, for: .highlighted), for: .highlighted)
            blankSlateDataSource.blankSlate(self, configure: button)
        }
    }

    private var itemsCount: Int {
        var items: Int = 0
        switch self {
        case let tableView as UITableView: // UITableView support
            guard let dataSource = tableView.dataSource else { return items }
            let sections = dataSource.numberOfSections?(in: tableView) ?? 1
            (0..<sections).forEach {
                items += dataSource.tableView(tableView, numberOfRowsInSection: $0)
            }
        case let collectionView as UICollectionView: // UICollectionView support
            guard let dataSource = collectionView.dataSource else { return items }
            let sections = dataSource.numberOfSections?(in: collectionView) ?? 1
            (0..<sections).forEach {
                items += dataSource.collectionView(collectionView, numberOfItemsInSection: $0)
            }
        default:
            break
        }
        return items
    }

    private func makeBlankSlateView() -> BlankSlate.View {
        let view = BlankSlate.View(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        view.isTouchAllowed = { [weak self] in
            guard let self, let blankSlateDelegate else { return true }
            return blankSlateDelegate.blankSlateShouldAllowTouch(self)
        }
        view.shouldRecognizeSimultaneously = { [weak self](other, of) in
            guard let self, let blankSlateDelegate else { return false }
            if let scrollView = blankSlateDelegate as? UIScrollView, scrollView == self {
                return false
            }
            if let delegate = blankSlateDelegate as? UIGestureRecognizerDelegate {
                // defer to blankSlateDelegate's implementation if available
                return delegate.gestureRecognizer?(of, shouldRecognizeSimultaneouslyWith: other) ?? false
            }
            return false
        }
        view.didTap = { [weak self] in
            guard let self, let blankSlateDelegate else { return }
            if let button = $0 as? UIButton {
                return blankSlateDelegate.blankSlate(self, didTapButton: button)
            }
            blankSlateDelegate.blankSlate(self, didTapView: $0)
        }
        blankSlateView = view
        return view
    }

    private func swizzleIfNeeded(_ originalClass: AnyClass, _ originalSelector: Selector) {
        // Check if the target responds to selector
        guard responds(to: originalSelector) else { return assertionFailure() }

        // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
        let originalStringSelector = NSStringFromSelector(originalSelector)
        for info in kIMPLookupTable.values where (info.selector == originalStringSelector && isKind(of: info.owner)) {
            return
        }

        // If the implementation for this class already exist, skip!!
        let key = "\(NSStringFromClass(originalClass))_\(originalStringSelector)"
        guard kIMPLookupTable[key] == nil else { return }

        // Swizzle by injecting additional implementation
        guard let originalMethod = class_getInstanceMethod(originalClass, originalSelector) else { return assertionFailure() }
        let originalImplementation = method_getImplementation(originalMethod)

        typealias OriginalIMP = @convention(c) (UIScrollView, Selector) -> Void

        let originalClosure = unsafeBitCast(originalImplementation, to: OriginalIMP.self)

        let swizzledBlock: @convention(block) (UIScrollView) -> Void = { owner in
            originalClosure(owner, originalSelector) // Call original implementation

            // We then inject the additional implementation for reloading the empty dataset
            // Doing it before calling the original implementation does update the 'isBlankSlateVisible' flag on time.
            owner.reloadBlankSlateIfNeeded()
        }

        let swizzledImplementation = imp_implementationWithBlock(unsafeBitCast(swizzledBlock, to: AnyObject.self))
        method_setImplementation(originalMethod, swizzledImplementation)

        kIMPLookupTable[key] = (originalClass, originalStringSelector) // Store the new implementation in the lookup table
    }
}

// MARK: - WeakObject

private class WeakObject {
    private(set) weak var value: AnyObject?

    init?(_ value: AnyObject?) {
        guard let value else { return nil }
        self.value = value
    }

    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 WeakObject is released.")
        #endif
    }
}

// MARK: - Private keys

private var kBlankSlateDataSourceKey: Void?
private var kBlankSlateDelegateKey: Void?
private var kBlankSlateViewKey: Void?
private var kBlankSlateStatusKey: Void?
private let kEmptyImageViewAnimationKey = "com.liam.blankSlate.imageViewAnimation"
private var kIMPLookupTable = [String: (owner: AnyClass, selector: String)](minimumCapacity: 3) // 3 represent the supported base classes
