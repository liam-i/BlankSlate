//
//  ViewController.swift
//  Example tvOS
//
//  Created by liam on 2024/2/6.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import LPEmptyDataSet

class ViewController: UIViewController, EmptyDataSetDataSource, EmptyDataSetDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        UIImage(named: "icon_wwdc")
    }

    func elementLayout(forEmptyDataSet scrollView: UIScrollView, for element: EmptyDataSetElement) -> ElementLayout {
        ElementLayout(edgeInsets: .init(top: 11, left: 16, bottom: 11, right: 16), height: 500)
    }
}
