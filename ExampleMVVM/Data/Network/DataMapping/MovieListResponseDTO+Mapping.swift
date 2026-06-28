//
//  MovieListResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

extension MovieListDTO {
    func toDomain() -> MovieList {
        MovieList(
            id: id,
            name: name,
            description: description,
            itemCount: itemCount,
            posterPath: posterPath
        )
    }
}
