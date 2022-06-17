//
//  EmptyDataSetModel.swift
//  EmptyDataSet <https://github.com/liam-i/EmptyDataSet>
//
//  Created by Liam on 2021/12/20.
//

import UIKit

/// 数据加载状态
public enum EmptyDataLoadStatus {
    /// 数据加载中
    case loading
    /// 数据加载成功。（有数据和空数据）
    case success
    /// 数据加载失败
    case failed
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

/// 控件布局约束值
public struct ElementLayout {
    /// 控件边缘内间距。默认：`UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)`
    public let edgeInsets: UIEdgeInsets
    /// 控件高。默认：`nil`，代表自适应高
    public let height: CGFloat?

    /// 初始化 ElementLayout
    /// - Parameters:
    ///   - edgeInsets: 控件边缘内间距。默认：`UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)`
    ///   - height: 控件高。默认：`nil`，代表自适应高
    public init(edgeInsets: UIEdgeInsets = .default, height: CGFloat? = nil) {
        self.edgeInsets = edgeInsets
        self.height = height
    }
}

extension UIEdgeInsets {
    /// 默认：`UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)`
    public static let `default` = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
}
