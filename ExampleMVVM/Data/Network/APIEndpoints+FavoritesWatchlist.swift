//
//  APIEndpoints+FavoritesWatchlist.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

extension APIEndpoints {

    static func getFavoriteMovies(
        accountId: Int,
        sessionId: String,
        requestDTO: MoviesListRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(
            path: "3/account/\(accountId)/favorite/movies",
            method: .get,
            queryParameters: [
                "session_id": sessionId,
                "page": requestDTO.page
            ]
        )
    }

    static func getWatchlistMovies(
        accountId: Int,
        sessionId: String,
        requestDTO: MoviesListRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(
            path: "3/account/\(accountId)/watchlist/movies",
            method: .get,
            queryParameters: [
                "session_id": sessionId,
                "page": requestDTO.page
            ]
        )
    }
    static func markAsFavorite(
        accountId: Int,
        sessionId: String,
        requestDTO: FavoriteRequestDTO
    ) -> Endpoint<CreateListResponseDTO> {

        return Endpoint(
            path: "3/account/\(accountId)/favorite",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParametersEncodable: requestDTO,
            bodyEncoder: JSONBodyEncoder()
        )
    }
    static func markAsWatchlist(
        accountId: Int,
        sessionId: String,
        requestDTO: WatchlistRequestDTO
    ) -> Endpoint<CreateListResponseDTO> {

        return Endpoint(
            path: "3/account/\(accountId)/watchlist",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParametersEncodable: requestDTO,
            bodyEncoder: JSONBodyEncoder()
        )
    }
}
