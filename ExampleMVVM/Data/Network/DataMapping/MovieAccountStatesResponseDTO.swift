//
//  MovieAccountStatesResponseDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 12/02/1448 AH.
//

import Foundation

struct MovieAccountStatesResponseDTO: Decodable {
    let id: Int
    let favorite: Bool
    let watchlist: Bool
}

extension MovieAccountStatesResponseDTO {

    func toDomain() -> MovieAccountStates {
        return MovieAccountStates(
            isFavorite: favorite,
            isInWatchlist: watchlist
        )
    }
}
