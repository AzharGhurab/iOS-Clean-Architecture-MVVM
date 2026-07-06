//
//  ListDetailsResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 17/01/1448 AH.
//

import Foundation

extension ListMovieDTO {
    func toDomain() -> ListDetailsMovie {
        ListDetailsMovie(
            id: id,
            title: title ?? name ?? "Unknown",
            posterPath: posterPath
        )
    }
}
