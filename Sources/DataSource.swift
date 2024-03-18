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
    func image(forBlankSlate view: UIView) -> UIImage?

    /// Asks the `Alpha` of the data set image from the data source, the value range is [0.0~1.0]. `Default to 1.0`
    func imageAlpha(forBlankSlate view: UIView) -> CGFloat

    /// Asks the data source for a tint color of the image dataset. `Default to nil`
    func imageTintColor(forBlankSlate view: UIView) -> UIColor?

    /// Asks the data source for the image animation of the dataset. `Default to nil`
    func imageAnimation(forBlankSlate view: UIView) -> CAAnimation?

    /// Asks the data source for the title of the dataset. `Default to nil`
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    func title(forBlankSlate view: UIView) -> NSAttributedString?

    /// Asks the data source for the description of the dataset. `Default to nil`
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    func detail(forBlankSlate view: UIView) -> NSAttributedString?

    /// Asks the data source for the title to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified title. The possible values are described in `UIControl.State`.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonTitle(forBlankSlate view: UIView, for state: UIControl.State) -> NSAttributedString?

    /// Asks the data source for a background image to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified image. The values are described in `UIControl.State`.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonBackgroundImage(forBlankSlate view: UIView, for state: UIControl.State) -> UIImage?

    /// Asks the data source for the image to be used for the specified button state. `Default to nil`
    /// - Parameter state: The state that uses the specified title. The possible values are described in `UIControl.State`.
    /// - Note: An image for the dataset button imageview.
    func buttonImage(forBlankSlate view: UIView, for state: UIControl.State) -> UIImage?

    /// Asks the data source to configure the button style.
    /// - Parameter button: Buttons that need to be configured.
    func blankSlate(_ view: UIView, configure button: UIButton)

    /// Asks the data source for the background color of the dataset. `Detail to .clear`
    /// - Note: A color to be applied to the dataset background view.
    func backgroundColor(forBlankSlate view: UIView) -> UIColor?

    /// Asks the data source for the background gradient of the dataset. `Default to nil`
    /// - Returns: A gradient to be applied to the dataset background view.
    func backgroundGradient(forBlankSlate view: UIView) -> CAGradientLayer?

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. `Default to nil`.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// - Note: The custom view.
    func customView(forBlankSlate view: UIView) -> UIView?

    /// Ask the data source for the vertical alignment of the content. `Default to .center()`.
    func alignment(forBlankSlate view: UIView) -> BlankSlate.Alignment

    /// Asks the layout constraint value of `BlankSlate.Element` from the data source.
    func layout(forBlankSlate view: UIView, for element: BlankSlate.Element) -> BlankSlate.Layout

    /// Requests the duration of the fade-in animation from the data source when displaying an empty dataset. `Default to 0.0`
    /// - Note: If `fadeInDuration <= 0.0` no animation is performed.
    func fadeInDuration(forBlankSlate view: UIView) -> TimeInterval
}

extension BlankSlateDataSource {
    public func image(forBlankSlate view: UIView) -> UIImage? { nil }
    public func imageAlpha(forBlankSlate view: UIView) -> CGFloat { 1.0 }
    public func imageTintColor(forBlankSlate view: UIView) -> UIColor? { nil }
    public func imageAnimation(forBlankSlate view: UIView) -> CAAnimation? { nil }

    public func title(forBlankSlate view: UIView) -> NSAttributedString? { nil }

    public func detail(forBlankSlate view: UIView) -> NSAttributedString? { nil }

    public func buttonTitle(forBlankSlate view: UIView, for state: UIControl.State) -> NSAttributedString? { nil }
    public func buttonBackgroundImage(forBlankSlate view: UIView, for state: UIControl.State) -> UIImage? { nil }
    public func buttonImage(forBlankSlate view: UIView, for state: UIControl.State) -> UIImage? { nil }
    public func blankSlate(_ view: UIView, configure button: UIButton) { }

    public func backgroundColor(forBlankSlate view: UIView) -> UIColor? { .clear }
    public func backgroundGradient(forBlankSlate view: UIView) -> CAGradientLayer? { nil }

    public func customView(forBlankSlate view: UIView) -> UIView? { nil }

    public func alignment(forBlankSlate view: UIView) -> BlankSlate.Alignment { .center() }

    public func layout(forBlankSlate view: UIView, for element: BlankSlate.Element) -> BlankSlate.Layout { .init() }

    public func fadeInDuration(forBlankSlate view: UIView) -> TimeInterval { 0.0 }
}
