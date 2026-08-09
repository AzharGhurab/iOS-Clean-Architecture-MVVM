//
//  DefaultListsRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

private enum AuthenticationError: LocalizedError {
    case missingSessionId

    var errorDescription: String? {
        "Session id is missing."
    }
}

final class DefaultListsRepository {

    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    private let authenticationStorage: AuthenticationStorage

    init(
        dataTransferService: DataTransferService,
        authenticationStorage: AuthenticationStorage,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
        self.authenticationStorage = authenticationStorage
    }
}

// MARK: - Private

private extension DefaultListsRepository {

    func validSessionId() throws -> String {
        guard let sessionId = authenticationStorage.sessionId() else {
            throw AuthenticationError.missingSessionId
        }

        return sessionId
    }
}

// MARK: - ListsRepository

extension DefaultListsRepository: ListsRepository {

    func fetchLists(
        accountId: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.getLists(
            accountId: accountId,
            sessionId: sessionId
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.results.map { $0.toDomain() }))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func createList(
        name: String,
        description: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let requestDTO = CreateListRequestDTO(
            name: name,
            description: description,
            language: "en"
        )

        let endpoint = APIEndpoints.createList(
            requestDTO: requestDTO,
            sessionId: sessionId
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func fetchListDetails(
        listId: Int,
        completion: @escaping (Result<[MovieSelectionMovie], Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.getListDetails(listId: listId)
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.items.map { $0.toDomain() }))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func deleteList(
        listId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.deleteList(
            listId: listId,
            sessionId: sessionId
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func addMovieToList(
        listId: Int,
        movieId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.addMovieToList(
            listId: listId,
            movieId: movieId,
            sessionId: sessionId
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success {
                    completion(.success(()))
                } else {
                    let error = NSError(
                        domain: "TMDB",
                        code: responseDTO.statusCode ?? 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: responseDTO.statusMessage ?? "Unknown error"
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
    func removeMovieFromList(
        listId: Int,
        movieId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.removeMovieFromList(
            listId: listId,
            movieId: movieId,
            sessionId: sessionId
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success {
                    completion(.success(()))
                } else {
                    let error = NSError(
                        domain: "TMDB",
                        code: responseDTO.statusCode ?? 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: responseDTO.statusMessage ?? "Unknown error"
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
