//
//  DefaultListsRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

final class DefaultListsRepository {

    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue

    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
}

extension DefaultListsRepository: ListsRepository {

    func fetchLists(
        accountId: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {

        let endpoint = APIEndpoints.getLists(accountId: accountId)
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
}
