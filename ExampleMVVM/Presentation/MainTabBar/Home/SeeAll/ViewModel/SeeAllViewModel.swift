//
//  SeeAllViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/02/1448 AH.
//

import Foundation

struct SeeAllViewModelActions {
    let showMovieDetails: (Movie) -> Void
}

enum SeeAllViewModelLoading {
    case fullScreen
    case nextPage
}

protocol SeeAllViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSelectGenre(at index: Int)
    func didSelectItem(at index: Int)
}

protocol SeeAllViewModelOutput {
    var title: String { get }
    var items: Observable<[MoviesListItemViewModel]> { get }
    var genres: Observable<[Genre]> { get }
    var loading: Observable<SeeAllViewModelLoading?> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
}

typealias SeeAllViewModel =
    SeeAllViewModelInput & SeeAllViewModelOutput

final class DefaultSeeAllViewModel: SeeAllViewModel {

    // MARK: - Dependencies

    private let section: HomeSectionType
    private let fetchSeeAllMoviesUseCase: FetchSeeAllMoviesUseCase
    private let fetchGenresUseCase: FetchGenresUseCase
    private let actions: SeeAllViewModelActions?
    private let mainQueue: DispatchQueueType
    // MARK: - State

    private var pages: [MoviesPage] = []
    private var allMovies: [Movie] = []
    private var displayedMovies: [Movie] = []
    
    private var selectedGenreId: Int?

    private var currentPage = 0
    private var totalPageCount = 1

    private var moviesLoadTask: Cancellable? {
        willSet {
            moviesLoadTask?.cancel()
        }
    }

    private var genresLoadTask: Cancellable? {
        willSet {
            genresLoadTask?.cancel()
        }
    }

    private var hasMorePages: Bool {
        currentPage < totalPageCount
    }

    private var nextPage: Int {
        hasMorePages ? currentPage + 1 : currentPage
    }

    // MARK: - Output

    let items: Observable<[MoviesListItemViewModel]> =
        Observable([])

    let genres: Observable<[Genre]> =
        Observable([])

    let loading: Observable<SeeAllViewModelLoading?> =
        Observable(nil)

    let error: Observable<String> =
        Observable("")

    var isEmpty: Bool {
        items.value.isEmpty
    }

    var title: String {
        switch section {
        case .nowPlaying:
            return NSLocalizedString(
                "Now Playing",
                comment: ""
            )

        case .popular:
            return NSLocalizedString(
                "Popular",
                comment: ""
            )

        case .topRated:
            return NSLocalizedString(
                "Top Rated",
                comment: ""
            )

        case .upcoming:
            return NSLocalizedString(
                "Upcoming",
                comment: ""
            )
        }
    }

    // MARK: - Init

    init(
        section: HomeSectionType,
        fetchSeeAllMoviesUseCase: FetchSeeAllMoviesUseCase,
        fetchGenresUseCase: FetchGenresUseCase,
        actions: SeeAllViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.section = section
        self.fetchSeeAllMoviesUseCase =
            fetchSeeAllMoviesUseCase
        self.fetchGenresUseCase = fetchGenresUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }

    deinit {
        moviesLoadTask?.cancel()
        genresLoadTask?.cancel()
    }
}

// MARK: - Input

extension DefaultSeeAllViewModel {

    func viewDidLoad() {
        loadGenres()
        resetPages()
        loadMovies(loading: .fullScreen)
    }

    func didLoadNextPage() {
        guard hasMorePages else {
            return
        }

        guard loading.value == nil else {
            return
        }

        loadMovies(loading: .nextPage)
    }

    func didSelectGenre(at index: Int) {
        if index == 0 {
            selectedGenreId = nil
            displayedMovies = allMovies
            updateItems()
            return
        }

        let genreIndex = index - 1

        guard genres.value.indices.contains(genreIndex) else {
            return
        }

        let selectedGenre = genres.value[genreIndex]
        selectedGenreId = selectedGenre.id

        applySelectedGenre()
    }

    func didSelectItem(at index: Int) {
        guard displayedMovies.indices.contains(index) else {
            return
        }

        let movie = displayedMovies[index]
        actions?.showMovieDetails(movie)
    }
}

// MARK: - Private

private extension DefaultSeeAllViewModel {

    func loadMovies(
        loading: SeeAllViewModelLoading
    ) {
        self.loading.value = loading
        error.value = ""

        moviesLoadTask =
            fetchSeeAllMoviesUseCase.execute(
                requestValue:
                    FetchSeeAllMoviesUseCaseRequestValue(
                        section: section,
                        page: nextPage
                    )
            ) { [weak self] result in
                self?.mainQueue.async {
                    guard let self else {
                        return
                    }

                    switch result {
                    case .success(let page):
                        self.appendPage(page)

                    case .failure(let error):
                        self.handle(error: error)
                    }

                    self.loading.value = nil
                }
            }
    }

    func loadGenres() {
        genresLoadTask = fetchGenresUseCase.execute { [weak self] result in
            self?.mainQueue.async {
                guard let self else {
                    return
                }

                switch result {
                case .success(let result):
                    self.genres.value = result.movieGenres

                case .failure(let error):
                    self.handle(error: error)
                }
            }
        }
    }

    func appendPage(_ page: MoviesPage) {
        currentPage = page.page
        totalPageCount = page.totalPages

        pages = pages.filter {
            $0.page != page.page
        } + [page]

        pages.sort {
            $0.page < $1.page
        }

        allMovies = pages.flatMap {
            $0.movies
        }

        applySelectedGenre()
    }

    func applySelectedGenre() {
        guard let selectedGenreId else {
            displayedMovies = allMovies
            updateItems()
            return
        }

        displayedMovies = allMovies.filter {
            $0.genreIds?.contains(selectedGenreId) ?? false
        }

        updateItems()
    }

    func updateItems() {
        items.value = displayedMovies.map(
            MoviesListItemViewModel.init
        )
    }

    func resetPages() {
        currentPage = 0
        totalPageCount = 1

        pages.removeAll()
        allMovies.removeAll()
        displayedMovies.removeAll()

        items.value.removeAll()
    }

    func handle(error: Error) {
        self.error.value =
            error.isInternetConnectionError
            ? NSLocalizedString(
                "No internet connection",
                comment: ""
            )
            : NSLocalizedString(
                "Failed loading movies",
                comment: ""
            )
    }
}
