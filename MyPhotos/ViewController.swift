//
//  ViewController.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/8/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

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

    private let photos = Photos()

    private lazy var photosView = PhotoCollectionView(photos: photos)
    private lazy var imageSizeSelector: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ImageSize.allCases.map { $0.displayName })
        segmentedControl.addTarget(self, action: #selector(handleImageSizeChanged), for: .valueChanged)
        return segmentedControl
    }()

    private var imageSize: ImageSize = .small {
        didSet {
            updatePhotosView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        photosView.frame = view.bounds
        photosView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(photosView)

        updatePhotosView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Debug", style: .plain, target: self, action: #selector(handleDebugButtonTap))
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: imageSizeSelector),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]

        imageSizeSelector.selectedSegmentIndex = imageSize.index
    }

    private func updatePhotosView() {
        photosView.numberOfColumns = imageSize.numberOfColumns
    }

    @objc private func handleImageSizeChanged() {
        imageSize = ImageSize.allCases[imageSizeSelector.selectedSegmentIndex]
    }

    @objc private func handleDebugButtonTap() {
        photosView.isInDebugMode = !photosView.isInDebugMode
    }
}
