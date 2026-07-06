//
//  MovieListsResponseDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

struct MovieListsResponseDTO: Decodable {
    let page: Int
    let results: [MovieListDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieListDTO: Decodable {
    let id: Int
    let name: String
    let description: String
    let itemCount: Int
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case itemCount = "item_count"
        case posterPath = "poster_path"
    }
}
