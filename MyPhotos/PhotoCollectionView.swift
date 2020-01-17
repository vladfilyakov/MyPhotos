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

    override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
        isSettingLayout = true
        super.setCollectionViewLayout(layout, animated: animated)
        isSettingLayout = false
    }
}
