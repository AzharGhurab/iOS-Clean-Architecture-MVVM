//
//  FetchAccountUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 17/01/1448 AH.
//

import Foundation

protocol FetchAccountUseCase {
    func execute(
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchAccountUseCase: FetchAccountUseCase {

    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func execute(
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable? {
        authenticationRepository.fetchAccount(
            completion: completion
        )
    }
}
