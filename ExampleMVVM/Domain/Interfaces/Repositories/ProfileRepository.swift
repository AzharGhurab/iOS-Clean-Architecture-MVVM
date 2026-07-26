//
//  ProfileRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

protocol ProfileRepository {

    func fetchFavoriteMovies(
        accountId: Int,
        requestValue: MoviesListRequestDTO,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func fetchWatchlistMovies(
        accountId: Int,
        requestValue: MoviesListRequestDTO,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func markAsFavorite(
        accountId: Int,
        requestValue: FavoriteRequestDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    func markAsWatchlist(
        accountId: Int,
        requestValue: WatchlistRequestDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
    
    func fetchMovieAccountStates(
        movieId: String,
        completion: @escaping (Result<MovieAccountStates, Error>) -> Void
    ) -> Cancellable?
}
