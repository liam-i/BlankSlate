//
//  SearchViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class SearchViewController: UIViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 SearchViewController is released.")
        #endif
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        if navigationController!.viewControllers.count == 1 {
            tabBarController?.navigationController?.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "tab_search"), tag: title!.hashValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController, navigationController.viewControllers.count == 1 {
            let searchResultsController = storyboard!.instantiateViewController(withIdentifier: "SBIDTableVC") as! TableViewController
            let searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.searchResultsUpdater = searchResultsController
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search Color"
            navigationItem.searchController = searchController
            definesPresentationContext = true
            self.searchController = searchController
            searchResultsController.searchController = searchController
            searchResultsController.searchResult = { [weak self](selectedColor) in
                guard let `self` = self else { return }
                self.selectedColor = selectedColor
                self.updateContent()
            }
        } else {
            title = "Detail"
        }
        updateContent()
    }

    @IBOutlet weak var colorView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hexLegend: UILabel!
    @IBOutlet weak var hexLabel: UILabel!
    @IBOutlet weak var rgbLegend: UILabel!
    @IBOutlet weak var rgbLabel: UILabel!
    var selectedColor: Color?

    var searchController: UISearchController?
    var searchResult: [String] = []
    lazy var isShowingLandscape: Bool = UIDevice.current.orientation.isLandscape

    private func updateContent() {
        let hide = selectedColor != nil ? false : true

        colorView.isHidden = hide
        nameLabel.isHidden = hide
        hexLabel.isHidden = hide
        rgbLabel.isHidden = hide
        hexLegend.isHidden = hide
        rgbLegend.isHidden = hide

        guard let selectedColor else { return }
        colorView.image = Color.roundImage(for: colorView.frame.size, with: selectedColor.color)
        nameLabel.text = selectedColor.name
        hexLabel.text = String(format: "#%@", selectedColor.hex)
        rgbLabel.text = selectedColor.rgb
    }
}
