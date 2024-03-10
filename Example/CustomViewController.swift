//
//  CustomViewController.swift
//  NoDataSet
//
//  Created by Liam on 2020/2/11.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit
import NoDataSet
import FlyHUD

private let reuseIdentifier = "Cell"
class CustomViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var dataNumber: Int = 0
    private var isFailed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom"
        edgesForExtendedLayout = []

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.nds.setDataSourceAndDelegate(self)
    }

    @IBAction func emptyDataButtonClicked(_ sender: UIBarButtonItem) {
        switch collectionView.nds.dataLoadStatus {
        case .loading:
            dataNumber = 10
            collectionView.nds.dataLoadStatus = .success
        case .success:
            dataNumber = 0
            collectionView.nds.dataLoadStatus = .failed
        case .failed:
            dataNumber = 0
            self.collectionView.nds.dataLoadStatus = .loading
            HUD.show(to: collectionView, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                HUD.hide(for: self.collectionView, animated: true)
                self.isFailed.toggle()
                self.dataNumber = self.isFailed ? 0 : 50
                self.collectionView.nds.dataLoadStatus = .success
            }
        default:
            self.dataNumber = 100
            collectionView.nds.dataLoadStatus = .success
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataNumber
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.contentView.backgroundColor = UIColor.red
        return cell
    }
}

extension CustomViewController: NoDataSetDataSource, NoDataSetDelegate {
    func noDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        switch scrollView.nds.dataLoadStatus {
        case .loading:  return false
        default:        return true
        }
    }

    func customView(forNoDataSet scrollView: UIScrollView) -> UIView? {
        let image = scrollView.nds.dataLoadStatus == .failed ? #imageLiteral(resourceName: "placeholder_vine") : #imageLiteral(resourceName: "icon_wwdc")
        return UIImageView(image:  image)
    }

//    func image(forNoDataSet scrollView: UIScrollView) -> UIImage? {
//        return scrollView.noDataSetType == .error ? #imageLiteral(resourceName: "placeholder_vine") : #imageLiteral(resourceName: "icon_wwdc")
//    }

    func noDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
