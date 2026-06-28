//
//  FetchListsUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

protocol FetchListsUseCase {
    func execute(
        requestValue: FetchListsUseCaseRequestValue,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchListsUseCase: FetchListsUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    func execute(
        requestValue: FetchListsUseCaseRequestValue,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {
        listsRepository.fetchLists(
            accountId: requestValue.accountId,
            completion: completion
        )
    }
}

struct FetchListsUseCaseRequestValue {
    let accountId: Int
}
