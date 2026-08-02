//
//  ProfileRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

protocol ProfileRepository {

    func fetchFavoriteMovies(
        accountId: Int,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func fetchWatchlistMovies(
        accountId: Int,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func markAsFavorite(
        accountId: Int,
        movieId: Int,
        isFavorite: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    func markAsWatchlist(
        accountId: Int,
        movieId: Int,
        isInWatchlist: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
    func fetchMovieAccountStates(
        movieId: String,
        completion: @escaping (Result<MovieAccountStates, Error>) -> Void
    ) -> Cancellable?
}
