//
//  ListDetailsCollectionViewCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import UIKit

final class ListDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8

        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 10)
    }

    func configure(
        title: String,
        image: UIImage?
    ) {
        titleLabel.text = title
        posterImageView.image = image ?? UIImage(systemName: "photo")
        posterImageView.tintColor = .systemGray
    }

    func updatePosterImage(_ image: UIImage?) {
        posterImageView.image = image
    }
}

