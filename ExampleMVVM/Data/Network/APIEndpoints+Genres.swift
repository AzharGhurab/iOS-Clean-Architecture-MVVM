//
//  APIEndpoints+Genres.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 28/01/1448 AH.
//

import Foundation

extension APIEndpoints {

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
    static func searchMovies(
        with requestDTO: MoviesRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {
        Endpoint(
            path: "3/search/movie",
            method: .get,
            queryParametersEncodable: requestDTO
        )
    }

    static func searchTVShows(
        with requestDTO: MoviesRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {
        Endpoint(
            path: "3/search/tv",
            method: .get,
            queryParametersEncodable: requestDTO
        )
    }
}
