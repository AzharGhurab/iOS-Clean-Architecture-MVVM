//
//  MoviesHomeFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 17/12/1447 AH.
//
import UIKit

protocol MoviesHomeFlowCoordinatorDependencies {
    func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
}

final class MoviesHomeFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesHomeFlowCoordinatorDependencies
    
    init(
        navigationController: UINavigationController,
        dependencies: MoviesHomeFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = HomeViewModelActions(
            showMovieDetails: showMovieDetails
        )
        
        let viewController = dependencies.makeHomeViewController(actions: actions)
        navigationController?.setViewControllers([viewController], animated: false)
    }
    
    private func showMovieDetails(movie: Movie) {
        let viewController = dependencies.makeMoviesDetailsViewController(movie: movie)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
