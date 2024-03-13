//
//  TableViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class TableViewController: UITableViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 TableViewController is released.")
        #endif
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        tabBarController?.navigationController?.popViewController(animated: true)
    }
    @IBAction func remove(_ sender: UIBarButtonItem) {
        colors.removeAll()
        tableView.reloadData()
    }
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        colors = Palette.shared.colors.shuffled()
        tableView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "tab_table"), tag: title!.hashValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bs.dataSource = self
        tableView.bs.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    var colors: [Color] = Palette.shared.colors.shuffled()
    var filteredColors: [Color] = []
    weak var searchController: UISearchController?
    var searchResult: ((Color) -> Void)?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isFiltering() else {
            return colors.count
        }
        return filteredColors.count
    }

    static let reuseIdentifier: String = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseIdentifier, for: indexPath)
        let color: Color
        if isFiltering() {
            color = filteredColors[indexPath.row]
        } else {
            color = colors[indexPath.row]
        }
        cell.textLabel?.text = color.name
        cell.detailTextLabel?.text = "#\(color.hex)"
        cell.imageView?.image = Color.roundThumb(with: color.color)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let color: Color
        if isFiltering() {
            color = filteredColors[indexPath.row]
            filteredColors.removeAll { $0 == color }
        } else {
            color = colors[indexPath.row]
            colors.removeAll { $0 == color }
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        action == #selector(copy(_:))
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        DispatchQueue.global().async {
            guard action == #selector(self.copy(_:)) else { return }
            let color: Color
            if self.isFiltering() {
                color = self.filteredColors[indexPath.row]
            } else {
                color = self.colors[indexPath.row]
            }
            UIPasteboard.general.string = color.hex
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let color: Color
        if isFiltering() {
            color = filteredColors[indexPath.row]
        } else {
            color = colors[indexPath.row]
        }
        if isFiltering() {
            searchResult?(color)
            searchController?.isActive = false
        } else {
            if shouldPerformSegue(withIdentifier: "table_push_detail", sender: color) {
                performSegue(withIdentifier: "table_push_detail", sender: color)
            }
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "table_push_detail" else { return }
        (segue.destination as! SearchViewController).selectedColor = sender as? Color
    }
}

extension TableViewController: BlankSlateDataSource, BlankSlateDelegate {
    func title(forBlankSlate view: UIView) -> NSAttributedString? {
        let text = isFiltering() ? "No colors Found" : "No colors loaded"
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
        let text = isFiltering() ? "Make sure that all words are\nspelled correctly." : "To show a list of random colors, tap on the refresh icon in the right top corner.\n\nTo clean the list, tap on the trash icon."
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
        guard isFiltering() else { return nil }
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
        UIImage(named: isFiltering() ? "search_icon" : "empty_placeholder")
    }

    func blankSlateShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        true
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        print(#function)
    }

    func blankSlate(_ view: UIView, didTapButton sender: UIButton) {
        print(#function)
    }
}

extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!.lowercased()
        filteredColors = colors.filter {
            $0.name.lowercased().contains(searchText) || $0.hex.lowercased().contains(searchText)
        }
        tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        searchController?.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        (searchController?.isActive ?? false) && !searchBarIsEmpty()
    }
}
