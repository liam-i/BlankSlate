//
//  ViewController.swift
//  Example tvOS
//
//  Created by liam on 2024/2/6.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import NoDataSet

class ViewController: UIViewController, NoDataSetDataSource, NoDataSetDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.noDataSetSource = self
        tableView.noDataSetDelegate = self
    }

    func image(forNoDataSet scrollView: UIScrollView) -> UIImage? {
        UIImage(named: "icon_wwdc")
    }

    func elementLayout(forNoDataSet scrollView: UIScrollView, for element: NoDataSetElement) -> ElementLayout {
        ElementLayout(edgeInsets: .init(top: 11, left: 16, bottom: 11, right: 16), height: 500)
    }
}
