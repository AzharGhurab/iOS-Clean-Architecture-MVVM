import UIKit


final class MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies ,MoviesHomeFlowCoordinatorDependencies {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()
    lazy var movieDetailsRepository: MovieDetailsRepository = UserDefaultsMovieDetailsRepository()
    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(
            moviesRepository: makeMoviesRepository(),
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    func makeFetchGenresUseCase() -> FetchGenresUseCase {
        DefaultFetchGenresUseCase(
            genresRepository: makeGenresRepository()
        }
    func makeMoviesHomeFlowCoordinator(navigationController: UINavigationController) -> MoviesHomeFlowCoordinator {
        MoviesHomeFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
    func makeFetchHomeMoviesUseCase() -> FetchHomeMoviesUseCase {
        DefaultFetchHomeMoviesUseCase(
            moviesRepository: makeMoviesRepository()
        )
    }
    
    func makeFetchRecentMovieQueriesUseCase(
        requestValue: FetchRecentMovieQueriesUseCase.RequestValue,
        completion: @escaping (FetchRecentMovieQueriesUseCase.ResultValue) -> Void
    ) -> UseCase {
        FetchRecentMovieQueriesUseCase(
            requestValue: requestValue,
            completion: completion,
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        DefaultMoviesRepository(
            dataTransferService: dependencies.apiDataTransferService,
            cache: moviesResponseCache
        )
    }
    func makeGenresRepository() -> GenresRepository {
        DefaultGenresRepository(
            dataTransferService: dependencies.apiDataTransferService
        )
    }
    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        DefaultMoviesQueriesRepository(
            moviesQueriesPersistentStorage: moviesQueriesStorage
        )
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        DefaultPosterImagesRepository(
            dataTransferService: dependencies.imageDataTransferService
        )
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController(actions: MoviesListViewModelActions) -> MoviesListViewController {
        MoviesListViewController.create(
            with: makeMoviesListViewModel(actions: actions),
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    
    func makeMoviesListViewModel(actions: MoviesListViewModelActions) -> MoviesListViewModel {
        DefaultMoviesListViewModel(
            searchMoviesUseCase: makeSearchMoviesUseCase(),
            fetchGenresUseCase: makeFetchGenresUseCase(),
            actions: actions
        )
    }
    // MARK: - Home

    func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController {
        HomeViewController.create(
            with: makeHomeViewModel(actions: actions),
            posterImagesRepository: makePosterImagesRepository()
        )
    }

    func makeHomeViewModel(actions: HomeViewModelActions) -> HomeViewModel {
        DefaultHomeViewModel(
            fetchHomeMoviesUseCase: makeFetchHomeMoviesUseCase(),
            actions: actions
        )
    }
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController {
        MovieDetailsViewController.create(
            with: makeMoviesDetailsViewModel(movie: movie)
        )
    }
    
    func makeMoviesDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        DefaultMovieDetailsViewModel(
            movie: movie,
            posterImagesRepository: makePosterImagesRepository(),
            movieDetailsRepository: movieDetailsRepository
        )
    }
    // MARK: - Movies Queries Suggestions List

    func makeMoviesQueriesSuggestionsListViewController(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> UIViewController {
        return MoviesQueriesTableViewController.create(
            with: makeMoviesQueryListViewModel(didSelect: didSelect)
        )
    }

    func makeMoviesQueryListViewModel(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> MoviesQueryListViewModel {
        DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 10,
            fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase,
            didSelect: didSelect
        )
    }
    // MARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}
