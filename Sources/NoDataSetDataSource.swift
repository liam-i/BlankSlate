//
//  NoDataSetDataSource.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by Liam on 2021/7/9.
//

import UIKit

/// 空数据集的数据源协议
/// - Note: 数据源必须采用`NoDataSetDataSource`协议。所有数据源方法都是可选的
public protocol NoDataSetDataSource: AnyObject {
    /// 向数据源请求数据集的图像。默认`nil`
    func image(forNoDataSet scrollView: UIScrollView) -> UIImage?

    /// 向数据源请求数据集图像的`Alpha`，取值范围[0.0~1.0]。默认`1.0`
    func imageAlpha(forNoDataSet scrollView: UIScrollView) -> CGFloat

    /// 向数据源请求数据集图像的`TintColor`。默认`nil`
    func imageTintColor(forNoDataSet scrollView: UIScrollView) -> UIColor?

    /// 向数据源请求数据集的图像动画，默认`nil`
    func imageAnimation(forNoDataSet scrollView: UIScrollView) -> CAAnimation?

    /// 向数据源请求数据集的标题文本。默认`nil`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func title(forNoDataSet scrollView: UIScrollView) -> NSAttributedString?

    /// 向数据源请求数据集的明细文本。默认`nil`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func detail(forNoDataSet scrollView: UIScrollView) -> NSAttributedString?

    /// 向数据源请求用于指定按钮状态的标题。默认`nil`
    /// - Parameter state: 指定标题的状态。详情请见`UIControl.State`
    /// - Note: 如果未设置任何属性，则默认使用固定字体样式。如果要使用其他字体样式，请见`NSAttributedString`
    func buttonTitle(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString?

    /// 向数据源请求用于指定按钮状态的背景图像。默认`nil`
    /// - Parameter state: 指定图像的状态。详情请见`UIControl.State`
    func buttonBackgroundImage(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?

    /// 向数据源请求用于指定按钮状态的图像。默认`nil`
    /// - Parameter state: 指定图像的状态。详情请见`UIControl.State`
    /// - Note: 此方法将覆盖`buttonTitle(forNoDataSet:for:)`函数
    func buttonImage(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?

    /// 向数据源请求去配置按钮样式
    /// - Parameter button: 需要配置的按钮
    func configure(forNoDataSet scrollView: UIScrollView, for button: UIButton)

    /// 向数据源请求数据集的背景色。 默认`UIColor.clear`
    func backgroundColor(forNoDataSet scrollView: UIScrollView) -> UIColor?

    /// 向数据源请求自定义空数据集视图，而不显示默认视图，例如`labels`、`imageview`和`button`。默认`nil`
    func customView(forNoDataSet scrollView: UIScrollView) -> UIView?

    /// 向数据源请求内容垂直对齐的偏移量。默认`0pt`
    func verticalOffset(forNoDataSet scrollView: UIScrollView) -> CGFloat

    /// 向数据源请求`NoDataSetElement`的布局约束值。
    func elementLayout(forNoDataSet scrollView: UIScrollView, for element: NoDataSetElement) -> ElementLayout

    /// 向数据源请求在显示空数据集时采用淡入动画的持续时间。默认`0`
    /// - Note: 如果`fadeInDuration <= 0`则不执行动画
    func fadeInDuration(forNoDataSet scrollView: UIScrollView) -> TimeInterval
}

extension NoDataSetDataSource {
    public func image(forNoDataSet scrollView: UIScrollView) -> UIImage? { nil }
    public func imageAlpha(forNoDataSet scrollView: UIScrollView) -> CGFloat { 1.0 }
    public func imageTintColor(forNoDataSet scrollView: UIScrollView) -> UIColor? { nil }
    public func imageAnimation(forNoDataSet scrollView: UIScrollView) -> CAAnimation? { nil }

    public func title(forNoDataSet scrollView: UIScrollView) -> NSAttributedString? { nil }

    public func detail(forNoDataSet scrollView: UIScrollView) -> NSAttributedString? { nil }

    public func buttonTitle(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { nil }
    public func buttonBackgroundImage(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    public func buttonImage(forNoDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    public func configure(forNoDataSet scrollView: UIScrollView, for button: UIButton) { }

    public func backgroundColor(forNoDataSet scrollView: UIScrollView) -> UIColor? { UIColor.clear }

    public func customView(forNoDataSet scrollView: UIScrollView) -> UIView? { nil }

    public func verticalOffset(forNoDataSet scrollView: UIScrollView) -> CGFloat { 0.0 }

    public func elementLayout(forNoDataSet scrollView: UIScrollView, for element: NoDataSetElement) -> ElementLayout { .default }

    public func fadeInDuration(forNoDataSet scrollView: UIScrollView) -> TimeInterval { 0.0 }
}
