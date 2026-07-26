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

    init(profileRepository: ProfileRepository)
    {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: MarkAsWatchlistUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        return profileRepository.markAsWatchlist(
            accountId: requestValue.accountId,
            requestValue: requestValue.watchlistRequestDTO,
            completion: completion
        )
    }
}

struct MarkAsWatchlistUseCaseRequestValue {
    let accountId: Int
    let watchlistRequestDTO: WatchlistRequestDTO
}
