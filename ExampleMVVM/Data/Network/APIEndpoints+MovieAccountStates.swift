//
//  APIEndpoints+MovieAccountStates.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 12/02/1448 AH.
//

import Foundation

extension APIEndpoints {

    static func getMovieAccountStates(
        movieId: String,
        sessionId: String
    ) -> Endpoint<MovieAccountStatesResponseDTO> {

        return Endpoint(
            path: "3/movie/\(movieId)/account_states",
            method: .get,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }
}
