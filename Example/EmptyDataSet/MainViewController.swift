//
//  MainViewController.swift
//  EmptyDataSet
//
//  Created by Liam on 2020/2/10.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController { // , EmptyDataSetDataSource, EmptyDataSetDelegate
    private var platforms: [Platform] = {
        let url = Bundle.main.url(forResource: "applications", withExtension: "json")!
        return Platform.applicationsFromJSON(at: url)
    }()
    
    private var filteredApps: [Platform] {
    //    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    //    if ([searchBar isFirstResponder] && searchBar.text.length > 0) {
    //        NSPredicate *precidate = [NSPredicate predicateWithFormat:@"displayName CONTAINS[cd] %@", searchBar.text];
    //        return [self.applications filteredArrayUsingPredicate:precidate];
    //    }
        return platforms
    }
    
    // MARK: - View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resets styling
        guard let bar = navigationController?.navigationBar else { return }
        bar.titleTextAttributes = nil;
        bar.barTintColor = UIColor(hex: "f8f8f8")
        bar.isTranslucent = false
        bar.barStyle = .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EmptyDataSet"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredApps.count
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = filteredApps[indexPath.row]
        let controller = DetailViewController(with: app, platforms: platforms, allowShuffling: true)
        controller.hidesBottomBarWhenPushed = true
        if controller.preferredStatusBarStyle == .lightContent {
            navigationController?.navigationBar.barStyle = .black
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}
