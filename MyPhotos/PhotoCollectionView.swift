//
//  PhotoCollectionView.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/16/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class PhotoCollectionView: UICollectionView {
    private(set) var isLayingOutSubviews: Bool = false

    override func layoutSubviews() {
        isLayingOutSubviews = true
        super.layoutSubviews()
        isLayingOutSubviews = false
    }
}
