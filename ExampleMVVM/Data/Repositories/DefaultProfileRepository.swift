//
//  DefaultProfileRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

private enum ProfileAuthenticationError: LocalizedError {
    case missingSessionId

    var errorDescription: String? {
        "Session id is missing."
    }
}

final class DefaultProfileRepository {

    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    private let authenticationStorage: AuthenticationStorage

    init(
        dataTransferService: DataTransferService,
        authenticationStorage: AuthenticationStorage,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(
            qos: .userInitiated
        )
    ) {
        self.dataTransferService = dataTransferService
        self.authenticationStorage = authenticationStorage
        self.backgroundQueue = backgroundQueue
    }
}

// MARK: - Private

private extension DefaultProfileRepository {

    func validSessionId() throws -> String {
        guard let sessionId = authenticationStorage.sessionId() else {
            throw ProfileAuthenticationError.missingSessionId
        }

        return sessionId
    }
}

// MARK: - ProfileRepository

extension DefaultProfileRepository: ProfileRepository {

    func fetchFavoriteMovies(
        accountId: Int,
        requestValue: MoviesListRequestDTO,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.getFavoriteMovies(
            accountId: accountId,
            sessionId: sessionId,
            requestDTO: requestValue
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func fetchWatchlistMovies(
        accountId: Int,
        requestValue: MoviesListRequestDTO,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.getWatchlistMovies(
            accountId: accountId,
            sessionId: sessionId,
            requestDTO: requestValue
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func markAsFavorite(
        accountId: Int,
        requestValue: FavoriteRequestDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.markAsFavorite(
            accountId: accountId,
            sessionId: sessionId,
            requestDTO: requestValue
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
                            NSLocalizedDescriptionKey:
                                responseDTO.statusMessage ?? "Unknown error"
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

    func markAsWatchlist(
        accountId: Int,
        requestValue: WatchlistRequestDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.markAsWatchlist(
            accountId: accountId,
            sessionId: sessionId,
            requestDTO: requestValue
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
                            NSLocalizedDescriptionKey:
                                responseDTO.statusMessage ?? "Unknown error"
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
    
    func fetchMovieAccountStates(
        movieId: String,
        completion: @escaping (
            Result<MovieAccountStates, Error>
        ) -> Void
    ) -> Cancellable? {

        let sessionId: String

        do {
            sessionId = try validSessionId()
        } catch {
            completion(.failure(error))
            return nil
        }

        let endpoint = APIEndpoints.getMovieAccountStates(
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
                completion(.success(responseDTO.toDomain()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
