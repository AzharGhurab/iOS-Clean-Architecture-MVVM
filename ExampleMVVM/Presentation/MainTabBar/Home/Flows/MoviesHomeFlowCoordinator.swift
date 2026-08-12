//
//  MoviesHomeFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 17/12/1447 AH.
//
import UIKit

protocol MoviesHomeFlowCoordinatorDependencies {
    func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController
    func makeMoviesDetailsViewControllerHomeFlow(movie: Movie) -> UIViewController
    func makeSeeAllFlowCoordinator(navigationController: UINavigationController,section: HomeSectionType) -> SeeAllFlowCoordinator
}

final class MoviesHomeFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesHomeFlowCoordinatorDependencies
    private var seeAllFlowCoordinator: SeeAllFlowCoordinator?
    
    init(
        navigationController: UINavigationController,
        dependencies: MoviesHomeFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = HomeViewModelActions(
            showMovieDetails: showMovieDetails,
            showSeeAll: showSeeAll
        )
        
        let viewController = dependencies.makeHomeViewController(actions: actions)
        navigationController?.setViewControllers([viewController], animated: false)
    }
    
    private func showMovieDetails(movie: Movie) {
        let viewController = dependencies.makeMoviesDetailsViewControllerHomeFlow(movie: movie)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showSeeAll(section: HomeSectionType) {
        guard let navigationController else {
            return
        }

        let flow = dependencies.makeSeeAllFlowCoordinator(
            navigationController: navigationController,
            section: section
        )

        seeAllFlowCoordinator = flow
        flow.start()
    }
}
