//
//  PhotosLayout.swift
//  Photos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class PhotosLayout: UICollectionViewFlowLayout {
    private struct Constants {
        static let itemSpacing: CGFloat = 6
    }

    var numberOfColumns: Int = 4 {
        didSet {
            numberOfColumns = max(1, numberOfColumns)
            if numberOfColumns != oldValue {
                invalidateLayout()
            }
        }
    }

    override func prepare() {
        super.prepare()
        minimumLineSpacing = Constants.itemSpacing
        minimumInteritemSpacing = Constants.itemSpacing

        var availableWidth = collectionView?.bounds.width ?? UIScreen.main.bounds.width
        availableWidth -= CGFloat(numberOfColumns - 1) * Constants.itemSpacing
        let itemWidth = UIScreen.main.roundDownToDevicePixels(availableWidth / CGFloat(numberOfColumns))
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
}
