//
//  CategoryFilterView.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 22/02/1448 AH.
//

import UIKit

enum SearchCategory {
    case movies
    case tvShows
}

final class CategoryFilterView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var moviesButton: UIButton!
    @IBOutlet private weak var tvShowsButton: UIButton!
    @IBOutlet private weak var selectedIndicator: UIView!
    @IBOutlet private weak var indicatorLeadingConstraint: NSLayoutConstraint!
    
    var onCategoryChanged: ((SearchCategory) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(
            String(describing: CategoryFilterView.self),
            owner: self,
            options: nil
        )
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        showSelectedCategory(.movies, animated: false)
    }
    @IBAction private func moviesTapped(_ sender: UIButton) {
        showSelectedCategory(.movies, animated: true)
        onCategoryChanged?(.movies)
    }
    
    @IBAction private func tvShowsTapped(_ sender: UIButton) {
        showSelectedCategory(.tvShows, animated: true)
        onCategoryChanged?(.tvShows)
    }
    
    private func showSelectedCategory(
        _ category: SearchCategory,
        animated: Bool
    ) {
        contentView.layoutIfNeeded()

        switch category {
        case .movies:
            moviesButton.configuration?.baseForegroundColor = .systemBlue
            tvShowsButton.configuration?.baseForegroundColor = .systemGray

            indicatorLeadingConstraint.constant = 0

        case .tvShows:
            moviesButton.configuration?.baseForegroundColor = .systemGray
            tvShowsButton.configuration?.baseForegroundColor = .systemBlue

            indicatorLeadingConstraint.constant =
                tvShowsButton.center.x - moviesButton.center.x
        }

        UIView.animate(
            withDuration: animated ? 0.25 : 0
        ) {
            self.contentView.layoutIfNeeded()
        }
    }
}
