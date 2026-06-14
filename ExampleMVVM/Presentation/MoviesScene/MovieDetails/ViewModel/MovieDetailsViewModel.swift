import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
    func toggleFavorite()
    func toggleWatchlist()
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var rating: String { get }
    var isFavorite: Observable<Bool> { get }
    var isInWatchlist: Observable<Bool> { get }
    var overview: String { get }
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
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.movieId = movie.id
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
        self.movieDetailsRepository = movieDetailsRepository
        self.mainQueue = mainQueue
        self.rating = String(format: "%.1f", movie.rating ?? 0)
        self.isFavorite = Observable(movieDetailsRepository.isFavorite(movieId: movieId))
        self.isInWatchlist = Observable(movieDetailsRepository.isInWatchlist(movieId: movieId))
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
        movieDetailsRepository.toggleFavorite(movieId: movieId)
        isFavorite.value = movieDetailsRepository.isFavorite(movieId: movieId)
    }

    func toggleWatchlist() {
        movieDetailsRepository.toggleWatchlist(movieId: movieId)
        isInWatchlist.value = movieDetailsRepository.isInWatchlist(movieId: movieId)
    }
}
