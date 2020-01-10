//
//  ViewController.swift
//  Photos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private enum ImageSize: CaseIterable {
        case small
        case medium
        case large

        var numberOfColumns: Int {
            switch self {
            case .small:
                return 4
            case .medium:
                return 2
            case .large:
                return 1
            }
        }

        var displayName: String {
            switch self {
            case .small:
                return "Small"
            case .medium:
                return "Medium"
            case .large:
                return "Large"
            }
        }

    }

    private let photosView = UICollectionView(frame: .zero, collectionViewLayout: PhotosLayout())
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

    private var imageSize: ImageSize = .small {
        didSet {
            updatePhotosLayout()
        }
    }

    private var markIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        photosView.dataSource = self
        photosView.delegate = self
        photosView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        photosView.frame = view.bounds
        photosView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(photosView)
        //!!!
        photosView.backgroundColor = .orange

        updatePhotosLayout()

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: imageSizeSelector),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]

        imageSizeSelector.selectedSegmentIndex = imageSize.index
    }

    private func updatePhotosLayout() {
        photosLayout.numberOfColumns = imageSize.numberOfColumns
    }

    @objc private func handleImageSizeChanged() {
        imageSize = ImageSize.allCases[imageSizeSelector.selectedSegmentIndex]
    }
}

// MARK: - ViewController: UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 300
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        //!!!
        cell.backgroundColor = .cyan
        let label = cell.contentView.subviews.first as? UILabel ?? {
            let label = UILabel()
            label.textAlignment = .center
            label.frame = cell.contentView.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.contentView.addSubview(label)
            return label
        }()

        let actualIndex = markIndex + indexPath.item
        label.text = "\(actualIndex)"

        return cell
    }
}

// MARK: - ViewController: UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //!!!
        if scrollView.contentSize == .zero {
            return
        }

        let contentOffsetBuffer = 2 * scrollView.frame.height

        if scrollView.contentOffset.y < contentOffsetBuffer {

        }

        if scrollView.contentOffset.y > scrollView.contentSize.height - contentOffsetBuffer {
            let markPoint = CGPoint(x: 0, y: scrollView.contentOffset.y - contentOffsetBuffer)
            // Alternative point for cases when original one gets into space between items
            let alternativeMarkPoint = CGPoint(x: markPoint.x, y: markPoint.y + photosLayout.minimumLineSpacing)

            let markIndexPath = photosView.indexPathForItem(at: markPoint) ?? photosView.indexPathForItem(at: alternativeMarkPoint)

            if let indexPath = markIndexPath, let attributes = photosView.layoutAttributesForItem(at: indexPath) {
                markIndex += indexPath.item
                scrollView.contentOffset.y -= attributes.frame.minY
                photosView.reloadData()
            } else {
                fatalError()
            }
        }
    }
}
