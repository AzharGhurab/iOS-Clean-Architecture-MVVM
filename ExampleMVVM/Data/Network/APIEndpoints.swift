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
    // MARK: - Lists
    static func getLists(
        accountId: Int,
        sessionId: String
    ) -> Endpoint<MovieListsResponseDTO> {
        return Endpoint(
            path: "3/account/\(accountId)/lists",
            method: .get,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }
    static func createList(
        requestDTO: CreateListRequestDTO,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "name": requestDTO.name,
                "description": requestDTO.description,
                "language": requestDTO.language
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }
    static func getListDetails(
        listId: Int
    ) -> Endpoint<ListDetailsResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)",
            method: .get
        )
    }
    static func deleteList(
        listId: Int,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        Endpoint(
            path: "3/list/\(listId)",
            method: .delete,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }
    static func getAccountDetails(
        sessionId: String
    ) -> Endpoint<AccountResponseDTO> {

        Endpoint(
            path: "3/account",
            method: .get,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }
    static func addMovieToList(
        listId: Int,
        movieId: String,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)/add_item",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "media_id": movieId
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }
    static func removeMovieFromList(
        listId: Int,
        movieId: String,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)/remove_item",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "media_id": movieId
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }
}


