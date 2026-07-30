//
//  FetchPopularMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/02/1448 AH.
//

import Foundation

protocol FetchPopularMoviesUseCase {

    @discardableResult
    func execute(
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchPopularMoviesUseCase: FetchPopularMoviesUseCase {

    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    @discardableResult
    func execute(
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        return moviesRepository.fetchPopularMovies(
            page: page,
            completion: completion
        )
    }
}
