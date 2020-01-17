//
//  PhotosLayout.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class PhotosLayout: UICollectionViewFlowLayout {
    private struct Constants {
        static let columnSpacing: CGFloat = 2
        static let rowSpacing: CGFloat = 2
    }

    let photos: Photos

    var anchorIndex: Int = 0 {
        didSet {
            if anchorIndex != oldValue {
                invalidateLayout()
            }
        }
    }
    var numberOfColumns: Int = 3 {
        didSet {
            numberOfColumns = max(1, numberOfColumns)
            if numberOfColumns != oldValue {
                invalidateLayout()
            }
        }
    }

    required init(photos: Photos) {
        self.photos = photos
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func clone() -> Self {
        let layout = Self(photos: photos)
        layout.anchorIndex = anchorIndex
        layout.numberOfColumns = numberOfColumns
        return layout
    }

    override func prepare() {
        super.prepare()
        minimumLineSpacing = Constants.rowSpacing
        minimumInteritemSpacing = Constants.columnSpacing

        var availableWidth = collectionView?.bounds.width ?? UIScreen.main.bounds.width
        availableWidth -= CGFloat(numberOfColumns - 1) * Constants.columnSpacing
        let itemWidth = UIScreen.main.roundDownToDevicePixels(availableWidth / CGFloat(numberOfColumns))
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    func indexPathForFirstItem(at verticalOffset: CGFloat) -> IndexPath {
        let row = Int(floor(verticalOffset / (itemSize.height + minimumLineSpacing)))
        return IndexPath(item: max(-anchorIndex, row * numberOfColumns), section: 0)
    }

    func verticalOffsetForItem(at indexPath: IndexPath) -> CGFloat {
        let row = indexPath.item / numberOfColumns
        return CGFloat(row) * (itemSize.height + minimumLineSpacing)
    }
}
