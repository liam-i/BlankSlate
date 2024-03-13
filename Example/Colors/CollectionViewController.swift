//
//  CollectionViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

private let reuseIdentifier = "Cell"
class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 CollectionViewController is released.")
        #endif
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        tabBarController?.navigationController?.popViewController(animated: true)
    }
    @IBAction func remove(_ sender: UIBarButtonItem) {
        filteredPalette.removeAll()
        collectionView.reloadData()
    }
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        filteredPalette = Palette.shared.colors.shuffled()
        collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "tab_collection"), tag: title!.hashValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical //.horizontal

        let inset = layout.minimumLineSpacing * 1.5
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: inset, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.bs.dataSource = self
        collectionView.bs.delegate = self
    }

    var columnCount: CGFloat {
        UIDevice.current.orientation.isLandscape ? 7 : 5
    }
    var filteredPalette: [Color] = Palette.shared.colors.shuffled()

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPalette.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        cell.backgroundColor = filteredPalette[indexPath.item].color
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let size = (tabBarController!.view.bounds.width / columnCount) - flowLayout.minimumLineSpacing
        return CGSize(width: size, height: size)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = filteredPalette[indexPath.item]
        if shouldPerformSegue(withIdentifier: "collection_push_detail", sender: color) {
            performSegue(withIdentifier: "collection_push_detail", sender: color)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "collection_push_detail" else { return }
        (segue.destination as! SearchViewController).selectedColor = sender as? Color
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
}

extension CollectionViewController: BlankSlateDataSource, BlankSlateDelegate {
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

    func image(forBlankSlate view: UIView) -> UIImage? {
        UIImage(named: "empty_placeholder")
    }
    
    func blankSlateShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        true
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        print(#function)
    }
}
