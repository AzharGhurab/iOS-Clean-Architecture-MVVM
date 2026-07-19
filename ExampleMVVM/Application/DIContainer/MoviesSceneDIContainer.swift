import UIKit

final class MoviesSceneDIContainer:
    MoviesSearchFlowCoordinatorDependencies,
    MoviesHomeFlowCoordinatorDependencies,
    AuthFlowCoordinatorDependencies,
    ListsFlowCoordinatorDependencies {

    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()
    lazy var movieDetailsRepository: MovieDetailsRepository = UserDefaultsMovieDetailsRepository()
    lazy var authenticationStorage: AuthenticationStorage = KeychainAuthenticationStorage()
    lazy var authenticationRepository: AuthenticationRepository =
        DefaultAuthenticationRepository(
            dataTransferService: dependencies.apiDataTransferService,
            storage: authenticationStorage
        )
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }

    // MARK: - Authentication Use Cases

    func makeCreateGuestSessionUseCase() -> CreateGuestSessionUseCase {
        DefaultCreateGuestSessionUseCase(
            authenticationRepository: authenticationRepository
        )
    }

    func makeCreateRequestTokenUseCase() -> CreateRequestTokenUseCase {
        DefaultCreateRequestTokenUseCase(
            authenticationRepository: authenticationRepository
        )
    }
    func makeCreateSessionUseCase() -> CreateSessionUseCase {
        DefaultCreateSessionUseCase(
            authenticationRepository: authenticationRepository
        )
    }

    // MARK: - Movies Use Cases

    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(
            moviesRepository: makeMoviesRepository(),
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    func makeFetchGenresUseCase() -> FetchGenresUseCase {
        DefaultFetchGenresUseCase(
            genresRepository: makeGenresRepository())
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

    // MARK: - Lists Use Cases

    func makeFetchListsUseCase() -> FetchListsUseCase {
        DefaultFetchListsUseCase(listsRepository: makeListsRepository())
    }

    func makeCreateListUseCase() -> CreateListUseCase {
        DefaultCreateListUseCase(listsRepository: makeListsRepository())
    }
    func makeFetchListDetailsUseCase() -> FetchListDetailsUseCase {
        DefaultFetchListDetailsUseCase(
            listsRepository: makeListsRepository()
        )
    }
    func makeDeleteListUseCase() -> DeleteListUseCase {
        DefaultDeleteListUseCase(
            listsRepository: makeListsRepository()
        )
    }
    func makeAddMovieToListUseCase() -> AddMovieToListUseCase {
        DefaultAddMovieToListUseCase(
            listsRepository: makeListsRepository()
        )
    }
    func makeRemoveMovieFromListUseCase() -> RemoveMovieFromListUseCase {
        DefaultRemoveMovieFromListUseCase(
            listsRepository: makeListsRepository()
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
        DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService)
    }

    func makeListsRepository() -> ListsRepository {
        DefaultListsRepository(
            dataTransferService: dependencies.apiDataTransferService,
            authenticationStorage: authenticationStorage
        )
    }

    // MARK: - Authentication

    func makeLoginViewModel(
        actions: LoginViewModelActions
    ) -> LoginViewModel {
        DefaultLoginViewModel(
            createGuestSessionUseCase: makeCreateGuestSessionUseCase(),
            createRequestTokenUseCase: makeCreateRequestTokenUseCase(),
            createSessionUseCase: makeCreateSessionUseCase(),
            fetchAccountUseCase: makeFetchAccountUseCase(),
            authenticationStorage: authenticationStorage,
            actions: actions
        )
    }
    func makeFetchAccountUseCase() -> FetchAccountUseCase {
        DefaultFetchAccountUseCase(
            authenticationRepository: authenticationRepository
        )
    }

    // MARK: - Profile

    func makeProfileViewModel(actions: ProfileViewModelActions) -> ProfileViewModel {
        DefaultProfileViewModel(actions: actions)
    }

    func makeProfileViewController(actions: ProfileViewModelActions) -> ProfileViewController {
        ProfileViewController.create(
            with: makeProfileViewModel(actions: actions)
        )
    }

    // MARK: - Lists

    func makeListsViewModel(
        accountId: Int,
        actions: ListsViewModelActions
    ) -> ListsViewModel {
        
        DefaultListsViewModel(
            fetchListsUseCase: makeFetchListsUseCase(),
            fetchListDetailsUseCase: makeFetchListDetailsUseCase(),
            deleteListUseCase: makeDeleteListUseCase(),
            actions: actions,
            accountId: accountId
        )
    }

    func makeListsViewController(
        accountId: Int,
        actions: ListsViewModelActions,
        onCreateList: @escaping () -> Void
    ) -> ListsViewController {

        ListsViewController.create(
            with: makeListsViewModel(
                accountId: accountId,
                actions: actions
            ),
            onCreateList: onCreateList,
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    
    // MARK: - List Details

    func makeListDetailsViewModel(
        listId: Int
    ) -> ListDetailsViewModel {
        DefaultListDetailsViewModel(
            listId: listId,
            fetchListDetailsUseCase: makeFetchListDetailsUseCase()
        )
    }

    func makeListDetailsViewController(
        listId: Int,
        title: String
    ) -> ListDetailsViewController {

        ListDetailsViewController.create(
            with: makeListDetailsViewModel(listId: listId),
            posterImagesRepository: makePosterImagesRepository(),
            title: title
        )
    }

    // MARK: - Create List

    func makeCreateListViewModel(
        actions: CreateListViewModelActions
    ) -> CreateListViewModel {
        DefaultCreateListViewModel(
            createListUseCase: makeCreateListUseCase(),
            actions: actions
        )
    }

    func makeCreateListViewController(
        actions: CreateListViewModelActions
    ) -> CreateListViewController {
        CreateListViewController.create(
            with: makeCreateListViewModel(actions: actions)
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
            with: makeMoviesDetailsViewModel(movie: movie),
            makeSelectListViewController: {
                self.makeSelectListViewController(movie: movie)
            }
        )
    }
    
    func makeMoviesDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        DefaultMovieDetailsViewModel(
            movie: movie,
            posterImagesRepository: makePosterImagesRepository(),
            movieDetailsRepository: movieDetailsRepository,
            addMovieToListUseCase: makeAddMovieToListUseCase(),
            removeMovieFromListUseCase: makeRemoveMovieFromListUseCase(),
            fetchAccountUseCase: makeFetchAccountUseCase(),
            fetchListsUseCase: makeFetchListsUseCase(),
            fetchListDetailsUseCase: makeFetchListDetailsUseCase()
        )
    }
    func makeSelectListViewModel(
        movie: Movie
    ) -> SelectListViewModel {

        DefaultSelectListViewModel(
            movieId: movie.id,
            fetchAccountUseCase: makeFetchAccountUseCase(),
            fetchListsUseCase: makeFetchListsUseCase(),
            fetchListDetailsUseCase: makeFetchListDetailsUseCase()
        )
    }

    func makeSelectListViewController(
        movie: Movie
    ) -> SelectListViewController {

        SelectListViewController.create(
            with: makeSelectListViewModel(movie: movie),
            posterImagesRepository: makePosterImagesRepository()
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

    func makeMoviesHomeFlowCoordinator(navigationController: UINavigationController) -> MoviesHomeFlowCoordinator {
        MoviesHomeFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }

    func makeAuthFlowCoordinator(navigationController: UINavigationController) -> AuthFlowCoordinator {
        AuthFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }

    func makeListsFlowCoordinator(
        navigationController: UINavigationController,
        accountId: Int
    ) -> ListsFlowCoordinator {
        ListsFlowCoordinator(
            navigationController: navigationController,
            dependencies: self,
            accountId: accountId
        )
    }
}
