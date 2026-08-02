//
//  MovieDetailsLocalStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/12/1447 AH.
//

protocol MovieDetailsRepository {
    func isFavorite(movieId: String) -> Bool
    func isInWatchlist(movieId: String) -> Bool

    func toggleFavorite(movieId: String)
    func toggleWatchlist(movieId: String)

    func setFavorite(
        movieId: String,
        isFavorite: Bool
    )

    func setWatchlist(
        movieId: String,
        isInWatchlist: Bool
    )
    func clearCache()
}

