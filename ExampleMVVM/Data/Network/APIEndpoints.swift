import Foundation

struct APIEndpoints {
     enum Header {
           static let contentType = "Content-Type"
           static let applicationJSON = "application/json;charset=utf-8"
       }

        enum Parameter {
           static let requestToken = "request_token"
       }
    
    static func searchMedia(category: SearchCategory,
        with moviesRequestDTO: MoviesRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {

        let path: String

        switch category {
        case .movies:
            path = "3/search/movie"

        case .tvShows:
            path = "3/search/tv"
        }

        return Endpoint(
            path: path,
            method: .get,
            queryParametersEncodable: moviesRequestDTO
        )
    }
    static func getNowPlayingMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/now_playing",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getPopularMedia(category: SearchCategory,with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {

        let categoryPath: String

        switch category {
        case .movies:
            categoryPath = "movie"

        case .tvShows:
            categoryPath = "tv"
        }

        return Endpoint(
            path: "3/\(categoryPath)/popular",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getTopRatedMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/top_rated",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getUpcomingMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/upcoming",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {

        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes
            .enumerated()
            .min { abs($0.1 - width) < abs($1.1 - width) }?
            .element ?? sizes.first!
        
        return Endpoint(
            path: "t/p/w\(closestWidth)\(path)",
            method: .get,
            responseDecoder: RawDataResponseDecoder()
        )
    }
}
