//
//   ProfileItemCell.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 15/01/1448 AH.
//

import UIKit

final class ProfileItemCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray3
    }

    func configure(title: String, icon: UIImage?, isLogout: Bool = false) {
        titleLabel.text = title
        iconImageView.image = icon

        if isLogout {
            titleLabel.textColor = .systemRed
            iconImageView.tintColor = .systemRed
        } else {
            titleLabel.textColor = .label
            iconImageView.tintColor = .label
        }
    }
}
