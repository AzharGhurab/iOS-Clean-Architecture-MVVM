import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
    func toggleFavorite()
    func toggleWatchlist()
    func addToList(listId: Int)
    func updateAddedList(listId: Int?)
    func viewDidLoad()
    func viewWillAppear()
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var rating: String { get }
    var isFavorite: Observable<Bool> { get }
    var isInWatchlist: Observable<Bool> { get }
    var isAddedToList: Observable<Bool> { get }
    var overview: String { get }
    var error: Observable<String?> { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType
    
    private let movieId: String
    private let movieDetailsRepository : MovieDetailsRepository
    private(set) var isFavorite: Observable<Bool>
    private(set) var isInWatchlist: Observable<Bool>
    let isAddedToList: Observable<Bool> = Observable(false)
    private let addMovieToListUseCase: AddMovieToListUseCase
    private let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    private let fetchAccountUseCase: FetchAccountUseCase
    private let fetchListsUseCase: FetchListsUseCase
    private let fetchListDetailsUseCase: FetchListDetailsUseCase

    private let markAsFavoriteUseCase: MarkAsFavoriteUseCase
    private let markAsWatchlistUseCase: MarkAsWatchlistUseCase
    private let fetchMovieAccountStatesUseCase: FetchMovieAccountStatesUseCase
    
    private var addToListTask: Cancellable? {
        willSet {
            addToListTask?.cancel()
        }
    }

    private var fetchListsTask: Cancellable? {
        willSet {
            fetchListsTask?.cancel()
        }
    }

    private var fetchMovieAccountStatesTask: Cancellable? {
        willSet {
            fetchMovieAccountStatesTask?.cancel()
        }
    }
    private var fetchDetailsTasks: [Cancellable?] = []
    private var favoriteTask: Cancellable? {
        willSet {
            favoriteTask?.cancel()
        }
    }

    private var watchlistTask: Cancellable? {
        willSet {
            watchlistTask?.cancel()
        }
    }
    private var fetchAccountTask: Cancellable? {
        willSet {
            fetchAccountTask?.cancel()
        }
    }
    private var removeFromListTask: Cancellable? {
        willSet {
            removeFromListTask?.cancel()
        }
    }
    private var addedListId: Int?
    let error: Observable<String?> = Observable(nil)
    
    deinit {
        imageLoadTask?.cancel()
        addToListTask?.cancel()
        favoriteTask?.cancel()
        watchlistTask?.cancel()
        fetchAccountTask?.cancel()
        fetchListsTask?.cancel()
        removeFromListTask?.cancel()
        fetchMovieAccountStatesTask?.cancel()

        fetchDetailsTasks.forEach {
            $0?.cancel()
        }
    }
    

    // MARK: - OUTPUT
    let title: String
    let posterImage: Observable<Data?> = Observable(nil)
    let isPosterImageHidden: Bool
    let rating: String
    let overview: String
    
    init(
        movie: Movie,
        posterImagesRepository: PosterImagesRepository,
        movieDetailsRepository: MovieDetailsRepository,
        addMovieToListUseCase: AddMovieToListUseCase,
        removeMovieFromListUseCase: RemoveMovieFromListUseCase,
        fetchAccountUseCase: FetchAccountUseCase,
        fetchListsUseCase: FetchListsUseCase,
        fetchListDetailsUseCase: FetchListDetailsUseCase,
        markAsFavoriteUseCase: MarkAsFavoriteUseCase,
        markAsWatchlistUseCase: MarkAsWatchlistUseCase,
        fetchMovieAccountStatesUseCase: FetchMovieAccountStatesUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.movieId = movie.id
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
        self.movieDetailsRepository = movieDetailsRepository
        self.addMovieToListUseCase = addMovieToListUseCase
        self.removeMovieFromListUseCase = removeMovieFromListUseCase
        self.fetchAccountUseCase = fetchAccountUseCase
        self.fetchListsUseCase = fetchListsUseCase
        self.fetchListDetailsUseCase = fetchListDetailsUseCase
        self.markAsFavoriteUseCase = markAsFavoriteUseCase
        self.markAsWatchlistUseCase = markAsWatchlistUseCase
        self.fetchMovieAccountStatesUseCase = fetchMovieAccountStatesUseCase
        self.mainQueue = mainQueue
        self.rating = String(format: "%.1f", movie.rating ?? 0)

        self.isFavorite = Observable(
            movieDetailsRepository.isFavorite(movieId: movieId)
        )

        self.isInWatchlist = Observable(
            movieDetailsRepository.isInWatchlist(movieId: movieId)
        )
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }
        
        imageLoadTask = posterImagesRepository.fetchImage(
            with: posterImagePath,
            width: width
        ) { [weak self] result in
            self?.mainQueue.async {
                guard self?.posterImagePath == posterImagePath else { return }
                switch result {
                case .success(let data):
                    self?.posterImage.value = data
                case .failure: break
                }
                self?.imageLoadTask = nil
            }
        }
    }
    func toggleFavorite() {
        let newFavoriteStatus = !isFavorite.value

        favoriteTask = fetchAccountUseCase.execute { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let account):
                self.markAsFavorite(
                    accountId: account.id,
                    isFavorite: newFavoriteStatus
                )

            case .failure(let error):
                self.mainQueue.async {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    private func markAsFavorite(
        accountId: Int,
        isFavorite: Bool
    ) {
        guard let movieId = Int(movieId) else { return }

        favoriteTask = markAsFavoriteUseCase.execute(
            requestValue: MarkAsFavoriteUseCaseRequestValue(
                accountId: accountId,
                favoriteRequestDTO: FavoriteRequestDTO(
                    mediaType: "movie",
                    mediaId: movieId,
                    favorite: isFavorite
                )
            )
        ) { [weak self] result in
            self?.mainQueue.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.movieDetailsRepository.setFavorite(
                        movieId: self.movieId,
                        isFavorite: isFavorite
                    )

                    self.isFavorite.value = isFavorite

                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }
        }
    }

    func toggleWatchlist() {
        let newWatchlistStatus = !isInWatchlist.value

        watchlistTask = fetchAccountUseCase.execute { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let account):
                self.markAsWatchlist(
                    accountId: account.id,
                    isInWatchlist: newWatchlistStatus
                )

            case .failure(let error):
                self.mainQueue.async {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    private func markAsWatchlist(
        accountId: Int,
        isInWatchlist: Bool
    ) {
        guard let movieId = Int(movieId) else { return }

        watchlistTask = markAsWatchlistUseCase.execute(
            requestValue: MarkAsWatchlistUseCaseRequestValue(
                accountId: accountId,
                watchlistRequestDTO: WatchlistRequestDTO(
                    mediaType: "movie",
                    mediaId: movieId,
                    watchlist: isInWatchlist
                )
            )
        ) { [weak self] result in
            self?.mainQueue.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.movieDetailsRepository.setWatchlist(
                        movieId: self.movieId,
                        isInWatchlist: isInWatchlist
                    )

                    self.isInWatchlist.value = isInWatchlist

                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    func addToList(listId: Int) {
        guard let currentListId = addedListId else {
            addMovie(to: listId)
            return
        }

        if currentListId == listId {
            removeMovie(from: currentListId)
        } else {
            moveMovie(
                from: currentListId,
                to: listId
            )
        }
    }
    func viewWillAppear() {
        fetchMovieAccountStates()
    }
    private func addMovie(to listId: Int) {
        addToListTask = addMovieToListUseCase.execute(
            requestValue: AddMovieToListUseCaseRequestValue(
                listId: listId,
                movieId: movieId
            )
        ) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success:
                    self?.addedListId = listId
                    self?.isAddedToList.value = true

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    private func removeMovie(from listId: Int) {
        removeFromListTask = removeMovieFromListUseCase.execute(
            requestValue: RemoveMovieFromListUseCaseRequestValue(
                listId: listId,
                movieId: movieId
            )
        ) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success:
                    self?.addedListId = nil
                    self?.isAddedToList.value = false

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    private func moveMovie(
        from currentListId: Int,
        to newListId: Int
    ) {
        removeFromListTask = removeMovieFromListUseCase.execute(
            requestValue: RemoveMovieFromListUseCaseRequestValue(
                listId: currentListId,
                movieId: movieId
            )
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.addMovie(to: newListId)

            case .failure(let error):
                self.mainQueue.async {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    func updateAddedList(listId: Int?) {
        addedListId = listId
        isAddedToList.value = listId != nil
    }
    func viewDidLoad() {
        fetchAccountTask = fetchAccountUseCase.execute { [weak self] result in
            switch result {
            case .success(let account):
                self?.checkMovieListStatus(accountId: account.id)

            case .failure(let error):
                self?.mainQueue.async {
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    private func checkMovieListStatus(accountId: Int) {
        fetchListsTask = fetchListsUseCase.execute(
            requestValue: FetchListsUseCaseRequestValue(accountId: accountId)
        ) { [weak self] result in
            switch result {
            case .success(let lists):
                self?.checkMovieInLists(lists)

            case .failure(let error):
                self?.error.value = error.localizedDescription
            }
        }
    }

    private func checkMovieInLists(_ lists: [MovieList]) {
        fetchDetailsTasks.forEach { $0?.cancel() }
        fetchDetailsTasks.removeAll()

        for list in lists {
            let task = fetchListDetailsUseCase.execute(listId: list.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let movies):
                    let containsMovie = movies.contains {
                        String($0.id) == self.movieId
                    }

                    if containsMovie {
                        self.mainQueue.async {
                            self.addedListId = list.id
                            self.isAddedToList.value = true
                        }
                    }

                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }

            fetchDetailsTasks.append(task)
        }
    }
    private func fetchMovieAccountStates() {
        fetchMovieAccountStatesTask =
            fetchMovieAccountStatesUseCase.execute(
                requestValue: FetchMovieAccountStatesUseCaseRequestValue(
                    movieId: movieId
                )
            ) { [weak self] result in
                guard let self else { return }

                self.mainQueue.async {
                    switch result {
                    case .success(let states):
                        self.isFavorite.value = states.isFavorite
                        self.isInWatchlist.value = states.isInWatchlist

                        self.movieDetailsRepository.setFavorite(
                            movieId: self.movieId,
                            isFavorite: states.isFavorite
                        )

                        self.movieDetailsRepository.setWatchlist(
                            movieId: self.movieId,
                            isInWatchlist: states.isInWatchlist
                        )

                    case .failure(let error):
                        self.error.value = error.localizedDescription
                    }
                }
            }
    }
}
