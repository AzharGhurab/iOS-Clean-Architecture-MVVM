//
//  MarkAsWatchlistUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

protocol MarkAsWatchlistUseCase {
    func execute(
        requestValue: MarkAsWatchlistUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultMarkAsWatchlistUseCase: MarkAsWatchlistUseCase {

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: MarkAsWatchlistUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        profileRepository.markAsWatchlist(
            accountId: requestValue.accountId,
            movieId: requestValue.movieId,
            isInWatchlist: requestValue.isInWatchlist,
            completion: completion
        )
    }
}

struct MarkAsWatchlistUseCaseRequestValue {
    let accountId: Int
    let movieId: Int
    let isInWatchlist: Bool
}
