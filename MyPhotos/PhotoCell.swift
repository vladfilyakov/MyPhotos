//
//  PhotoCell.swift
//  MyPhotos
//
//  Created by Vladislav Filyakov on 1/15/20.
//  Copyright © 2020 Vlad Filyakov. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    private struct Constants {
        static let labelCornerRadius: CGFloat = 2
        static let labelFontSize: CGFloat = 12
        static let labelNumberOfLines: Int = 3
        static let labelMargin: CGFloat = 2
    }

    static let reuseIdentifier = String(describing: self)

    let label: UILabel = {
        let label = UILabel()

        label.backgroundColor = .orange
        label.layer.cornerRadius = Constants.labelCornerRadius
        label.clipsToBounds = true

        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize)
        label.numberOfLines = Constants.labelNumberOfLines
        label.frame.size.height = round(CGFloat(label.numberOfLines) * (label.font.lineHeight + label.font.leading))

        label.isHidden = true

        return label
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)

        var frame = contentView.bounds.insetBy(dx: Constants.labelMargin, dy: Constants.labelMargin)
        frame.origin.y = frame.maxY - label.frame.height
        frame.size.height = label.frame.height
        label.frame = frame
        label.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.isHidden = true
        label.text = nil
        imageView.image = nil
    }
}
