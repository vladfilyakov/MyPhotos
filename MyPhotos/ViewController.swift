//
//  ViewController.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

//!!! Thumbnail image size optimization?
//!!! Cancel requests for images that are not needed anymore?

// MARK: ViewController

class ViewController: UIViewController {
    private enum ImageSize: CaseIterable {
        case extraSmall
        case small
        case medium
        case large

        var numberOfColumns: Int {
            switch self {
            case .extraSmall:
                return 4
            case .small:
                return 3
            case .medium:
                return 2
            case .large:
                return 1
            }
        }

        var displayName: String {
            switch self {
            case .extraSmall:
                return "Extra Small"
            case .small:
                return "Small"
            case .medium:
                return "Medium"
            case .large:
                return "Large"
            }
        }

    }

    private struct Constants {
        static let photoBufferLength: Int = 300
    }

    private let photos = Photos()

    private lazy var photosView = PhotoCollectionView(frame: .zero, collectionViewLayout: PhotosLayout(photos: photos))
    private var photosLayout: PhotosLayout {
        guard let photosLayout = photosView.collectionViewLayout as? PhotosLayout else {
            fatalError("Collection view has a wrong layout class")
        }
        return photosLayout
    }
    private lazy var imageSizeSelector: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ImageSize.allCases.map { $0.displayName })
        segmentedControl.addTarget(self, action: #selector(handleImageSizeChanged), for: .valueChanged)
        return segmentedControl
    }()

    private var anchorIndex: Int = 0 {
        didSet {
            photosLayout.anchorIndex = anchorIndex

            if precachesThumbnailImages {
                photos.updateCachingOfThumbnailImages(
                    oldRange: oldValue..<oldValue + Constants.photoBufferLength,
                    newRange: anchorIndex..<anchorIndex + Constants.photoBufferLength
                )
            }
        }
    }
    private var imageSize: ImageSize = .small {
        didSet {
            updatePhotosLayout()
        }
    }
    private var precachesThumbnailImages: Bool = false  // Setting to true degrades scrolling performance, maybe due to the large size of the buffer

    private var isInDebugMode: Bool = false {
        didSet {
            photosView.showsVerticalScrollIndicator = isInDebugMode
            photosView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        photosView.backgroundColor = .systemBackground
        photosView.dataSource = self
        photosView.delegate = self
        photosView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        photosView.frame = view.bounds
        photosView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(photosView)

        updatePhotosLayout()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Debug", style: .plain, target: self, action: #selector(handleDebugButtonTap))
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: imageSizeSelector),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]

        imageSizeSelector.selectedSegmentIndex = imageSize.index

        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange), name: Photos.didChangeNotification, object: photos)
    }

    private func updatePhotosLayout() {
        let newLayout = photosLayout.clone()
        newLayout.numberOfColumns = imageSize.numberOfColumns
        photosView.setCollectionViewLayout(newLayout, animated: true)
    }

    @objc private func handleImageSizeChanged() {
        imageSize = ImageSize.allCases[imageSizeSelector.selectedSegmentIndex]
    }

    @objc private func handleDebugButtonTap() {
        isInDebugMode = !isInDebugMode
    }

    @objc private func handlePhotosDidChange() {
        photosView.reloadData()
    }
}

// MARK: - ViewController: UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.isEmpty ? 0 : Constants.photoBufferLength
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            fatalError("Wrong cell type")
        }

        //!!!
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

// MARK: - ViewController: UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //!!!
        if photosView.isSettingLayout || scrollView.contentSize == .zero {
            return
        }

        let contentOffsetBuffer = scrollView.bounds.height
        let deadZoneBuffer = scrollView.bounds.height

        if scrollView.contentOffset.y < contentOffsetBuffer {
            let newAnchorOffset = scrollView.bounds.maxY + contentOffsetBuffer - scrollView.contentSize.height + deadZoneBuffer
            let indexPath = photosLayout.indexPathForFirstItem(at: newAnchorOffset)
            if indexPath.item < 0 {
                let contentOffsetChange = photosLayout.verticalOffsetForItem(at: indexPath)
                anchorIndex -= -indexPath.item
                scrollView.contentOffset.y += -contentOffsetChange
            }
        }

        if scrollView.bounds.maxY > scrollView.contentSize.height - contentOffsetBuffer {
            let newAnchorOffset = scrollView.contentOffset.y - contentOffsetBuffer - deadZoneBuffer
            let indexPath = photosLayout.indexPathForFirstItem(at: newAnchorOffset)
            let contentOffsetChange = photosLayout.verticalOffsetForItem(at: indexPath)
            anchorIndex += indexPath.item
            scrollView.contentOffset.y -= contentOffsetChange
        }
    }
}
