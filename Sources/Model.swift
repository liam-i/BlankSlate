//
//  Model.swift
//  BlankSlate <https://github.com/liam-i/BlankSlate>
//
//  Created by Liam on 2021/12/20.
//

import UIKit

extension BlankSlate {
    /// Data loading status
    public enum DataLoadStatus {
        /// Data is loading.
        case loading
        /// Data loaded successfully. (With data or empty data)
        case success
        /// Data loading failed.
        case failure
    }

    /// Type of empty data set element
    public enum Element: CaseIterable {
        /// Image view
        case image
        /// Title label
        case title
        /// Detail label
        case detail
        /// Button control
        case button
        /// Custom views (if you don’t want to use the default `image`, `title`, `detail` and `button` elements; you can consider customizing)
        case custom
    }

    /// Control layout constraints
    public struct Layout {
        /// Padding around the edges of the control.
        /// - Note: UIEdgeInsets.bottom is only valid when the value of BlankSlate.Element is custom and button.
        public var edgeInsets: UIEdgeInsets
        /// The height of the control. Default: `nil`, represents adaptive height
        public var height: CGFloat?

        /// Initialize Layout
        /// - Parameters:
        ///   - edgeInsets: Padding around the edges of the control. `Default to UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)`
        ///   - height: The height of the control. Default: `nil`, represents adaptive height. `Default to nil`
        public init(edgeInsets: UIEdgeInsets = .init(top: 11, left: 16, bottom: 11, right: 16), height: CGFloat? = nil) {
            self.edgeInsets = edgeInsets
            self.height = height
        }

        /// Update attribute value. Executes the given block passing the `Self` in as its sole `inout` argument.
        /// - Parameter populator: A block or function that populates the `Self`, which is passed into the block as an `inout` argument.
        @discardableResult
        public mutating func with(_ populator: (inout Self) -> Void) -> Self {
            populator(&self)
            return self
        }
    }

    /// The vertical alignment of content within the BlankSlateView’s bounds.
    public enum Alignment {
        /// Aligns the content vertically in the center of the `BlankSlateView` (the default).
        /// - Parameters:
        ///   - x: A offset for horizontal alignment of the content. `Default to 0.0`.
        ///   - y: A offset for vertically alignment of the content. `Default to 0.0`.
        case center(x: CGFloat = 0.0, y: CGFloat = 0.0)
        /// Aligns the content vertically at the top in the `BlankSlateView`.
        /// - Parameters:
        ///   - x: A offset for horizontal alignment of the content. `Default to 0.0`.
        ///   - y: A offset for vertically alignment of the content. `Default to 0.0`.
        case top(x: CGFloat = 0.0, y: CGFloat = 0.0)
        /// Aligns the content vertically at the bottom in the `BlankSlateView`.
        /// - Parameters:
        ///   - x: A offset for horizontal alignment of the content. `Default to 0.0`.
        ///   - y: A offset for vertically alignment of the content. `Default to 0.0`.
        case bottom(x: CGFloat = 0.0, y: CGFloat = 0.0)
    }
}
