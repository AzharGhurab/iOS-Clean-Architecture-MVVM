//
//  ListDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import UIKit

final class ListDetailsViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!

    private var viewModel: ListDetailsViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTasks: [IndexPath: Cancellable?] = [:]

    static func create(
        with viewModel: ListDetailsViewModel,
        posterImagesRepository: PosterImagesRepository?,
        title: String
    ) -> ListDetailsViewController {
        let viewController = ListDetailsViewController(
            nibName: "ListDetailsViewController",
            bundle: nil
        )
        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository
        viewController.title = title
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
}

// MARK: - Private

private extension ListDetailsViewController {

    func setupCollectionView() {
        collectionView.register(
            UINib(nibName: "ListDetailsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ListDetailsCollectionViewCell"
        )

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func bind(to viewModel: ListDetailsViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ListDetailsViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.items.value.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ListDetailsCollectionViewCell",
            for: indexPath
        ) as! ListDetailsCollectionViewCell

        let item = viewModel.items.value[indexPath.item]

        cell.configure(
            title: item.title,
            image: nil
        )

        if let posterPath = item.posterPath {
            imageLoadTasks[indexPath] = posterImagesRepository?.fetchImage(
                with: posterPath,
                width: 200
            ) { result in
                DispatchQueue.main.async {
                    guard
                        let currentIndexPath = collectionView.indexPath(for: cell),
                        currentIndexPath == indexPath
                    else { return }

                    if case let .success(data) = result {
                        cell.updatePosterImage(UIImage(data: data))
                    }
                }
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ListDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let padding: CGFloat = 24
        let spacing: CGFloat = 16
        
                let width = (collectionView.bounds.width - padding * 2 - spacing * 2) / 3
        
                return CGSize(width: width, height: width * 1.5 + 28)
            }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
            8
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumLineSpacingForSectionAt section: Int
        ) -> CGFloat {
            0
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            insetForSectionAt section: Int
        ) -> UIEdgeInsets {
            UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        }
    }
