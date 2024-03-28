//
//  CustomViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/14.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class CustomViewController: UIViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 CustomViewController is released.")
        #endif
    }
    @IBAction func remove(_ sender: UIBarButtonItem) {
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

extension CustomViewController: BlankSlate.DataSource, BlankSlate.Delegate {
    func backgroundColor(forBlankSlate view: UIView) -> UIColor? { .orange }
    func alignment(forBlankSlate view: UIView) -> BlankSlate.Alignment { .center() }
    func fadeInDuration(forBlankSlate view: UIView) -> TimeInterval { 0.5 }
    func layout(forBlankSlate view: UIView, for element: BlankSlate.Element) -> BlankSlate.Layout { .init(height: 200) }

    func customView(forBlankSlate view: UIView) -> UIView? {
        class Custom: UIView {
            let iv = UIImageView(image: UIImage(named: "icon_vine"))
            override init(frame: CGRect) {
                super.init(frame: frame)
                iv.contentMode = .scaleAspectFit
                addSubview(iv)
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 5
                iv.layer.borderColor = UIColor.blue.cgColor
                iv.layer.borderWidth = 1
            }
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            deinit {
                #if DEBUG
                print("👍🏻👍🏻👍🏻 Custom is released.")
                #endif
            }
            override func layoutSubviews() {
                super.layoutSubviews()
                iv.frame = bounds.insetBy(dx: 50, dy: 50)
            }
        }
        return Custom()
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        print(#function)
    }

    func blankSlateWillAppear(_ view: UIView) {
        print(#function)
    }

    func blankSlateDidAppear(_ view: UIView) {
        print(#function)
    }

    func blankSlateWillDisappear(_ view: UIView) {
        print(#function)
    }

    func blankSlateDidDisappear(_ view: UIView) {
        print(#function)
    }
}
