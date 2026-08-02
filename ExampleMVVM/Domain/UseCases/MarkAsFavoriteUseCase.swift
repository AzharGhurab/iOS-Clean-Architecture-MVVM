//
//  MarkAsFavoriteUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

protocol MarkAsFavoriteUseCase {
    func execute(
        requestValue: MarkAsFavoriteUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}
final class DefaultMarkAsFavoriteUseCase: MarkAsFavoriteUseCase {

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        requestValue: MarkAsFavoriteUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        profileRepository.markAsFavorite(
            accountId: requestValue.accountId,
            movieId: requestValue.movieId,
            isFavorite: requestValue.isFavorite,
            completion: completion
        )
    }
}

struct MarkAsFavoriteUseCaseRequestValue {
    let accountId: Int
    let movieId: Int
    let isFavorite: Bool
}
