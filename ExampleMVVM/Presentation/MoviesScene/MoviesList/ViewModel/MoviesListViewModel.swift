import Foundation

struct MoviesListViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions:(@escaping (MovieQuery, Bool) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelectItem(at index: Int)
    func didSelectGenre(at index: Int)
    func didSelectCategory(_ category: SearchCategory)
    
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
    var genres: Observable<[Genre]> { get }
}

typealias MoviesListViewModel = MoviesListViewModelInput & MoviesListViewModelOutput

final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCase
    private var isSearching = false
    private let fetchGenresUseCase: FetchGenresUseCase
    private var movieGenres: [Genre] = []
    private var tvGenres: [Genre] = []
    private var selectedCategory: SearchCategory = .movies
    private let actions: MoviesListViewModelActions?
    private var allMovies: [Movie] = []
    private var popularMovies: [Movie] = []
    private var selectedGenreId: Int?
    private var displayedMovies: [Movie] = []
    let genres: Observable<[Genre]> = Observable([])
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    private var genresLoadTask: Cancellable? {
        willSet {genresLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueueType
    
    // MARK: - OUTPUT
    
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let emptyDataTitle = NSLocalizedString("No Found", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder =  NSLocalizedString("Search movies, TV shows...", comment: "")
    
    // MARK: - Init
    
    init(
        searchMoviesUseCase: SearchMoviesUseCase,
        fetchPopularMoviesUseCase: FetchPopularMoviesUseCase,
        fetchGenresUseCase: FetchGenresUseCase,
        actions: MoviesListViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
        self.fetchGenresUseCase = fetchGenresUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages
            .filter { $0.page != moviesPage.page }
        + [moviesPage]
        allMovies = pages.movies

        if !isSearching {
            popularMovies = allMovies
        }
        applyCurrentFilters()
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        displayedMovies.removeAll()
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        query.value = movieQuery.query
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
            })
    }
    
    private func loadPopularMovies(
        loading: MoviesListViewModelLoading
    ) {
        self.loading.value = loading

        moviesLoadTask = fetchPopularMoviesUseCase.execute(
            page: nextPage
        ) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let page):
                    self?.appendPage(page)

                case .failure(let error):
                    self?.handle(error: error)
                }

                self?.loading.value = .none
            }
        }
    }
    private func showDefaultMovies() {
        moviesLoadTask?.cancel()

        isSearching = false
        query.value = ""

        resetPages()
        loadPopularMovies(loading: .fullScreen)
    }
    
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery,isSearching: Bool) {
        self.isSearching = isSearching
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
    // MARK: - Private
    
    private func loadGenres() {
        genresLoadTask = fetchGenresUseCase.execute { [weak self] result in
            self?.mainQueue.async {
                guard let self else { return }

                switch result {
                case .success(let result):
                    self.movieGenres = result.movieGenres
                    self.tvGenres = result.tvGenres
                    self.genres.value = result.movieGenres

                case .failure(let error):
                    print("Error loading genres:", error)
                }
            }
        }
    }

    private func applyCurrentFilters() {
        let sourceItems = isSearching
            ? allMovies
            : popularMovies

        let categoryItems = sourceItems.filter { item in
            switch selectedCategory {
            case .movies:
                return item.mediaType == "movie" || item.mediaType == nil

            case .tvShows:
                return item.mediaType == "tv"
            }
        }

        if let selectedGenreId {
            displayedMovies = categoryItems.filter {
                $0.genreIds?.contains(selectedGenreId) ?? false
            }
        } else {
            displayedMovies = categoryItems
        }

        items.value = displayedMovies.map(
            MoviesListItemViewModel.init
        )
    }

    }

// MARK: - INPUT. View event methods

extension DefaultMoviesListViewModel {
    
    func viewDidLoad() {
        loadGenres()
        showDefaultMovies()
    }
    
    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }

        if isSearching {
            load(
                movieQuery: MovieQuery(query: query.value),
                loading: .nextPage
            )
        } else {
            loadPopularMovies(loading: .nextPage)
        }
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }

        isSearching = true
        update(movieQuery: MovieQuery(query: query), isSearching: true)
    }

    func didCancelSearch() {
        showDefaultMovies()
    }

    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions{ [weak self] movieQuery, isSearching in
            
            self?.update(
                movieQuery: movieQuery,
                isSearching: isSearching
            )
        }
    }

    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }

    func didSelectItem(at index: Int) {
        guard displayedMovies.indices.contains(index) else
        {
            return
        }
        actions?.showMovieDetails(displayedMovies[index])
    }
    func didSelectGenre(at index: Int) {
        if index == 0 {
            selectedGenreId = nil
            applyCurrentFilters()
            return
        }

        let genreIndex = index - 1

        guard genres.value.indices.contains(genreIndex) else {
            return
        }

        selectedGenreId = genres.value[genreIndex].id
        applyCurrentFilters()
    }
    func didSelectCategory(_ category: SearchCategory) {
        selectedCategory = category
        selectedGenreId = nil

        switch category {
        case .movies:
            genres.value = movieGenres

        case .tvShows:
            genres.value = tvGenres
        }

        applyCurrentFilters()
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
