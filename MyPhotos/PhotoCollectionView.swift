//
//  PhotoCollectionView.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/16/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

// MARK: PhotoCollectionView

class PhotoCollectionView: UICollectionView {
    private struct Constants {
        static let photoBufferLength: Int = 300
    }

    var photos: Photos { return layout.photos }

    var layout: PhotosLayout {
        guard let layout = collectionViewLayout as? PhotosLayout else {
            fatalError("PhotoCollectionView: wrong layout class")
        }
        return layout
    }
    private(set) var isSettingLayout: Bool = false
    var numberOfColumns: Int {
        get { return layout.numberOfColumns }
        set {
            let newLayout = layout.clone()
            initLayout(newLayout)
            newLayout.numberOfColumns = newValue
            // Remove handler from the old layout so it does not update photos
            layout.itemSizeChanged = nil
            setCollectionViewLayout(newLayout, animated: true) { _ in
                // Update thumbnail images with the new size
                self.reloadItems(at: self.indexPathsForVisibleItems)
            }
        }
    }

    var isInDebugMode: Bool = false {
        didSet {
            showsVerticalScrollIndicator = isInDebugMode
            reloadData()
        }
    }
    var precachesThumbnailImages: Bool = false  // Setting to true degrades scrolling performance, maybe due to the large size of the buffer

    private var anchorIndex: Int = 0 {
        didSet {
            layout.anchorIndex = anchorIndex

            if precachesThumbnailImages {
                photos.updateCachingOfThumbnailImages(
                    oldRange: oldValue..<oldValue + Constants.photoBufferLength,
                    newRange: anchorIndex..<anchorIndex + Constants.photoBufferLength
                )
            }
        }
    }

    init(photos: Photos) {
        super.init(frame: .zero, collectionViewLayout: PhotosLayout(photos: photos))
        initLayout(layout)
        backgroundColor = .systemBackground
        showsVerticalScrollIndicator = false

        dataSource = self
        delegate = self
        register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)

        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange), name: Photos.didChangeNotification, object: photos)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
        isSettingLayout = true
        super.setCollectionViewLayout(layout, animated: animated)
        isSettingLayout = false
    }

    override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        isSettingLayout = true
        super.setCollectionViewLayout(layout, animated: animated, completion: completion)
        isSettingLayout = false
    }

    private func initLayout(_ layout: PhotosLayout) {
        layout.itemSizeChanged = { [unowned layout] itemSize in
            var imageSize = itemSize
            imageSize.width *= UIScreen.main.scale
            imageSize.height *= UIScreen.main.scale
            layout.photos.thumbnailImageSize = imageSize
        }
    }

    @objc private func handlePhotosDidChange() {
        reloadData()
    }
}

// MARK: - PhotoCollectionView: UICollectionViewDataSource

extension PhotoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.isEmpty ? 0 : Constants.photoBufferLength
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            fatalError("PhotoCollectionView: wrong cell type")
        }

        let actualIndex = anchorIndex + indexPath.item
        cell.tag = actualIndex
        if isInDebugMode {
            cell.label.isHidden = false
            cell.label.text = photos.captionForItem(at: actualIndex) + "\nbuffer: \(indexPath.item)"
        }
        photos.getThumbnailImage(at: actualIndex) { [weak cell] image in
            if cell?.tag == actualIndex && image != nil {
                cell?.imageView.image = image
            }
        }

        return cell
    }
}

// MARK: - PhotoCollectionView: UICollectionViewDelegateFlowLayout

extension PhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSettingLayout || contentSize == .zero {
            return
        }

        let contentOffsetBuffer = bounds.height
        let deadZoneBuffer = bounds.height

        if contentOffset.y < contentOffsetBuffer {
            let newAnchorOffset = bounds.maxY + contentOffsetBuffer - contentSize.height + deadZoneBuffer
            let indexPath = layout.indexPathForFirstItem(at: newAnchorOffset)
            if indexPath.item < 0 {
                let contentOffsetChange = layout.verticalOffsetForItem(at: indexPath)
                anchorIndex -= -indexPath.item
                contentOffset.y += -contentOffsetChange
            }
        }

        if bounds.maxY > contentSize.height - contentOffsetBuffer {
            let newAnchorOffset = contentOffset.y - contentOffsetBuffer - deadZoneBuffer
            let indexPath = layout.indexPathForFirstItem(at: newAnchorOffset)
            let contentOffsetChange = layout.verticalOffsetForItem(at: indexPath)
            anchorIndex += indexPath.item
            contentOffset.y -= contentOffsetChange
        }
    }
}
