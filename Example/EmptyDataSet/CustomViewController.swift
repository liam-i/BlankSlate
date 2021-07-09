//
//  CustomViewController.swift
//  EmptyDataSet
//
//  Created by pengli on 2020/2/11.
//  Copyright © 2020 pengli. All rights reserved.
//

import UIKit
import EmptyDataSet

private let reuseIdentifier = "Cell"
class CustomViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var isEmptyData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom"
        edgesForExtendedLayout = []
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    @IBAction func emptyDataButtonClicked(_ sender: UIBarButtonItem) {
        isEmptyData = !isEmptyData
        if isEmptyData {
            let type: EmptyDataSetType = collectionView.emptyDataSetType == .error ? .empty : .error
            return collectionView.reloadAllData(with: type)
        }
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEmptyData ? 0 : 200
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.contentView.backgroundColor = UIColor.red
        return cell
    }
}

extension CustomViewController: EmptyDataSetDataSource, EmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return UIImageView(image: scrollView.emptyDataSetType == .error ? #imageLiteral(resourceName: "placeholder_vine") : #imageLiteral(resourceName: "icon_wwdc"))
    }
    
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return scrollView.emptyDataSetType == .error ? #imageLiteral(resourceName: "placeholder_vine") : #imageLiteral(resourceName: "icon_wwdc")
//    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
