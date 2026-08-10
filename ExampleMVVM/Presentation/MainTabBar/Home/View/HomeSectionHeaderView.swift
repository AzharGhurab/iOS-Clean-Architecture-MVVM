//
//  HomeSectionHeaderView.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/11/1447 AH.
//

import UIKit
import SkeletonView

final class HomeSectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier =
        String(describing: HomeSectionHeaderView.self)

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!

    private var onSeeAllTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        isSkeletonable = false
        titleLabel.isSkeletonable = false
        seeAllButton.isSkeletonable = false
    }
    
    func configure(
        title: String,
        onSeeAllTapped: @escaping () -> Void
    ) {
        titleLabel.isHidden = false
        seeAllButton.isHidden = false

        titleLabel.text = title
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.isEnabled = true

        self.onSeeAllTapped = onSeeAllTapped
    }

    func showLoadingState() {
        onSeeAllTapped = nil
        titleLabel.isHidden = true
        seeAllButton.isHidden = true
        seeAllButton.isEnabled = false
    }

    func hideLoadingState() {
        titleLabel.isHidden = false
        seeAllButton.isHidden = false
        seeAllButton.isEnabled = false
    }

    @IBAction private func seeAllTapped(_ sender: UIButton) {
        onSeeAllTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        onSeeAllTapped = nil
        titleLabel.text = nil
        seeAllButton.setTitle(nil, for: .normal)
    }
}
