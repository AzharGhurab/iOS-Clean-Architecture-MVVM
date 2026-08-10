import UIKit

protocol MoviesSearchFlowCoordinatorDependencies  {
    func makeMoviesListViewController(
        actions: MoviesListViewModelActions
    ) -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie, actions: MovieDetailsViewModelActions) -> UIViewController
    func makeMoviesQueriesSuggestionsListViewController(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> UIViewController
}

final class MoviesSearchFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesSearchFlowCoordinatorDependencies

    private weak var moviesListVC: MoviesListViewController?
    private weak var moviesQueriesSuggestionsVC: UIViewController?

    private let onShowLogin: () -> Void
    
    init(
        navigationController: UINavigationController,
        dependencies: MoviesSearchFlowCoordinatorDependencies,
        onShowLogin: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.onShowLogin = onShowLogin
    }
    
    func start() {
        // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
        let actions = MoviesListViewModelActions(showMovieDetails: showMovieDetails,
                                                 showMovieQueriesSuggestions: showMovieQueriesSuggestions,
                                                 closeMovieQueriesSuggestions: closeMovieQueriesSuggestions)
        let vc = dependencies.makeMoviesListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        moviesListVC = vc
    }

    private func showMovieDetails(movie: Movie) {
        let actions = MovieDetailsViewModelActions(
            showLogin: { [weak self] in
                self?.onShowLogin()
            }
        )
        let vc = dependencies.makeMoviesDetailsViewController(movie: movie,actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showMovieQueriesSuggestions(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) {
            guard let moviesListViewController = moviesListVC, moviesQueriesSuggestionsVC == nil,
            let container = moviesListViewController.suggestionsListContainer else { return }

        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)

        moviesListViewController.add(child: vc, container: container)
        moviesQueriesSuggestionsVC = vc
        container.isHidden = false
    }

    private func closeMovieQueriesSuggestions() {
        moviesQueriesSuggestionsVC?.remove()
        moviesQueriesSuggestionsVC = nil
        moviesListVC?.suggestionsListContainer.isHidden = true
    }
}
