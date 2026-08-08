//
//  HomeMovieCollectionViewCell.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/11/1447 AH.
//


import UIKit
import SkeletonView

final class HomeMovieCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier =
        String(describing: HomeMovieCollectionViewCell.self)

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!

    private var imageLoadTask: Cancellable? {
        willSet {
            imageLoadTask?.cancel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isSkeletonable = true
        contentView.isSkeletonable = true

        posterImageView.isSkeletonable = true
        titleLabel.isSkeletonable = true
        ratingLabel.isSkeletonable = true

        posterImageView.clipsToBounds = true
        titleLabel.clipsToBounds = true
        ratingLabel.clipsToBounds = true

        posterImageView.layer.cornerRadius = 8
        titleLabel.linesCornerRadius = 4
        ratingLabel.linesCornerRadius = 4
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadTask?.cancel()

        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
    }

    func configure(
        with viewModel: HomeMovieCellViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) {
        posterImageView.image = nil
        titleLabel.text = viewModel.title
        ratingLabel.text = viewModel.rating

        guard let posterPath = viewModel.posterPath else {
            return
        }

        imageLoadTask =
            posterImagesRepository?.fetchImage(
                with: posterPath,
                width: Int(posterImageView.bounds.width)
            ) { [weak self] result in
                guard case .success(let data) = result else {
                    return
                }

                DispatchQueue.main.async {
                    self?.posterImageView.image =
                        UIImage(data: data)
                }
            }
    }
}
