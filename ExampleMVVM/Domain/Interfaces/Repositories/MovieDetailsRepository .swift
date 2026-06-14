//
//  MovieDetailsLocalStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/12/1447 AH.
//

import Foundation

protocol MovieDetailsRepository {
    func isFavorite(movieId: String) -> Bool
    func isInWatchlist(movieId: String) -> Bool
    func toggleFavorite(movieId: String)
    func toggleWatchlist(movieId: String)
}
