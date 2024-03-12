//
//  ApplicationsTableViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class ApplicationsTableViewController: UITableViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 ApplicationsTableViewController is released.")
        #endif
    }

    private var applications: [Application] = []

    private let searchController = UISearchController(searchResultsController: nil)

    private var filteredApps: [Application] {
        let searchBar = searchController.searchBar
        if applications.isEmpty == false, searchBar.isFirstResponder,
            let searchText = searchBar.text, searchText.count > 0 {
            return applications.filter {
                $0.displayName.lowercased().contains(searchText.lowercased())
            }
        }
        return applications
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Applications"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.bs.setDataSourceAndDelegate(self)
        loadData()
    }

    private func loadData() {
        DispatchQueue.global().async {
            self.applications = Application.fromJSON(
                at: Bundle.main.url(forResource: "applications", withExtension: "json")!
            )
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source & delegat

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredApps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let app = filteredApps[indexPath.row]
        cell.textLabel?.text = app.displayName
        cell.detailTextLabel?.text = app.developerName

        let image = UIImage(named: app.iconName)!
        cell.imageView?.image = image
        cell.imageView?.layer.cornerRadius = image.size.width * 0.2
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        cell.imageView?.layer.borderWidth = 0.5
        cell.imageView?.layer.shouldRasterize = true
        cell.imageView?.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ApplicationDetailViewController(with: filteredApps[indexPath.row], applications: applications)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ApplicationsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
}

extension ApplicationsTableViewController: BlankSlateDataSource, BlankSlateDelegate {
    func title(forBlankSlate scrollView: UIScrollView) -> NSAttributedString? {
        NSAttributedString(string: "No Application Found")
    }
    
    func detail(forBlankSlate scrollView: UIScrollView) -> NSAttributedString? {
        guard let searchText = searchController.searchBar.text else { return nil }
        let attributedString = NSMutableAttributedString(string: "There are no empty dataset examples for \"")
        attributedString.append(NSAttributedString(string: searchText, attributes: [.font: UIFont.boldSystemFont(ofSize: 17.0)]))
        attributedString.append(NSAttributedString(string: "\"."))
        return attributedString
    }

    func buttonTitle(forBlankSlate scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        NSAttributedString(string: "Search on the App Store", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0),
            .foregroundColor: (state == .normal ? UIColor(hex: "007aff") : UIColor(hex: "c6def9")) ?? .black
        ])
    }

    func blankSlateShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        true
    }

    func blankSlate(_ scrollView: UIScrollView, didTapView sender: UIView) {
        print(#function)
    }

    func blankSlate(_ scrollView: UIScrollView, didTapButton sender: UIButton) {
        guard let searchText = searchController.searchBar.text
            , let url = URL(string: "http://itunes.com/apps/\(searchText)") else { return }
        
        guard UIApplication.shared.canOpenURL(url) else {
            return print("Can't open \(url)")
        }
        UIApplication.shared.open(url)
    }
}
