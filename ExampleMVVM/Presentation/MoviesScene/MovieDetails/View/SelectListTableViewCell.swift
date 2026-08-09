//
//  SelectListTableViewCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/01/1448 AH.
//

import UIKit

final class SelectListTableViewCell: UITableViewCell {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var moviesCountLabel: UILabel!
    @IBOutlet private weak var selectionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
    }

    func configure(
        title: String,
        moviesCount: Int,
        posterPath: String?,
        isSelected: Bool
    ) {
        titleLabel.text = title
        moviesCountLabel.text = "\(moviesCount) movies"

        posterImageView.image = UIImage(systemName: "film")
        posterImageView.tintColor = .systemGray3
        posterImageView.backgroundColor = .systemGray6

        selectionImageView.image = UIImage(
            systemName: isSelected ? "largecircle.fill.circle" : "circle"
        )
        selectionImageView.tintColor = isSelected ? .systemPink : .systemGray3
    }
    func updatePosterImage(_ image: UIImage?) {
        posterImageView.image = image
    }
}
