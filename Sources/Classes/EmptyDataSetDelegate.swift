//
//  EmptyDataSetDelegate.swift
//  EmptyDataSet
//
//  Created by Liam on 2021/7/9.
//

import UIKit

/// 空数据集的委托协议
/// - Note: 所有委托方法都是可选的。使用此委托来接收操作回调
public protocol EmptyDataSetDelegate: AnyObject {
    /// 向委托请求当items数大于0时是否仍然显示空数据集。默认`false`
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool

    /// 向委托请求是否允许显示空数据集。 默认为`true`
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool

    /// 当 subviews.count > 1 时，向委托请求插入层级。-1. addSubview(EmptyDataSet); 0. insertSubview(EmptyDataSet, at: 0)。默认`0`
    func emptyDataSetShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int

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

    /// 向委托请求当空数据集已经消失后是否允许滚动。 默认为`true`
    func shouldAllowScrollAfterEmptyDataSetDisappear(_ scrollView: UIScrollView) -> Bool
}

extension EmptyDataSetDelegate {
    public func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool { false }

    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool { true }

    public func emptyDataSetShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int { 0 }

    public func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool { true }

    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool { false }

    public func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) { }

    public func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) { }

    public func emptyDataSetWillAppear(_ scrollView: UIScrollView) { }

    public func emptyDataSetDidAppear(_ scrollView: UIScrollView) { }

    public func emptyDataSetWillDisappear(_ scrollView: UIScrollView) { }

    public func emptyDataSetDidDisappear(_ scrollView: UIScrollView) { }

    public func shouldAllowScrollAfterEmptyDataSetDisappear(_ scrollView: UIScrollView) -> Bool { true }
}
