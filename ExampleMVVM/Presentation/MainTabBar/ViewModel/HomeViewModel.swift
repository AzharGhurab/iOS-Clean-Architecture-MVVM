//
//  HomeViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/11/1447 AH.
//

import Foundation

struct HomeMovieCellViewModel {
    let title: String?
    let rating: String
    let posterPath: String?
}

struct HomeSectionViewModel {
    let title: String
    let movies: [HomeMovieCellViewModel]
}

struct HomeViewModelActions {
    let showMovieDetails: (Movie) -> Void
}

protocol HomeViewModelInput {
    func viewDidLoad()
    func didSelectMovie(sectionIndex: Int, movieIndex: Int)
}

protocol HomeViewModelOutput {
    var sections: Observable<[HomeSectionViewModel]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var screenTitle: String { get }
}

typealias HomeViewModel = HomeViewModelInput & HomeViewModelOutput

final class DefaultHomeViewModel: HomeViewModel {
    
    private let fetchHomeMoviesUseCase: FetchHomeMoviesUseCase
    private let actions: HomeViewModelActions?
    private let mainQueue: DispatchQueueType
    private var movieSections: [[Movie]] = []
    private var loadTask: Cancellable? { willSet { loadTask?.cancel() } }
    
    let sections: Observable<[HomeSectionViewModel]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String> = Observable("")
    let screenTitle = NSLocalizedString("Home", comment: "")
    
    init(
        fetchHomeMoviesUseCase: FetchHomeMoviesUseCase,
        actions: HomeViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.fetchHomeMoviesUseCase = fetchHomeMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }
    
    func viewDidLoad() {
        loadHomeMovies()
    }
    
    func didSelectMovie(sectionIndex: Int, movieIndex: Int) {
        guard movieSections.indices.contains(sectionIndex),
              movieSections[sectionIndex].indices.contains(movieIndex) else {
            return
        }
        
        let movie = movieSections[sectionIndex][movieIndex]
        actions?.showMovieDetails(movie)
    }
}

// MARK: - Private

private extension DefaultHomeViewModel {
    
    func loadHomeMovies() {
        loading.value = true
        
        loadTask = fetchHomeMoviesUseCase.execute { [weak self] result in
            self?.mainQueue.async {
                guard let self = self else { return }
                self.loading.value = false
                
                switch result {
                case .success(let homeMovies):
                    
                    self.movieSections = [
                        homeMovies.nowPlaying,
                        homeMovies.popular,
                        homeMovies.topRated,
                        homeMovies.upcoming
                    ]
                    
                    self.sections.value = [
                        HomeSectionViewModel(
                            title: NSLocalizedString("Now Playing", comment: ""),
                            movies: homeMovies.nowPlaying.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            title: NSLocalizedString("Popular", comment: ""),
                            movies: homeMovies.popular.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            title: NSLocalizedString("Top Rated", comment: ""),
                            movies: homeMovies.topRated.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            title: NSLocalizedString("Upcoming", comment: ""),
                            movies: homeMovies.upcoming.map { HomeMovieCellViewModel(movie: $0) }
                        )
                    ]
                    
                case .failure(let error):
                    self.handle(error: error)
                }
            }
        }
    }
    
    func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }
}
private extension HomeMovieCellViewModel {
    
    init(movie: Movie) {
        self.title = movie.title
        self.rating = String(format: "%.1f", movie.rating ?? 0)
        self.posterPath = movie.posterPath
    }
}
