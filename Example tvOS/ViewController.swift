//
//  ViewController.swift
//  Example tvOS
//
//  Created by liam on 2024/2/6.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class ViewController: UIViewController, BlankSlateDataSource, BlankSlateDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bs.dataSource = self
        tableView.bs.delegate = self
    }

    func image(forBlankSlate view: UIView) -> UIImage? {
        UIImage(named: "icon_wwdc")
    }

    func layout(forBlankSlate scrollView: UIScrollView, for element: BlankSlate.Element) -> BlankSlate.Layout {
        BlankSlate.Layout(edgeInsets: .init(top: 11, left: 16, bottom: 11, right: 16), height: 500)
    }
}
