//
//  NoDataSet.swift
//  NoDataSet <https://github.com/liam-i/NoDataSet>
//
//  Created by liam on 2024/3/8.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

/// Type that acts as a generic extension point for all `NoDataSetExtended` types.
public struct NoDataSet<ExtendedViewType> {
    /// Stores the type or meta-type of any extended type.
    private let view: ExtendedViewType
    /// Create an instance from the provided value.
    /// - Parameter view: Instance being extended.
    public init(_ view: ExtendedViewType) {
        self.view = view
    }
}

/// Protocol describing the `nds` extension points for NoDataSet extended types.
public protocol NoDataSetExtended {
    /// Type being extended.
    associatedtype ExtendedType
    /// Instance NoDataSet extension point.
    var nds: NoDataSet<ExtendedType> { get }
}
extension NoDataSetExtended {
    /// Instance NoDataSet extension point.
    public var nds: NoDataSet<Self> { NoDataSet(self) }
}

extension UIScrollView: NoDataSetExtended {}

extension NoDataSet where ExtendedViewType: UIScrollView {

}
