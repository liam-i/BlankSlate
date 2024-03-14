//
//  ViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/13.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class ViewController: UIViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 ViewController is released.")
        #endif
    }

    var coun: Int = 0
    @IBAction func remove(_ sender: UIBarButtonItem) {
        coun += 1
        view.bs.reload()
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        view.bs.dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.bs.setDataSourceAndDelegate(self)
    }
}

extension ViewController: BlankSlateDataSource, BlankSlateDelegate {
    func title(forBlankSlate view: UIView) -> NSAttributedString? {
        let text = "No colors loaded"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 17.0),
            .foregroundColor: UIColor(red: 170 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ])
    }

    func detail(forBlankSlate view: UIView) -> NSAttributedString? {
        let text = "To show a list of random colors, tap on the refresh icon in the right top corner.\n\nTo clean the list, tap on the trash icon."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 15.0),
            .foregroundColor: UIColor(red: 170 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ])
    }

    func buttonTitle(forBlankSlate view: UIView, for state: UIControl.State) -> NSAttributedString? {
        let text = "Add a New Color"
        var color: UIColor
        if state == .highlighted {
            color = UIColor(red: 106 / 255.0, green: 187 / 255.0, blue: 227 / 255.0, alpha: 1.0)
        } else {
            color = UIColor(red: 44 / 255.0, green: 137 / 255.0, blue: 202 / 255.0, alpha: 1.0)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14.0),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ])
    }

    func image(forBlankSlate view: UIView) -> UIImage? {
        UIImage(named: "empty_placeholder")
    }

    func backgroundGradient(forBlankSlate view: UIView) -> CAGradientLayer? {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        return backgroundGradient
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        print(#function)
    }

    func blankSlate(_ view: UIView, didTapButton sender: UIButton) {
        print(#function)
    }

    func fadeInDuration(forBlankSlate view: UIView) -> TimeInterval {
        0.3
    }

    func layout(forBlankSlate view: UIView, for element: BlankSlate.Element) -> BlankSlate.Layout {
        coun.isMultiple(of: 2) ? .init() : .init(edgeInsets: .init(top: 40, left: 20, bottom: 40, right: 20))
    }
}
