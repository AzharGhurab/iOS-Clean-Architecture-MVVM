//
//  MovieSelectionViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import Foundation

protocol MovieSelectionViewModelInput {
    func viewDidLoad()
    func didTapEdit()
    func didTapCancel()
    func didSelectMovie(at index: Int)
    func didTapDelete()
}

protocol MovieSelectionViewModelOutput {
    var title: String { get }
    var items: Observable<[MovieSelectionMovie]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String?> { get }

    var isEditing: Observable<Bool> { get }
    var selectedMovieIds: Observable<Set<Int>> { get }
}

protocol MovieSelectionViewModel:
    MovieSelectionViewModelInput,
    MovieSelectionViewModelOutput { }

final class DefaultMovieSelectionViewModel: MovieSelectionViewModel {
    
    let title: String
    let items: Observable<[MovieSelectionMovie]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String?> = Observable(nil)
    
    let isEditing: Observable<Bool> = Observable(false)
    let selectedMovieIds: Observable<Set<Int>> = Observable([])
    
    private let type: MovieSelectionType
    private let fetchListDetailsUseCase: FetchListDetailsUseCase
    private let fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase
    private let fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase
    private let fetchAccountUseCase: FetchAccountUseCase
    private let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    private let markAsFavoriteUseCase: MarkAsFavoriteUseCase
    private let markAsWatchlistUseCase: MarkAsWatchlistUseCase
    private var accountId: Int?
    private var deleteTasks: [Cancellable] = []
    private let movieDetailsRepository: MovieDetailsRepository
    private let mainQueue: DispatchQueueType
    
    private var accountTask: Cancellable? {
        willSet { accountTask?.cancel() }
    }
    
    private var moviesLoadTask: Cancellable? {
        willSet { moviesLoadTask?.cancel() }
    }
    
    init(
        type: MovieSelectionType,
        fetchListDetailsUseCase: FetchListDetailsUseCase,
        fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase,
        fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase,
        fetchAccountUseCase: FetchAccountUseCase,
        removeMovieFromListUseCase: RemoveMovieFromListUseCase,
        markAsFavoriteUseCase: MarkAsFavoriteUseCase,
        markAsWatchlistUseCase: MarkAsWatchlistUseCase,
        movieDetailsRepository: MovieDetailsRepository,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.type = type
        self.title = type.title
        self.fetchListDetailsUseCase = fetchListDetailsUseCase
        self.fetchFavoriteMoviesUseCase = fetchFavoriteMoviesUseCase
        self.fetchWatchlistMoviesUseCase = fetchWatchlistMoviesUseCase
        self.fetchAccountUseCase = fetchAccountUseCase
        self.removeMovieFromListUseCase = removeMovieFromListUseCase
        self.markAsFavoriteUseCase = markAsFavoriteUseCase
        self.markAsWatchlistUseCase = markAsWatchlistUseCase
        self.movieDetailsRepository = movieDetailsRepository
        self.mainQueue = mainQueue
    }
    
    func viewDidLoad() {
        loading.value = true
        error.value = nil
        
        switch type {
        case .list(let listId):
            fetchListMovies(listId: listId)
            
        case .favorites, .watchlist:
            fetchAccount()
        }
    }
    
    func didTapEdit() {
        guard !items.value.isEmpty else {
            return
        }
        
        selectedMovieIds.value = []
        isEditing.value = true
    }
    
    func didTapCancel() {
        selectedMovieIds.value = []
        isEditing.value = false
    }
    
    func didSelectMovie(at index: Int) {
        guard isEditing.value else {
            return
        }
        
        guard items.value.indices.contains(index) else {
            return
        }
        
        let movieId = items.value[index].id
        var selectedIds = selectedMovieIds.value
        
        if selectedIds.contains(movieId) {
            selectedIds.remove(movieId)
        } else {
            selectedIds.insert(movieId)
        }
        
        selectedMovieIds.value = selectedIds
    }
    
