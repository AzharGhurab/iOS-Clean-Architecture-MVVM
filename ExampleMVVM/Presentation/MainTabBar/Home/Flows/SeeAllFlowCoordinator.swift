//
//  SeeAllFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/02/1448 AH.
//

import UIKit

protocol SeeAllFlowCoordinatorDependencies {

    func makeSeeAllViewController(
        actions: SeeAllViewModelActions,
        section: HomeSectionType
    ) -> SeeAllViewController

    func makeMoviesDetailsViewControllerSeeAll(
        movie: Movie
    ) -> UIViewController
}

final class SeeAllFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: SeeAllFlowCoordinatorDependencies
    private let section: HomeSectionType

    init(
        navigationController: UINavigationController,
        dependencies: SeeAllFlowCoordinatorDependencies,
        section: HomeSectionType
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.section = section
    }

    func start() {
        let actions = SeeAllViewModelActions(
            showMovieDetails: showMovieDetails
        )

        let viewController = dependencies.makeSeeAllViewController(
            actions: actions,
            section: section
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func showMovieDetails(movie: Movie) {
        let viewController = dependencies.makeMoviesDetailsViewControllerSeeAll(
            movie: movie
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}
