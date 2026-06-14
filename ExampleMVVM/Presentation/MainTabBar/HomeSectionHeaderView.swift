//
//  HomeSectionHeaderView.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/11/1447 AH.
//

import UIKit

final class HomeSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: HomeSectionHeaderView.self)
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
