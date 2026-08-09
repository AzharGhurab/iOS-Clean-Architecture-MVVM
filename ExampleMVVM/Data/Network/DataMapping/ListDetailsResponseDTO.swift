//
//  ListDetailsResponseDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//
import Foundation

struct ListDetailsResponseDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let itemCount: Int
    let items: [ListMovieDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case itemCount = "item_count"
        case items
    }
}

struct ListMovieDTO: Decodable {
    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case posterPath = "poster_path"
    }
}
