//
//  GenreCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 19/11/1447 AH.
//

import UIKit

class GenreCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: GenreCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    func configure(with title: String) {
        titleLabel.text = title
        contentView.backgroundColor = .clear

            contentView.layer.cornerRadius = 10
            contentView.clipsToBounds = true
            
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)

        }
    }

