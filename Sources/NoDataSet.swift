//
//  NoDataSet.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by liam on 2024/3/8.
//  Copyright © 2020 Liam. All rights reserved.
//

public struct NoDataSet {
    /// Type that acts as a generic extension point for all `NoDataSetExtended` types.
    public struct Extension<ExtendedViewType> {
        /// Stores the type or meta-type of any extended type.
        private let view: ExtendedViewType
        /// Create an instance from the provided value.
        /// - Parameter view: Instance being extended.
        public init(_ view: ExtendedViewType) {
            self.view = view
        }
    }

    /// Protocol describing the `nds` extension points for NoDataSet extended types.
    public protocol Extended {
        /// Type being extended.
        associatedtype ExtendedType
        /// Instance NoDataSet extension point.
        var nds: Extension<ExtendedType> { get set }
    }
}
extension NoDataSet.Extended {
    /// Instance NoDataSet extension point.
    public var nds: NoDataSet.Extension<Self> {
        get { NoDataSet.Extension(self) }
        set {}
    }
}

extension UIScrollView: NoDataSet.Extended {}
extension NoDataSet.Extension where ExtendedViewType: UIScrollView {
    /// 空数据集数据源
    public weak var dataSource: NoDataSetDataSource? {
        get { view.noDataSetSource }
        set { view.noDataSetSource = newValue }
    }

    /// 空数据集委托
    public weak var delegate: NoDataSetDelegate? {
        get { view.noDataSetDelegate }
        set { view.noDataSetDelegate = newValue }
    }

    /// 同时设置`NoDataSetDataSource` & `NoDataSetDelegate`
    public func setDataSourceAndDelegate(_ newValue: (NoDataSetDataSource & NoDataSetDelegate)?) {
        view.noDataSetSource = newValue
        view.noDataSetDelegate = newValue
    }

    /// 数据加载状态
    /// - Note: 为`UITableView`和`UICollectionView`设置此属性时自动执行`reloadData()`方法
    public var dataLoadStatus: NoDataSet.DataLoadStatus? {
        get { view.dataLoadStatus }
        set { view.dataLoadStatus = newValue }
    }

    /// 设置数据加载状态
    public func setDataLoadStatus(_ newValue: NoDataSet.DataLoadStatus?) {
        view.dataLoadStatus = newValue
    }

    /// 空视图集内容视图
    public var contentView: UIView? {
        view.noDataSetView
    }

    /// 如果空数据集可见，则为`true`
    public var isVisible: Bool {
        view.isNoDataSetVisible
    }

    /// 重新加载空数据集内容视图
    /// - Note: 调用此方法以强制刷新所有数据。类似于`reloadData()`，但这仅强制重新加载空数据集，而不强制重新加载整个表视图或集合视图
    public func reload() {
        view.reloadNoDataSetIfNeeded()
    }

    /// Dismisses the NoDataSet View.
    public func dismiss() {
        view.dismissNoDataSetIfNeeded()
    }
}
