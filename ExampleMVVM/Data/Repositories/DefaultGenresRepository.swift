//
//  DefaultGenresRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/12/1447 AH.
//

import Foundation

final class DefaultGenresRepository: GenresRepository {

    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue

    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }

    func fetchMovieGenres(
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.getMovieGenres()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                let genres = responseDTO.genres.map { $0.toDomain() }
                completion(.success(genres))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    func fetchTVGenres(
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.getTVGenres()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                let genres = responseDTO.genres.map { $0.toDomain() }
                completion(.success(genres))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
