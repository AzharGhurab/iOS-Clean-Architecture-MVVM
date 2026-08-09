//
//  MovieDetailsLocalStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/11/1447 AH.
//

import Foundation

final class UserDefaultsMovieDetailsRepository: MovieDetailsRepository {

    private let favoritesKey = "favorite_movie_ids"
    private let watchlistKey = "watchlist_movie_ids"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func isFavorite(movieId: String) -> Bool {
        ids(forKey: favoritesKey).contains(movieId)
    }

    func isInWatchlist(movieId: String) -> Bool {
        ids(forKey: watchlistKey).contains(movieId)
    }

    func toggleFavorite(movieId: String) {
        toggle(movieId: movieId, key: favoritesKey)
    }

    func toggleWatchlist(movieId: String) {
        toggle(movieId: movieId, key: watchlistKey)
    }
    func setFavorite(movieId: String,isFavorite: Bool) {
        var movieIds = ids(forKey: favoritesKey)

        if isFavorite {
            if !movieIds.contains(movieId) {
                movieIds.append(movieId)
            }
        } else {
            movieIds.removeAll { $0 == movieId }
        }

        userDefaults.set(movieIds, forKey: favoritesKey)
    }
    func setWatchlist(movieId: String,isInWatchlist: Bool) {
        var movieIds = ids(forKey: watchlistKey)
        
        if isInWatchlist {
            if !movieIds.contains(movieId) {
                movieIds.append(movieId)
            }
        } else {
            movieIds.removeAll { $0 == movieId }
        }
        
        userDefaults.set(movieIds, forKey: watchlistKey)
    }
        func clearCache() {
            userDefaults.removeObject(forKey: favoritesKey)
            userDefaults.removeObject(forKey: watchlistKey)
        }

    private func ids(forKey key: String) -> [String] {
        userDefaults.array(forKey: key) as? [String] ?? []
    }

    private func toggle(movieId: String, key: String) {
        var movieIds = ids(forKey: key)

        if movieIds.contains(movieId) {
            movieIds.removeAll { $0 == movieId }
        } else {
            movieIds.append(movieId)
        }

        userDefaults.set(movieIds, forKey: key)
    }
}
