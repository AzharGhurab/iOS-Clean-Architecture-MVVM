//
//  HomeViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/11/1447 AH.
//

import UIKit
import SkeletonView

final class HomeViewController: UIViewController, StoryboardInstantiable {
    
    private var viewModel: HomeViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private let refreshControl = UIRefreshControl()
    private var isLoading = false
    @IBOutlet private weak var collectionView: UICollectionView!
    
    static func create(
        with viewModel: HomeViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> HomeViewController {
        let viewController = HomeViewController.instantiateViewController()
        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
}

// MARK: - Private
private extension HomeViewController {
    
    func setupView() {
        title = viewModel.screenTitle

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSkeletonable = true

        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )

        collectionView.refreshControl = refreshControl
    }
    
    @objc private func didPullToRefresh() {
        viewModel.didPullToRefresh()
    }
    
    func bind(to viewModel: HomeViewModel) {
        viewModel.sections.observe(on: self) { [weak self] _ in
            guard let self else { return }
            
            guard !self.isLoading else { return }

            self.collectionView.reloadData()
        }

        viewModel.loading.observe(on: self) { [weak self] isLoading in
            guard let self else { return }

            self.isLoading = isLoading

            if isLoading {
                if !self.refreshControl.isRefreshing {
                    self.collectionView.showAnimatedGradientSkeleton()
                }
            } else {
                self.refreshControl.endRefreshing()

                self.collectionView.hideSkeleton(
                    reloadDataAfter: false,
                    transition: .crossDissolve(0.25)
                )

                self.collectionView.reloadData()
            }
        }

        viewModel.error.observe(on: self) { [weak self] error in
            guard !error.isEmpty else { return }
            self?.showError(message: error)
        }
    }
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alert, animated: true)
    }
}
// MARK: - UICollectionViewDataSource

extension HomeViewController: SkeletonCollectionViewDataSource  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.value.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard viewModel.sections.value.indices.contains(section) else {
            return 0
        }

        return min(
            viewModel.sections.value[section].movies.count,
            3
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeMovieCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? HomeMovieCollectionViewCell else {
            return UICollectionViewCell()
        }

        let sections = viewModel.sections.value

        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].movies.indices.contains(indexPath.item) else {
            return cell
        }

        let movie = sections[indexPath.section].movies[indexPath.item]

        cell.configure(
            with: movie,
            posterImagesRepository: posterImagesRepository
        )
        
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? HomeSectionHeaderView else {
            return UICollectionReusableView()
        }

        if isLoading {
            header.showLoadingState()
            return header
        }

        let sections = viewModel.sections.value

        guard sections.indices.contains(indexPath.section) else {
            return header
        }

        header.configure(
            title: sections[indexPath.section].title,
            onSeeAllTapped: { [weak self] in
                self?.viewModel.didTapSeeAll(
                    sectionIndex: indexPath.section
                )
            }
        )

        return header
    }
    func numSections(
        in collectionSkeletonView: UICollectionView
    ) -> Int {
        return 4
    }

    func collectionSkeletonView(
        _ skeletonView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 3
    }

    func collectionSkeletonView(
        _ skeletonView: UICollectionView,
        cellIdentifierForItemAt indexPath: IndexPath
    ) -> ReusableCellIdentifier {
        return HomeMovieCollectionViewCell.reuseIdentifier
    }

    func collectionSkeletonView(
        _ skeletonView: UICollectionView,
        supplementaryViewIdentifierOfKind kind: String,
        at indexPath: IndexPath
    ) -> ReusableCellIdentifier? {
        return nil
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard !isLoading else { return }

        viewModel.didSelectMovie(
            sectionIndex: indexPath.section,
            movieIndex: indexPath.item
        )
    }
}
