//
//  Photos.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/9/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import Foundation
import Photos
import UIKit

// MARK: Photos

class Photos: NSObject {
    private struct Constants {
        static let targetImageSize = CGSize(width: 500, height: 500)   //!!!
    }

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        assets = fetchAssets()
    }

    private var assets: PHFetchResult<PHAsset>!
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        return options
    }()

    func captionForItem(at index: Int) -> String {
        return "\(index)"
    }

    func getThumbnailImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard assets.count > 0 else {
            completion(nil)
            return
        }

        let photoIndex = index % assets.count
        let asset = assets[photoIndex]

        imageManager.requestImage(for: asset, targetSize: Constants.targetImageSize, contentMode: .aspectFill, options: imageRequestOptions) { image, _ in
            completion(image)
        }
    }

    private func fetchAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        return PHAsset.fetchAssets(with: .image, options: options)
    }
}

// MARK: - Photos: PHPhotoLibraryChangeObserver

extension Photos: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let changeDetails = changeInstance.changeDetails(for: self.assets) {
                self.assets = changeDetails.fetchResultAfterChanges
            } else {
                self.assets = self.fetchAssets()
            }
        }
    }
}
