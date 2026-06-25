import Foundation

struct APIEndpoints {
    private enum Header {
           static let contentType = "Content-Type"
           static let applicationJSON = "application/json;charset=utf-8"
       }

       private enum Parameter {
           static let requestToken = "request_token"
       }
    
    static func getMovies(with moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(
            path: "3/search/multi",
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

    static func getPopularMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/popular",
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
    // MARK: - Genres
        
        static func getMovieGenres() -> Endpoint<GenresResponseDTO> {
            return Endpoint(
                path: "3/genre/movie/list",
                method: .get
            )
        }
        
        static func getTVGenres() -> Endpoint<GenresResponseDTO> {
            return Endpoint(
                path: "3/genre/tv/list",
                method: .get
            )
        }
    // MARK: - Authentication
    
    static func createGuestSession() -> Endpoint<GuestSessionResponseDTO> {
        return Endpoint(
            path: "3/authentication/guest_session/new",
            method: .get
        )
    }
    
    static func createRequestToken() -> Endpoint<RequestTokenResponseDTO> {
        return Endpoint(
            path: "3/authentication/token/new",
            method: .get
        )
    }
    
    static func createSession(requestToken: String) -> Endpoint<SessionResponseDTO> {
        return Endpoint(
            path: "3/authentication/session/new",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            bodyParameters: [
                Parameter.requestToken: requestToken
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }
}


