//
//  FetchMovieAccountStatesUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 12/02/1448 AH.
//

import Foundation

protocol FetchMovieAccountStatesUseCase {
    func execute(
        requestValue: FetchMovieAccountStatesUseCaseRequestValue,
        completion: @escaping (
            Result<MovieAccountStates, Error>
        ) -> Void
    ) -> Cancellable?
}
final class DefaultFetchMovieAccountStatesUseCase:
    FetchMovieAccountStatesUseCase {

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: FetchMovieAccountStatesUseCaseRequestValue,
        completion: @escaping (
            Result<MovieAccountStates, Error>
        ) -> Void
    ) -> Cancellable? {

        return profileRepository.fetchMovieAccountStates(
            movieId: requestValue.movieId,
            completion: completion
        )
    }
}

struct FetchMovieAccountStatesUseCaseRequestValue {
    let movieId: String
}
