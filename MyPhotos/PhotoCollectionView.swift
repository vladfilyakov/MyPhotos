//
//  PhotoCollectionView.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/16/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class PhotoCollectionView: UICollectionView {
    private(set) var isSettingLayout: Bool = false

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        showsVerticalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
        isSettingLayout = true
        super.setCollectionViewLayout(layout, animated: animated)
        isSettingLayout = false
    }
}
