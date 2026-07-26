//
//  FetchWatchlistMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

protocol FetchWatchlistMoviesUseCase {
    func execute(
        requestValue: FetchWatchlistMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase {

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: FetchWatchlistMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {

        return profileRepository.fetchWatchlistMovies(
            accountId: requestValue.accountId,
            requestValue: requestValue.moviesListRequestDTO,
            completion: completion
        )
    }
}

struct FetchWatchlistMoviesUseCaseRequestValue {
    let accountId: Int
    let moviesListRequestDTO: MoviesListRequestDTO
}
