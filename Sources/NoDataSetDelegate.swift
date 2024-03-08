//
//  NoDataSetDelegate.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by Liam on 2021/7/9.
//

import UIKit

/// 空数据集的委托协议
/// - Note: 所有委托方法都是可选的。使用此委托来接收操作回调
public protocol NoDataSetDelegate: AnyObject {
    /// 向委托请求当items数大于0时是否仍然显示空数据集。默认`false`
    func noDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool

    /// 向委托请求是否允许显示空数据集。 默认为`true`
    func noDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool

    /// 当 subviews.count > 1 时，向委托请求插入层级。-1. addSubview(NoDataSet); 0. insertSubview(NoDataSet, at: 0)。默认`0`
    func noDataSetShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int

    /// 向委托请求是否允许响应触摸手势。 默认为`true`
    func noDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool

    /// 向委托请求是否允许滚动。 默认为`false`
    func noDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool

    /// 通知委托该空数据集视图被触摸
    /// - Parameter view: 用户点击的视图
    func noDataSet(_ scrollView: UIScrollView, didTap view: UIView)

    /// 通知委托该操作按钮被点击
    /// - Parameter button: 用户点击的按钮
    func noDataSet(_ scrollView: UIScrollView, didTap button: UIButton)

    /// 通知委托该空数据集将要显示
    func noDataSetWillAppear(_ scrollView: UIScrollView)

    /// 通知委托该空数据集已经显示
    func noDataSetDidAppear(_ scrollView: UIScrollView)

    /// 通知委托该空数据集将要消失
    func noDataSetWillDisappear(_ scrollView: UIScrollView)

    /// 通知委托该空数据集已经消失
    func noDataSetDidDisappear(_ scrollView: UIScrollView)

    /// 向委托请求当空数据集已经消失后是否允许滚动。 默认为`true`
    func shouldAllowScrollAfterNoDataSetDisappear(_ scrollView: UIScrollView) -> Bool
}

extension NoDataSetDelegate {
    public func noDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool { false }

    public func noDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool { true }

    public func noDataSetShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int { 0 }

    public func noDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool { true }

    public func noDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool { false }

    public func noDataSet(_ scrollView: UIScrollView, didTap view: UIView) { }

    public func noDataSet(_ scrollView: UIScrollView, didTap button: UIButton) { }

    public func noDataSetWillAppear(_ scrollView: UIScrollView) { }

    public func noDataSetDidAppear(_ scrollView: UIScrollView) { }

    public func noDataSetWillDisappear(_ scrollView: UIScrollView) { }

    public func noDataSetDidDisappear(_ scrollView: UIScrollView) { }

    public func shouldAllowScrollAfterNoDataSetDisappear(_ scrollView: UIScrollView) -> Bool { true }
}
