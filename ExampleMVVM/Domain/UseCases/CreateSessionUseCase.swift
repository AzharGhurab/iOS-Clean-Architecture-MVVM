//
//  CreateSessionUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

protocol CreateSessionUseCase {
    func execute(
        requestValue: CreateSessionUseCaseRequestValue,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateSessionUseCase: CreateSessionUseCase {

    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func execute(
        requestValue: CreateSessionUseCaseRequestValue,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        return authenticationRepository.createSession(
            requestToken: requestValue.requestToken,
            completion: completion
        )
    }
}

struct CreateSessionUseCaseRequestValue {
    let requestToken: String
}
