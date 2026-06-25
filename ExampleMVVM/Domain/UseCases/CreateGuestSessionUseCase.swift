//
//  CreateGuestSessionUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

protocol CreateGuestSessionUseCase {
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateGuestSessionUseCase: CreateGuestSessionUseCase {

    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        return authenticationRepository.createGuestSession(
            completion: completion
        )
    }
}
