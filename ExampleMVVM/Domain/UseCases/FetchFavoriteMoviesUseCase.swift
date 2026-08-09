//
//  FetchFavoriteMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

protocol FetchFavoriteMoviesUseCase {
    func execute(
        requestValue: FetchFavoriteMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase {

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: FetchFavoriteMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {

        profileRepository.fetchFavoriteMovies(
            accountId: requestValue.accountId,
            page: requestValue.page,
            completion: completion
        )
    }
}

struct FetchFavoriteMoviesUseCaseRequestValue {
    let accountId: Int
    let page: Int
}
