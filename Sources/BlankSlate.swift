//
//  BlankSlate.swift
//  BlankSlate <https://github.com/liam-i/BlankSlate>
//
//  Created by liam on 2024/3/8.
//  Copyright © 2020 Liam. All rights reserved.
//

/// A drop-in UITableView/UICollectionView superclass extension for showing empty datasets whenever the view has no content to display.
/// - Attention: It will work automatically, by just conforming to `BlankSlateDataSource`, and returning the data you want to show.
public struct BlankSlate {
    /// Type that acts as a generic extension point for all `BlankSlateExtended` types.
    public struct Extension<ExtendedViewType> {
        /// Stores the type or meta-type of any extended type.
        private let view: ExtendedViewType
        /// Create an instance from the provided value.
        /// - Parameter view: Instance being extended.
        public init(_ view: ExtendedViewType) {
            self.view = view
        }
    }

    /// Protocol describing the `bs` extension points for BlankSlate extended types.
    public protocol Extended: AnyObject {
        /// Type being extended.
        associatedtype ExtendedType
        /// Instance BlankSlate extension point.
        var bs: Extension<ExtendedType> { get set }
    }
}
extension BlankSlate.Extended {
    /// Instance BlankSlate extension point.
    public var bs: BlankSlate.Extension<Self> {
        get { BlankSlate.Extension(self) }
        set {}
    }
}

extension UIScrollView: BlankSlate.Extended {}
extension BlankSlate.Extension where ExtendedViewType: UIScrollView {
    /// The empty datasets data source.
    public weak var dataSource: BlankSlateDataSource? {
        get { view.blankSlateDataSource }
        set { view.blankSlateDataSource = newValue }
    }

    /// The empty datasets delegate.
    public weak var delegate: BlankSlateDelegate? {
        get { view.blankSlateDelegate }
        set { view.blankSlateDelegate = newValue }
    }

    /// Set `BlankSlateDataSource` & `BlankSlateDelegate` at the same time.
    public func setDataSourceAndDelegate(_ newValue: (BlankSlateDataSource & BlankSlateDelegate)?) {
        view.blankSlateDataSource = newValue
        view.blankSlateDelegate = newValue
    }

    /// Data loading status
    /// - Note: Automatically execute the `reloadData()` method when setting this property for `UITableView` and `UICollectionView`.
    public var dataLoadStatus: BlankSlate.DataLoadStatus? {
        get { view.dataLoadStatus }
        set { view.dataLoadStatus = newValue }
    }

    /// Blank slate content view
    public var contentView: UIView? {
        view.blankSlateView
    }

    /// true if any empty dataset is visible.
    public var isVisible: Bool {
        view.isBlankSlateVisible
    }

    /// Reloads the empty dataset content receiver.
    /// - Note: Call this method to force all the data to refresh. Calling `reloadData()` is similar, but this forces only the empty dataset to reload, not the entire table view or collection view.
    public func reload() {
        view.reloadBlankSlateIfNeeded()
    }

    /// Dismisses the BlankSlate View.
    public func dismiss() {
        view.dismissBlankSlateIfNeeded()
    }
}
