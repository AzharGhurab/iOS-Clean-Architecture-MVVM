//
//  DefaultAuthenticationRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

final class DefaultAuthenticationRepository {

    private let dataTransferService: DataTransferService
    private let storage: AuthenticationStorage
    private let backgroundQueue: DataTransferDispatchQueue

    init(
        dataTransferService: DataTransferService,
        storage: AuthenticationStorage,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.storage = storage
        self.backgroundQueue = backgroundQueue
    }
}
extension DefaultAuthenticationRepository: AuthenticationRepository {

    func createGuestSession(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.createGuestSession()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.guestSessionId))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func createRequestToken(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.createRequestToken()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.requestToken))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func createSession(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        let endpoint = APIEndpoints.createSession(
            requestToken: requestToken
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if let sessionId = responseDTO.sessionId {
                    completion(.success(sessionId))
                } else {
                    let error = NSError(
                        domain: "TMDB",
                        code: responseDTO.statusCode ?? 0,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Authorization was cancelled. Please approve access in TMDB to continue."
                        ]
                    )
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
