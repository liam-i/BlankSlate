//
//  DataSource.swift
//  BlankSlate <https://github.com/liam-i/BlankSlate>
//
//  Created by Liam on 2021/7/9.
//

import UIKit

/// The object that acts as the data source of the empty datasets.
/// - Note: The data source must adopt the `BlankSlateDataSource` protocol. The data source is not retained. All data source methods are optional.
public protocol BlankSlateDataSource: AnyObject {
    /// Asks the data source for the image of the dataset. `Default to nil`
    func image(forBlankSlate scrollView: UIScrollView) -> UIImage?

    /// Asks the `Alpha` of the data set image from the data source, the value range is [0.0~1.0]. `Default to 1.0`
    func imageAlpha(forBlankSlate scrollView: UIScrollView) -> CGFloat

    /// Asks the data source for a tint color of the image dataset. `Default to nil`
    func imageTintColor(forBlankSlate scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for the image animation of the dataset. `Default to nil`
    func imageAnimation(forBlankSlate scrollView: UIScrollView) -> CAAnimation?

    /// Asks the data source for the title of the dataset. `Default to nil`
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    func title(forBlankSlate scrollView: UIScrollView) -> NSAttributedString?

    /// Asks the data source for the description of the dataset. `Default to nil`
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    func detail(forBlankSlate scrollView: UIScrollView) -> NSAttributedString?

    /// Asks the data source for the title to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified title. The possible values are described in `UIControl.State`.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonTitle(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString?

    /// Asks the data source for a background image to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified image. The values are described in `UIControl.State`.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonBackgroundImage(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> UIImage?

    /// Asks the data source for the image to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified title. The possible values are described in `UIControl.State`.
    /// - Note: An image for the dataset button imageview.
    func buttonImage(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> UIImage?

    /// Asks the data source to configure the button style.
    /// - Parameter button: Buttons that need to be configured.
    func configure(forBlankSlate scrollView: UIScrollView, for button: UIButton)

    /// Asks the data source for the background color of the dataset. Default is clear color. `Detail to UIColor.clear`
    /// - Note: A color to be applied to the dataset background view.
    func backgroundColor(forBlankSlate scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// - Note: The custom view.
    func customView(forBlankSlate scrollView: UIScrollView) -> UIView?

    /// Asks the data source for a offset for vertical and horizontal alignment of the content. `Default is CGPoint.zero`.
    func offset(forBlankSlate scrollView: UIScrollView) -> CGPoint

    /// Asks the layout constraint value of `BlankSlate.Element` from the data source.
    func layout(forBlankSlate scrollView: UIScrollView, for element: BlankSlate.Element) -> BlankSlate.Layout

    /// Requests the duration of the fade-in animation from the data source when displaying an empty dataset. `Default to 0.0`
    /// - Returns: If `fadeInDuration <= 0.0` no animation is performed.
    func fadeInDuration(forBlankSlate scrollView: UIScrollView) -> TimeInterval
}

extension BlankSlateDataSource {
    public func image(forBlankSlate scrollView: UIScrollView) -> UIImage? { nil }
    public func imageAlpha(forBlankSlate scrollView: UIScrollView) -> CGFloat { 1.0 }
    public func imageTintColor(forBlankSlate scrollView: UIScrollView) -> UIColor? { nil }
    public func imageAnimation(forBlankSlate scrollView: UIScrollView) -> CAAnimation? { nil }

    public func title(forBlankSlate scrollView: UIScrollView) -> NSAttributedString? { nil }

    public func detail(forBlankSlate scrollView: UIScrollView) -> NSAttributedString? { nil }

    public func buttonTitle(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? { nil }
    public func buttonBackgroundImage(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    public func buttonImage(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> UIImage? { nil }
    public func configure(forBlankSlate scrollView: UIScrollView, for button: UIButton) { }

    public func backgroundColor(forBlankSlate scrollView: UIScrollView) -> UIColor? { .clear }

    public func customView(forBlankSlate scrollView: UIScrollView) -> UIView? { nil }

    public func offset(forBlankSlate scrollView: UIScrollView) -> CGPoint { .zero }

    public func layout(forBlankSlate scrollView: UIScrollView, for element: BlankSlate.Element) -> BlankSlate.Layout { .init() }

    public func fadeInDuration(forBlankSlate scrollView: UIScrollView) -> TimeInterval { 0.0 }
}
