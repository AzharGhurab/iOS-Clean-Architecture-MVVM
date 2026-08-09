//
//  GenresResponseDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 18/11/1447 AH.
//

import Foundation

struct GenresResponseDTO: Decodable {
    let genres: [GenreDTO]
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}

// MARK: - Mapping
extension GenreDTO {
    func toDomain() -> Genre {
        return Genre(
            id: id,
            name: name
        )
    }
}
