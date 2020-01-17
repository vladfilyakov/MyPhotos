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

// TODO: Cancel requests for thumbnail images that are not needed anymore?

class Photos: NSObject {
    static let didChangeNotification = Notification.Name("Photos.didChangeNotification")

    var isEmpty: Bool { return assets.count == 0 }

    var thumbnailImageSize = CGSize(width: 500, height: 500)

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        assets = fetchAssets()
    }

    private var assets: PHFetchResult<PHAsset>! {
        didSet {
            NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
        }
    }
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        return options
    }()

    func captionForItem(at index: Int) -> String {
        return "index: \(index)\n" + "photo: \(assetIndex(for: index) ?? -1)"
    }

    func getThumbnailImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard let assetIndex = assetIndex(for: index) else {
            completion(nil)
            return
        }

        let asset = assets[assetIndex]

        imageManager.requestImage(for: asset, targetSize: thumbnailImageSize, contentMode: .aspectFill, options: imageRequestOptions) { image, _ in
            completion(image)
        }
    }

    func updateCachingOfThumbnailImages(oldRange: Range<Int>, newRange: Range<Int>) {
        let oldIndexes = assetIndexes(for: oldRange)
        let newIndexes = assetIndexes(for: newRange)
        stopCachingThumbnailImages(at: oldIndexes.subtracting(newIndexes))
        startCachingThumbnailImages(at: newIndexes.subtracting(oldIndexes))
    }

    private func assetIndex(for index: Int) -> Int? {
        if assets.count == 0 {
            return nil
        }
        return index % assets.count
    }

    private func assetIndexes(for range: Range<Int>) -> IndexSet {
        guard let start = assetIndex(for: range.startIndex), let end = assetIndex(for: range.endIndex) else {
            return IndexSet()
        }
        if start <= end {
            return IndexSet(integersIn: start..<end)
        } else {
            return IndexSet(integersIn: start..<assets.count).union(IndexSet(integersIn: 0..<end))
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

    private func startCachingThumbnailImages(at indexes: IndexSet) {
        imageManager.startCachingImages(for: assets.objects(at: indexes), targetSize: thumbnailImageSize, contentMode: .aspectFill, options: imageRequestOptions)
    }

    private func stopCachingThumbnailImages(at indexes: IndexSet) {
        imageManager.stopCachingImages(for: assets.objects(at: indexes), targetSize: thumbnailImageSize, contentMode: .aspectFill, options: imageRequestOptions)
    }
}

// MARK: - Photos: PHPhotoLibraryChangeObserver

extension Photos: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let changeDetails = changeInstance.changeDetails(for: self.assets) {
                if !changeDetails.hasIncrementalChanges {
                    self.assets = changeDetails.fetchResultAfterChanges
                }
            } else {
                self.assets = self.fetchAssets()
            }
        }
    }
}
