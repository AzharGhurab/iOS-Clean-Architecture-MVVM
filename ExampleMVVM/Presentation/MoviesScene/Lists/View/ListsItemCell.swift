//
//  ListsItemCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 15/01/1448 AH.
//

import UIKit
final class ListsItemCell: UITableViewCell {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var moreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        moreLabel.text = "⋯"
            moreLabel.textColor = .systemGray3

            posterImageView.contentMode = .scaleAspectFill
            posterImageView.clipsToBounds = true
            posterImageView.layer.cornerRadius = 8
    }

    func configure(
        title: String,
        count: String,
        image: UIImage?
    ) {
        titleLabel.text = title
        countLabel.text = count
        posterImageView.image = image ?? UIImage(systemName: "photo")
        posterImageView.tintColor = .gray
    }

    func updatePosterImage(_ image: UIImage?) {
        posterImageView.image = image
    }
}
