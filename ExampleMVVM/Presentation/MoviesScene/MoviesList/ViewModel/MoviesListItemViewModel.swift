// **Note**: This item view model is to display data and does not contain any domain model to prevent views accessing it

import Foundation

struct MoviesListItemViewModel: Equatable {
    let title: String
    let overview: String
    let releaseDate: String
    let posterImagePath: String?
    let rating: String
}

extension MoviesListItemViewModel {

    init(movie: Movie,category: SearchCategory) {
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""
        self.rating = String(format: "%.1f", movie.rating ?? 0)
        let type = category == .tvShows
                    ? "TV Show"
                    : "Movie"

                if let releaseDate = movie.releaseDate {
                    let year = Calendar.current.component(
                        .year,
                        from: releaseDate
                    )

                    self.releaseDate = "\(year) • \(type)"
                } else {
                    self.releaseDate = type
                }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