    func didTapDelete() {
        let selectedIds = Array(selectedMovieIds.value)
        
        guard !selectedIds.isEmpty else {
            return
        }
        
        loading.value = true
        error.value = nil
        deleteTasks.removeAll()
        
        var remainingRequests = selectedIds.count
        var deletedMovieIds = Set<Int>()
        var firstError: Error?
        
        for movieId in selectedIds {
            let completion: (Result<Void, Error>) -> Void = { [weak self] result in
                guard let self else { return }
                
                self.mainQueue.async {
                    switch result {
                    case .success:
                        deletedMovieIds.insert(movieId)
                        
                        switch self.type {
                        case .favorites:
                            self.movieDetailsRepository.setFavorite(
                                movieId: String(movieId),
                                isFavorite: false
                            )
                            
                        case .watchlist:
                            self.movieDetailsRepository.setWatchlist(
                                movieId: String(movieId),
                                isInWatchlist: false
                            )
                            
                        case .list:
                            break
                        }
                        
                    case .failure(let error):
                        if firstError == nil {
                            firstError = error
                        }
                    }
                    
                    remainingRequests -= 1
                    
                    guard remainingRequests == 0 else {
                        return
                    }
                    
                    self.loading.value = false
                    
                    self.items.value.removeAll {
                        deletedMovieIds.contains($0.id)
                    }
                    
                    self.selectedMovieIds.value = []
                    self.isEditing.value = false
                    self.deleteTasks.removeAll()
                    
                    if let firstError {
                        self.error.value = firstError.localizedDescription
                    }
                }
            }
            
            if let task = deleteMovie(
                movieId: movieId,
                completion: completion
            ) {
                deleteTasks.append(task)
            } else {
                completion(
                    .failure(MovieSelectionError.deleteTaskNotCreated)
                )
            }
        }
    }
}
// MARK: - Private

private extension DefaultMovieSelectionViewModel {

    func fetchListMovies(listId: Int) {
        moviesLoadTask = fetchListDetailsUseCase.execute(
            listId: listId
        ) { [weak self] result in
            guard let self else { return }

            self.mainQueue.async {
                self.loading.value = false

                switch result {
                case .success(let movies):
                    self.items.value = movies

                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }
        }
    }

    func fetchAccount() {
        accountTask = fetchAccountUseCase.execute { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let account):
                self.accountId = account.id

                self.fetchProfileMovies(
                    accountId: account.id,
                    page: 1
                )
            case .failure(let error):
                self.mainQueue.async {
                    self.loading.value = false
                    self.error.value = error.localizedDescription
                }
            }
        }
    }

    func fetchProfileMovies(
        accountId: Int,
        page: Int
    ) {

        switch type {
        case .favorites:
            moviesLoadTask = fetchFavoriteMoviesUseCase.execute(
                requestValue:  FetchFavoriteMoviesUseCaseRequestValue(
                    accountId: accountId,
                    page: page
                ),
                completion: handleProfileMoviesResult
            )

        case .watchlist:
            moviesLoadTask = fetchWatchlistMoviesUseCase.execute(
                requestValue: FetchWatchlistMoviesUseCaseRequestValue(
                    accountId: accountId,
                    page: page
                ),
                completion: handleProfileMoviesResult
            )

        case .list:
            break
        }
    }

    func handleProfileMoviesResult(
        _ result: Result<MoviesPage, Error>
    ) {
        mainQueue.async { [weak self] in
            guard let self else { return }

            self.loading.value = false

            switch result {
            case .success(let moviesPage):
                self.items.value = moviesPage.movies.compactMap { movie in
                    guard let id = Int(movie.id) else {
                        return nil
                    }

                    return MovieSelectionMovie(
                        id: id,
                        title: movie.title ?? "Untitled",
                        posterPath: movie.posterPath
                    )
                }

            case .failure(let error):
                self.error.value = error.localizedDescription
            }
        }
    }
    func deleteMovie(
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        switch type {
        case .list(let listId):
            return removeMovieFromListUseCase.execute(
                requestValue: RemoveMovieFromListUseCaseRequestValue(
                    listId: listId,
                    movieId: String(movieId)
                ),
                completion: completion
            )

        case .favorites:
            guard let accountId else {
                completion(.failure(MovieSelectionError.missingAccountId))
                return nil
            }

            return markAsFavoriteUseCase.execute(
                requestValue: MarkAsFavoriteUseCaseRequestValue(
                    accountId: accountId,
                    movieId: movieId,
                    isFavorite: false
                ),
                completion: completion
            )

        case .watchlist:
            guard let accountId else {
                completion(.failure(MovieSelectionError.missingAccountId))
                return nil
            }

            return markAsWatchlistUseCase.execute(
                requestValue: MarkAsWatchlistUseCaseRequestValue(
                    accountId: accountId,
                    movieId: movieId,
                    isInWatchlist: false
                ),
                completion: completion
            )
        }
    }
}
private enum MovieSelectionError: LocalizedError {
    case missingAccountId
    case deleteTaskNotCreated

    var errorDescription: String? {
        switch self {
        case .missingAccountId:
            return "Missing account id"

        case .deleteTaskNotCreated:
            return "Failed to start delete request"
        }
    }
}
