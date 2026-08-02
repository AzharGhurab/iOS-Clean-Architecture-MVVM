//
//  MovieSelectionCollectionViewCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import UIKit

final class MovieSelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private let selectionOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(
            systemName: "checkmark.circle.fill"
        )
        imageView.tintColor = .systemBlue
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPosterImageView()
        setupTitleLabel()
        setupSelectionViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        
        posterImageView.image = UIImage(
            systemName: "photo"
        )
        posterImageView.tintColor = .systemGray
        
        updateSelection(
            isEditing: false,
            isSelected: false
        )
    }
    
    func configure(
        title: String?,
        image: UIImage? = nil,
        isEditing: Bool,
        isSelected: Bool
    ) {
        titleLabel.text = title ?? "Untitled"
        
        posterImageView.image =
        image ?? UIImage(systemName: "photo")
        
        posterImageView.tintColor = .systemGray
        
        updateSelection(
            isEditing: isEditing,
            isSelected: isSelected
        )
    }
    
    func updatePosterImage(_ image: UIImage?) {
        posterImageView.image =
        image ?? UIImage(systemName: "photo")
    }
    
    func updateSelection(
        isEditing: Bool,
        isSelected: Bool
    ) {
        selectionOverlayView.isHidden = !isEditing || !isSelected
        selectionImageView.isHidden = !isEditing
        
        selectionImageView.image = UIImage(
            systemName: isSelected
            ? "checkmark.circle.fill"
            : "circle"
        )
        
        selectionImageView.tintColor = .systemBlue
        selectionImageView.backgroundColor = .clear
        
        posterImageView.layer.borderWidth =
        isSelected ? 3 : 0
        
        posterImageView.layer.borderColor =
        isSelected
        ? UIColor.systemBlue.cgColor
        : UIColor.clear.cgColor
    }
}

// MARK: - Setup

private extension MovieSelectionCollectionViewCell {

    func setupPosterImageView() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
    }

    func setupTitleLabel() {
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 10)
    }

    func setupSelectionViews() {
        posterImageView.addSubview(selectionOverlayView)
        posterImageView.addSubview(selectionImageView)

        NSLayoutConstraint.activate([
            selectionOverlayView.topAnchor.constraint(
                equalTo: posterImageView.topAnchor
            ),
            selectionOverlayView.leadingAnchor.constraint(
                equalTo: posterImageView.leadingAnchor
            ),
            selectionOverlayView.trailingAnchor.constraint(
                equalTo: posterImageView.trailingAnchor
            ),
            selectionOverlayView.bottomAnchor.constraint(
                equalTo: posterImageView.bottomAnchor
            ),

            selectionImageView.topAnchor.constraint(
                equalTo: posterImageView.topAnchor,
                constant: 8
            ),
            selectionImageView.trailingAnchor.constraint(
                equalTo: posterImageView.trailingAnchor,
                constant: -8
            ),
            selectionImageView.widthAnchor.constraint(
                equalToConstant: 24
            ),
            selectionImageView.heightAnchor.constraint(
                equalToConstant: 24
            )
        ])
    }
}
